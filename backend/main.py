import json
import unicodedata
from datetime import datetime
from fastapi import FastAPI, Depends, HTTPException, Query
from sqlalchemy.orm import Session
import models
from database import engine, get_db

def remover_acentos(texto: str) -> str:
    nfkd = unicodedata.normalize("NFKD", texto)
    return "".join(c for c in nfkd if not unicodedata.combining(c))

# Cria as tabelas se não existirem
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="API Passaí")

@app.get("/")
def ler_raiz():
    return {"mensagem": "Bem-vindo à API do Passaí! O servidor está rodando perfeitamente."}

# Rota temporária para importar os dados do JSON para o PostgreSQL
@app.post("/popular-banco")
def popular_banco(db: Session = Depends(get_db)):
    try:
        # Lê o arquivo JSON
        with open("rotas.json", "r", encoding="utf-8") as file:
            dados = json.load(file)

        for item in dados:
            # 1. Verifica se a cidade de Origem já existe. Se não, cria.
            origem = db.query(models.Cidade).filter(models.Cidade.nome == item["origem"]).first()
            if not origem:
                origem = models.Cidade(nome=item["origem"])
                db.add(origem)
                db.commit()
                db.refresh(origem)

            # 2. Verifica se a cidade de Destino já existe. Se não, cria.
            destino = db.query(models.Cidade).filter(models.Cidade.nome == item["destino"]).first()
            if not destino:
                destino = models.Cidade(nome=item["destino"])
                db.add(destino)
                db.commit()
                db.refresh(destino)

            # 3. Formata o valor da tarifa (Tira o "R$ " e converte para número)
            tarifa_val = None
            if item["tarifa"]:
                tarifa_str = item["tarifa"].replace("R$ ", "").replace(",", ".")
                tarifa_val = float(tarifa_str)

            # 4. Cadastra a Rota
            nova_rota = models.Rota(
                origem_id=origem.id,
                destino_id=destino.id,
                distancia_km=item["km"],
                tarifa=tarifa_val,
                ativa=True
            )
            db.add(nova_rota)
            db.commit()
            db.refresh(nova_rota)

            # 5. Cadastra os Horários de IDA
            for hora_str in item["horarios_origem"]:
                hora_obj = datetime.strptime(hora_str, "%H:%M").time()
                db.add(models.Horario(rota_id=nova_rota.id, sentido="IDA", hora=hora_obj, dias_funcionamento=item["dias_operacao"]))

            # 6. Cadastra os Horários de VOLTA
            for hora_str in item["horarios_destino"]:
                hora_obj = datetime.strptime(hora_str, "%H:%M").time()
                db.add(models.Horario(rota_id=nova_rota.id, sentido="VOLTA", hora=hora_obj, dias_funcionamento=item["dias_operacao"]))

            db.commit()

        return {"mensagem": "Sucesso! Banco de dados do Passaí foi populado com as rotas iniciais."}
    
    except Exception as e:
        return {"erro": f"Ops, algo deu errado: {str(e)}"}


@app.get("/rotas/buscar")
def buscar_rotas(
    origem: str = Query(..., description="Nome da cidade de origem"),
    destino: str = Query(..., description="Nome da cidade de destino"),
    db: Session = Depends(get_db)
):
    origem_sem_acento = remover_acentos(origem).lower()
    destino_sem_acento = remover_acentos(destino).lower()

    cidades = db.query(models.Cidade).all()
    cidade_origem = next(
        (c for c in cidades if origem_sem_acento in remover_acentos(c.nome).lower()), None
    )
    cidade_destino = next(
        (c for c in cidades if destino_sem_acento in remover_acentos(c.nome).lower()), None
    )

    if not cidade_origem or not cidade_destino:
        raise HTTPException(status_code=404, detail="Cidade de origem ou destino não encontrada.")

    rotas = db.query(models.Rota).filter(
        models.Rota.origem_id == cidade_origem.id,
        models.Rota.destino_id == cidade_destino.id,
        models.Rota.ativa == True
    ).all()

    if not rotas:
        raise HTTPException(status_code=404, detail="Nenhuma rota encontrada entre estas cidades.")

    resultado = []
    for rota in rotas:
        horarios_ida = sorted([h.hora.strftime("%H:%M") for h in rota.horarios if h.sentido == "IDA"])
        horarios_volta = sorted([h.hora.strftime("%H:%M") for h in rota.horarios if h.sentido == "VOLTA"])

        resultado.append({
            "rota_id": rota.id,
            "origem": cidade_origem.nome,
            "destino": cidade_destino.nome,
            "distancia_km": rota.distancia_km,
            "tarifa": float(rota.tarifa) if rota.tarifa else None,
            "horarios_ida": horarios_ida,
            "horarios_volta": horarios_volta
        })

    return resultado