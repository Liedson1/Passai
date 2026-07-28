from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, Numeric, Time
from sqlalchemy.orm import relationship
from database import Base

class Cidade(Base):
    __tablename__ = "cidades"
    
    id = Column(Integer, primary_key=True, index=True)
    nome = Column(String, unique=True, index=True)
    estado = Column(String, default="AL")

class Rota(Base):
    __tablename__ = "rotas"
    
    id = Column(Integer, primary_key=True, index=True)
    origem_id = Column(Integer, ForeignKey("cidades.id"))
    destino_id = Column(Integer, ForeignKey("cidades.id"))
    distancia_km = Column(Integer, nullable=True)
    tarifa = Column(Numeric(10, 2), nullable=True)
    ativa = Column(Boolean, default=True)

    horarios = relationship("Horario", back_populates="rota", cascade="all, delete-orphan")

class Horario(Base):
    __tablename__ = "horarios"
    
    id = Column(Integer, primary_key=True, index=True)
    rota_id = Column(Integer, ForeignKey("rotas.id"))
    sentido = Column(String)  # 'IDA' ou 'VOLTA'
    hora = Column(Time)
    dias_funcionamento = Column(String, default="Segunda a Domingo")

    rota = relationship("Rota", back_populates="horarios")