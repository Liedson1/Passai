from fastapi import FastAPI
from config.database import engine
from models.models import Base
from views.rotas_view import router as rotas_router

Base.metadata.create_all(bind=engine)

app = FastAPI(title="API Passaí")

app.include_router(rotas_router)


@app.get("/")
def ler_raiz():
    return {"mensagem": "Bem-vindo à API do Passaí! O servidor está rodando perfeitamente."}