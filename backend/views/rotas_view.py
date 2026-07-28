from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from config.database import get_db
from services.rota_service import popular_banco as popular_banco_svc, buscar_rotas_service

router = APIRouter(prefix="/rotas", tags=["Rotas"])


@router.post("/popular-banco")
def popular_banco(db: Session = Depends(get_db)):
    try:
        return popular_banco_svc(db)
    except Exception as e:
        return {"erro": f"Ops, algo deu errado: {str(e)}"}


@router.get("/buscar")
def buscar_rotas(
    origem: str = Query(..., description="Nome da cidade de origem"),
    destino: str = Query(..., description="Nome da cidade de destino"),
    db: Session = Depends(get_db)
):
    resultado = buscar_rotas_service(origem, destino, db)

    if resultado is None:
        raise HTTPException(status_code=404, detail="Cidade de origem ou destino não encontrada.")

    if not resultado:
        raise HTTPException(status_code=404, detail="Nenhuma rota encontrada entre estas cidades.")

    return resultado