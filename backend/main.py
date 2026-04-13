from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime, timedelta, timezone
from sqlalchemy import Column, String, DateTime
from sqlalchemy.orm import Session
from jose import JWTError, jwt
from pydantic import BaseModel
import bcrypt
import pandas as pd
from fpdf import FPDF
import os
from dotenv import load_dotenv

from database import get_db, Base, engine

load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY", "cambia-esta-clave-secreta-en-produccion-min-32-chars")
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "480"))

app = FastAPI(title="Control Horario API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

# --- MODELOS DE BASE DE DATOS ---

class Usuario(Base):
    __tablename__ = "usuarios"
    username = Column(String, primary_key=True)
    password_hash = Column(String)
    empresa = Column(String)

class RegistroHorario(Base):
    __tablename__ = "registros_horarios"
    id = Column(String, primary_key=True, default=lambda: str(datetime.now().timestamp()))
    usuario = Column(String)
    empresa = Column(String)
    tipo = Column(String)  # ENTRADA o SALIDA
    fecha_hora = Column(DateTime, default=datetime.now)

Base.metadata.create_all(bind=engine)

# --- ESQUEMAS PYDANTIC ---

class UsuarioCreate(BaseModel):
    username: str
    password: str
    empresa: str = "Mi Empresa"

# --- FUNCIONES DE SEGURIDAD ---

def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

def verify_password(password: str, hashed: str) -> bool:
    return bcrypt.checkpw(password.encode("utf-8"), hashed.encode("utf-8"))

def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> Usuario:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Token inválido o expirado",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    user = db.query(Usuario).filter(Usuario.username == username).first()
    if user is None:
        raise credentials_exception
    return user

# --- ENDPOINTS ---

@app.get("/")
def home():
    return {"mensaje": "Control Horario API activa", "docs": "/docs"}

@app.post("/register")
def register(data: UsuarioCreate, db: Session = Depends(get_db)):
    existing = db.query(Usuario).filter(Usuario.username == data.username).first()
    if existing:
        raise HTTPException(status_code=400, detail="El usuario ya existe")
    nuevo = Usuario(
        username=data.username,
        password_hash=hash_password(data.password),
        empresa=data.empresa,
    )
    db.add(nuevo)
    db.commit()
    return {"mensaje": f"Usuario '{data.username}' creado correctamente"}

@app.post("/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(Usuario).filter(Usuario.username == form_data.username).first()
    if not user or not verify_password(form_data.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Usuario o contraseña incorrectos")
    token = create_access_token({"sub": user.username})
    return {"access_token": token, "token_type": "bearer"}

@app.get("/me")
def me(current_user: Usuario = Depends(get_current_user)):
    return {
        "username": current_user.username,
        "empresa": current_user.empresa,
    }

# --- SECCIÓN DE FICHAJES ---

@app.post("/fichar-entrada")
def fichar_entrada(current_user: Usuario = Depends(get_current_user), db: Session = Depends(get_db)):
    ahora = datetime.now()
    nuevo_registro = RegistroHorario(
        id=str(ahora.timestamp()),
        usuario=current_user.username,
        empresa=current_user.empresa,
        tipo="ENTRADA",
        fecha_hora=ahora,
    )
    db.add(nuevo_registro)
    db.commit()
    return {"mensaje": "Entrada fichada", "detalle": {
        "usuario": current_user.username,
        "empresa": current_user.empresa,
        "tipo": "ENTRADA",
        "fecha_hora": ahora.strftime("%Y-%m-%d %H:%M:%S"),
    }}

@app.post("/fichar-salida")
def fichar_salida(current_user: Usuario = Depends(get_current_user), db: Session = Depends(get_db)):
    ahora = datetime.now()
    nuevo_registro = RegistroHorario(
        id=str(ahora.timestamp()),
        usuario=current_user.username,
        empresa=current_user.empresa,
        tipo="SALIDA",
        fecha_hora=ahora,
    )
    db.add(nuevo_registro)
    db.commit()
    return {"mensaje": "Salida fichada", "detalle": {
        "usuario": current_user.username,
        "empresa": current_user.empresa,
        "tipo": "SALIDA",
        "fecha_hora": ahora.strftime("%Y-%m-%d %H:%M:%S"),
    }}

@app.get("/ver-mi-historial")
def historial(current_user: Usuario = Depends(get_current_user), db: Session = Depends(get_db)):
    registros = db.query(RegistroHorario).filter(
        RegistroHorario.usuario == current_user.username
    ).order_by(RegistroHorario.fecha_hora.desc()).all()
    return {
        "usuario": current_user.username,
        "historial": [
            {
                "id": r.id,
                "usuario": r.usuario,
                "empresa": r.empresa,
                "tipo": r.tipo,
                "fecha_hora": r.fecha_hora.strftime("%Y-%m-%d %H:%M:%S"),
            }
            for r in registros
        ],
    }

# --- SECCIÓN DE REPORTES (EXCEL Y PDF) ---

@app.get("/descargar-excel")
def descargar_excel(current_user: Usuario = Depends(get_current_user), db: Session = Depends(get_db)):
    datos = db.query(RegistroHorario).filter(RegistroHorario.usuario == current_user.username).all()
    if not datos:
        raise HTTPException(status_code=404, detail="No hay datos para exportar")
    df = pd.DataFrame([{
        "usuario": r.usuario,
        "empresa": r.empresa,
        "tipo": r.tipo,
        "fecha_hora": r.fecha_hora.strftime("%Y-%m-%d %H:%M:%S"),
    } for r in datos])
    archivo = f"reporte_{current_user.username}.xlsx"
    df.to_excel(archivo, index=False)
    return FileResponse(path=archivo, filename=archivo,
                        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")

@app.get("/descargar-pdf")
def descargar_pdf(current_user: Usuario = Depends(get_current_user), db: Session = Depends(get_db)):
    pdf = FPDF()
    pdf.add_page()
    pdf.set_font("Arial", "B", 16)
    pdf.cell(0, 10, f"Reporte Horario: {current_user.empresa}", ln=True, align="C")
    pdf.set_font("Arial", size=12)
    pdf.cell(0, 10, f"Empleado: {current_user.username}", ln=True, align="C")
    pdf.ln(10)
    registros = db.query(RegistroHorario).filter(RegistroHorario.usuario == current_user.username).all()
    for r in registros:
        pdf.cell(0, 10, txt=f"{r.fecha_hora.strftime('%Y-%m-%d %H:%M:%S')} --- {r.tipo}", ln=True)
    archivo = f"reporte_{current_user.username}.pdf"
    pdf.output(archivo)
    return FileResponse(path=archivo, filename=archivo, media_type="application/pdf")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)