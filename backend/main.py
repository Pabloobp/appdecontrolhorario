from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from fastapi.responses import FileResponse
from datetime import datetime
from sqlalchemy import Column, String, DateTime
from sqlalchemy.orm import Session
import pandas as pd
from fpdf import FPDF
import os
from dotenv import load_dotenv

from database import get_db, Base, engine

load_dotenv()

app = FastAPI()

# La llave para entrar al sitio
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

# --- MODELOS DE BASE DE DATOS ---

class Usuario(Base):
    __tablename__ = "usuarios"
    username = Column(String, primary_key=True)
    password = Column(String)
    empresa = Column(String)

class RegistroHorario(Base):
    __tablename__ = "registros_horarios"
    id = Column(String, primary_key=True, default=lambda: str(datetime.now().timestamp()))
    usuario = Column(String)
    empresa = Column(String)
    tipo = Column(String)  # ENTRADA o SALIDA
    fecha_hora = Column(DateTime, default=datetime.now)

# Crear las tablas en Supabase
Base.metadata.create_all(bind=engine)

@app.get("/")
def home():
    return {"mensaje": "Entorno de DESARROLLO - App Control Horario activa"}

@app.post("/login")
async def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(Usuario).filter(Usuario.username == form_data.username).first()
    if not user or form_data.password != user.password:
        raise HTTPException(status_code=401, detail="Error de acceso")
    return {"access_token": user.username, "token_type": "bearer"}

# --- SECCIÓN DE FICHAJES ---

@app.post("/fichar-entrada")
async def fichar_entrada(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    ahora = datetime.now()
    user_data = db.query(Usuario).filter(Usuario.username == token).first()
    
    if not user_data:
        raise HTTPException(status_code=401, detail="Usuario no encontrado")
    
    nuevo_registro = RegistroHorario(
        usuario=token,
        empresa=user_data.empresa,
        tipo="ENTRADA",
        fecha_hora=ahora
    )
    db.add(nuevo_registro)
    db.commit()
    db.refresh(nuevo_registro)
    
    return {"mensaje": "Entrada fichada, ¡a darle!", "detalle": {
        "usuario": token,
        "empresa": user_data.empresa,
        "tipo": "ENTRADA",
        "fecha_hora": ahora.strftime("%Y-%m-%d %H:%M:%S")
    }}

@app.post("/fichar-salida")
async def fichar_salida(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    ahora = datetime.now()
    user_data = db.query(Usuario).filter(Usuario.username == token).first()
    
    if not user_data:
        raise HTTPException(status_code=401, detail="Usuario no encontrado")
    
    nuevo_registro = RegistroHorario(
        usuario=token,
        empresa=user_data.empresa,
        tipo="SALIDA",
        fecha_hora=ahora
    )
    db.add(nuevo_registro)
    db.commit()
    db.refresh(nuevo_registro)
    
    return {"mensaje": "Salida fichada, ¡buen trabajo!", "detalle": {
        "usuario": token,
        "empresa": user_data.empresa,
        "tipo": "SALIDA",
        "fecha_hora": ahora.strftime("%Y-%m-%d %H:%M:%S")
    }}

@app.get("/ver-mi-historial")
async def historial(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    mis_fichajes = db.query(RegistroHorario).filter(RegistroHorario.usuario == token).all()
    return {"usuario": token, "historial": [
        {
            "usuario": r.usuario,
            "empresa": r.empresa,
            "tipo": r.tipo,
            "fecha_hora": r.fecha_hora.strftime("%Y-%m-%d %H:%M:%S")
        } for r in mis_fichajes
    ]}

# --- SECCIÓN DE REPORTES (EXCEL Y PDF) ---

@app.get("/descargar-excel")
async def descargar_excel(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    mis_datos = db.query(RegistroHorario).filter(RegistroHorario.usuario == token).all()
    
    if not mis_datos:
        raise HTTPException(status_code=404, detail="No hay datos para exportar")
    
    datos_formateados = [{
        "usuario": r.usuario,
        "empresa": r.empresa,
        "tipo": r.tipo,
        "fecha_hora": r.fecha_hora.strftime("%Y-%m-%d %H:%M:%S")
    } for r in mis_datos]
    
    df = pd.DataFrame(datos_formateados)
    archivo_excel = f"reporte_{token}.xlsx"
    df.to_excel(archivo_excel, index=False)
    
    return FileResponse(path=archivo_excel, filename=archivo_excel, media_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')

@app.get("/descargar-pdf")
async def descargar_pdf(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    user_data = db.query(Usuario).filter(Usuario.username == token).first()
    if not user_data:
        raise HTTPException(status_code=401, detail="Usuario no encontrado")
    
    pdf = FPDF()
    pdf.add_page()
    
    # Cabecera del PDF
    pdf.set_font("Arial", "B", 16)
    pdf.cell(0, 10, f"Reporte Horario: {user_data.empresa}", ln=True, align='C')
    pdf.set_font("Arial", size=12)
    pdf.cell(0, 10, f"Empleado: {token}", ln=True, align='C')
    pdf.ln(10)
    
    # Listado de fichajes desde BD
    registros = db.query(RegistroHorario).filter(RegistroHorario.usuario == token).all()
    for r in registros:
        linea = f"{r.fecha_hora.strftime('%Y-%m-%d %H:%M:%S')} --- Accion: {r.tipo}"
        pdf.cell(0, 10, txt=linea, ln=True)
            
    archivo_pdf = f"reporte_{token}.pdf"
    pdf.output(archivo_pdf)
    
    return FileResponse(path=archivo_pdf, filename=archivo_pdf, media_type='application/pdf')

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)