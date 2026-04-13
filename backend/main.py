from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from fastapi.responses import FileResponse
from datetime import datetime, timedelta, timezone
from sqlalchemy import Column, String, DateTime
from sqlalchemy.orm import Session
from pydantic import BaseModel
import pandas as pd
from fpdf import FPDF
import os
import re
import tempfile
from dotenv import load_dotenv
from passlib.context import CryptContext
from jose import JWTError, jwt

from database import get_db, Base, engine

load_dotenv()

app = FastAPI()

# --- CONFIGURACIÓN JWT Y BCRYPT ---
SECRET_KEY = os.getenv("SECRET_KEY")
if not SECRET_KEY:
    raise RuntimeError(
        "SECRET_KEY no está configurado. "
        "Crea un archivo .env con SECRET_KEY=<valor aleatorio seguro>."
    )
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "10080"))

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=JWT_ALGORITHM)


def _safe_filename(username: str) -> str:
    """Devuelve un nombre de archivo seguro basado en el username."""
    return re.sub(r"[^\w\-]", "_", username)[:64]


def get_current_username(token: str = Depends(oauth2_scheme)) -> str:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No se pudo validar las credenciales",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[JWT_ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        return username
    except JWTError:
        raise credentials_exception


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

# Crear las tablas en la base de datos
Base.metadata.create_all(bind=engine)


# --- SCHEMAS PYDANTIC ---

class RegisterRequest(BaseModel):
    username: str
    password: str
    empresa: str


# --- RUTAS ---

@app.get("/")
def home():
    return {"mensaje": "Entorno de DESARROLLO - App Control Horario activa"}

@app.post("/register")
async def register(data: RegisterRequest, db: Session = Depends(get_db)):
    existing = db.query(Usuario).filter(Usuario.username == data.username).first()
    if existing:
        raise HTTPException(status_code=400, detail="El usuario ya existe")
    nuevo_usuario = Usuario(
        username=data.username,
        password=hash_password(data.password),
        empresa=data.empresa,
    )
    db.add(nuevo_usuario)
    db.commit()
    return {"mensaje": "Usuario creado correctamente", "username": data.username}

@app.post("/login")
async def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(Usuario).filter(Usuario.username == form_data.username).first()
    if not user or not verify_password(form_data.password, user.password):
        raise HTTPException(status_code=401, detail="Error de acceso")
    access_token = create_access_token({"sub": user.username})
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/me")
async def get_me(username: str = Depends(get_current_username), db: Session = Depends(get_db)):
    user = db.query(Usuario).filter(Usuario.username == username).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return {"username": user.username, "empresa": user.empresa}

# --- SECCIÓN DE FICHAJES ---

@app.post("/fichar-entrada")
async def fichar_entrada(username: str = Depends(get_current_username), db: Session = Depends(get_db)):
    ahora = datetime.now()
    user_data = db.query(Usuario).filter(Usuario.username == username).first()
    
    if not user_data:
        raise HTTPException(status_code=401, detail="Usuario no encontrado")
    
    nuevo_registro = RegistroHorario(
        usuario=username,
        empresa=user_data.empresa,
        tipo="ENTRADA",
        fecha_hora=ahora
    )
    db.add(nuevo_registro)
    db.commit()
    db.refresh(nuevo_registro)
    
    return {"mensaje": "Entrada fichada, ¡a darle!", "detalle": {
        "usuario": username,
        "empresa": user_data.empresa,
        "tipo": "ENTRADA",
        "fecha_hora": ahora.strftime("%Y-%m-%d %H:%M:%S")
    }}

@app.post("/fichar-salida")
async def fichar_salida(username: str = Depends(get_current_username), db: Session = Depends(get_db)):
    ahora = datetime.now()
    user_data = db.query(Usuario).filter(Usuario.username == username).first()
    
    if not user_data:
        raise HTTPException(status_code=401, detail="Usuario no encontrado")
    
    nuevo_registro = RegistroHorario(
        usuario=username,
        empresa=user_data.empresa,
        tipo="SALIDA",
        fecha_hora=ahora
    )
    db.add(nuevo_registro)
    db.commit()
    db.refresh(nuevo_registro)
    
    return {"mensaje": "Salida fichada, ¡buen trabajo!", "detalle": {
        "usuario": username,
        "empresa": user_data.empresa,
        "tipo": "SALIDA",
        "fecha_hora": ahora.strftime("%Y-%m-%d %H:%M:%S")
    }}

@app.get("/ver-mi-historial")
async def historial(username: str = Depends(get_current_username), db: Session = Depends(get_db)):
    mis_fichajes = db.query(RegistroHorario).filter(RegistroHorario.usuario == username).all()
    return {"usuario": username, "historial": [
        {
            "usuario": r.usuario,
            "empresa": r.empresa,
            "tipo": r.tipo,
            "fecha_hora": r.fecha_hora.strftime("%Y-%m-%d %H:%M:%S")
        } for r in mis_fichajes
    ]}

# --- SECCIÓN DE REPORTES (EXCEL Y PDF) ---

@app.get("/descargar-excel")
async def descargar_excel(username: str = Depends(get_current_username), db: Session = Depends(get_db)):
    mis_datos = db.query(RegistroHorario).filter(RegistroHorario.usuario == username).all()
    
    if not mis_datos:
        raise HTTPException(status_code=404, detail="No hay datos para exportar")
    
    datos_formateados = [{
        "usuario": r.usuario,
        "empresa": r.empresa,
        "tipo": r.tipo,
        "fecha_hora": r.fecha_hora.strftime("%Y-%m-%d %H:%M:%S")
    } for r in mis_datos]
    
    df = pd.DataFrame(datos_formateados)
    safe_name = _safe_filename(username)
    with tempfile.NamedTemporaryFile(suffix=".xlsx", delete=False) as tmp:
        archivo_excel = tmp.name
    df.to_excel(archivo_excel, index=False)
    
    return FileResponse(
        path=archivo_excel,
        filename=f"reporte_{safe_name}.xlsx",
        media_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    )

@app.get("/descargar-pdf")
async def descargar_pdf(username: str = Depends(get_current_username), db: Session = Depends(get_db)):
    user_data = db.query(Usuario).filter(Usuario.username == username).first()
    if not user_data:
        raise HTTPException(status_code=401, detail="Usuario no encontrado")
    
    pdf = FPDF()
    pdf.add_page()
    
    # Cabecera del PDF
    pdf.set_font("Arial", "B", 16)
    pdf.cell(0, 10, f"Reporte Horario: {user_data.empresa}", ln=True, align='C')
    pdf.set_font("Arial", size=12)
    pdf.cell(0, 10, f"Empleado: {username}", ln=True, align='C')
    pdf.ln(10)
    
    # Listado de fichajes desde BD
    registros = db.query(RegistroHorario).filter(RegistroHorario.usuario == username).all()
    for r in registros:
        linea = f"{r.fecha_hora.strftime('%Y-%m-%d %H:%M:%S')} --- Accion: {r.tipo}"
        pdf.cell(0, 10, txt=linea, ln=True)
            
    safe_name = _safe_filename(username)
    with tempfile.NamedTemporaryFile(suffix=".pdf", delete=False) as tmp:
        archivo_pdf = tmp.name
    pdf.output(archivo_pdf)
    
    return FileResponse(
        path=archivo_pdf,
        filename=f"reporte_{safe_name}.pdf",
        media_type='application/pdf',
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)