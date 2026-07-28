import json
import unicodedata
from datetime import datetime
from sqlalchemy.orm import Session

from models.models import Cidade, Rota, Horario


def remover_acentos(texto: str) -> str:
    nfkd = unicodedata.normalize("NFKD", texto)
    return "".join(c for c in nfkd if not unicodedata.combining(c))


def popular_banco(db: Session) -> dict:
    with open("rotas.json", "r", encoding="utf-8") as file:
        dados = json.load(file)

    for item in dados:
        origem = db.query(Cidade).filter(Cidade.nome == item["origem"]).first()
        if not origem:
            origem = Cidade(nome=item["origem"])
            db.add(origem)
            db.commit()
            db.refresh(origem)

        destino = db.query(Cidade).filter(Cidade.nome == item["destino"]).first()
        if not destino:
            destino = Cidade(nome=item["destino"])
            db.add(destino)
            db.commit()
            db.refresh(destino)

        tarifa_val = None
        if item["tarifa"]:
            tarifa_str = item["tarifa"].replace("R$ ", "").replace(",", ".")
            tarifa_val = float(tarifa_str)

        nova_rota = Rota(
            origem_id=origem.id,
            destino_id=destino.id,
            distancia_km=item["km"],
            tarifa=tarifa_val,
            ativa=True
        )
        db.add(nova_rota)
        db.commit()
        db.refresh(nova_rota)

        for hora_str in item["horarios_origem"]:
            hora_obj = datetime.strptime(hora_str, "%H:%M").time()
            db.add(Horario(rota_id=nova_rota.id, sentido="IDA", hora=hora_obj, dias_funcionamento=item["dias_operacao"]))

        for hora_str in item["horarios_destino"]:
            hora_obj = datetime.strptime(hora_str, "%H:%M").time()
            db.add(Horario(rota_id=nova_rota.id, sentido="VOLTA", hora=hora_obj, dias_funcionamento=item["dias_operacao"]))

        db.commit()

    return {"mensagem": "Sucesso! Banco de dados do Passaí foi populado com as rotas iniciais."}


def buscar_rotas_service(origem: str, destino: str, db: Session) -> list:
    origem_sem_acento = remover_acentos(origem).lower()
    destino_sem_acento = remover_acentos(destino).lower()

    cidades = db.query(Cidade).all()
    cidade_origem = next(
        (c for c in cidades if origem_sem_acento in remover_acentos(c.nome).lower()), None
    )
    cidade_destino = next(
        (c for c in cidades if destino_sem_acento in remover_acentos(c.nome).lower()), None
    )

    if not cidade_origem or not cidade_destino:
        return None

    rotas = db.query(Rota).filter(
        Rota.origem_id == cidade_origem.id,
        Rota.destino_id == cidade_destino.id,
        Rota.ativa == True
    ).all()

    if not rotas:
        return []

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