#!/usr/bin/env bash

set -euo pipefail

FLUTTER_DIR="$HOME/development/flutter"
FLUTTER_BIN="$FLUTTER_DIR/bin"
BASHRC="$HOME/.bashrc"
ANDROID_ROOT="$HOME/Android"
ANDROID_SDK_ROOT="$ANDROID_ROOT/Sdk"
ANDROID_CMDLINE_ZIP="$ANDROID_ROOT/cmdline-tools.zip"
ANDROID_CMDLINE_DIR="$ANDROID_SDK_ROOT/cmdline-tools/latest"
JAVA_HOME_DIR="$HOME/development/jdks/jdk-17"

echo "==> Preparando entorno Flutter Web + Android en Linux"

if ! command -v git >/dev/null 2>&1; then
  echo "[ERROR] git no está instalado. Instálalo y vuelve a ejecutar este script."
  exit 1
fi

if ! command -v wget >/dev/null 2>&1; then
  echo "[ERROR] wget no está instalado. Instálalo y vuelve a ejecutar este script."
  exit 1
fi

if ! command -v unzip >/dev/null 2>&1; then
  echo "[ERROR] unzip no está instalado. Instálalo y vuelve a ejecutar este script."
  exit 1
fi

mkdir -p "$HOME/development"

if [ ! -d "$FLUTTER_DIR/.git" ]; then
  echo "==> Clonando Flutter (stable) en $FLUTTER_DIR"
  git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR"
else
  echo "==> Flutter ya existe en $FLUTTER_DIR"
fi

if ! grep -q 'development/flutter/bin' "$BASHRC"; then
  echo "==> Añadiendo Flutter al PATH en $BASHRC"
  {
    echo ""
    echo "# Flutter SDK"
    echo 'export PATH="$PATH:$HOME/development/flutter/bin"'
  } >> "$BASHRC"
else
  echo "==> PATH ya contiene Flutter en $BASHRC"
fi

if ! grep -q 'CHROME_EXECUTABLE=/usr/bin/chromium' "$BASHRC"; then
  if command -v chromium >/dev/null 2>&1; then
    echo "==> Configurando Chromium para Flutter Web"
    {
      echo ""
      echo "# Flutter Web browser"
      echo 'export CHROME_EXECUTABLE=/usr/bin/chromium'
    } >> "$BASHRC"
  else
    echo "[WARN] Chromium no encontrado en /usr/bin/chromium."
    echo "       Instálalo para ejecutar flutter run -d chrome."
  fi
fi

if [ ! -x "$JAVA_HOME_DIR/bin/java" ]; then
  echo "==> Instalando JDK 17 local en $JAVA_HOME_DIR"
  mkdir -p "$HOME/development/jdks"
  cd "$HOME/development/jdks"
  rm -f jdk17.tar.gz
  wget -O jdk17.tar.gz "https://api.adoptium.net/v3/binary/latest/17/ga/linux/x64/jdk/hotspot/normal/eclipse"
  rm -rf "$JAVA_HOME_DIR"
  mkdir -p "$JAVA_HOME_DIR"
  tar -xzf jdk17.tar.gz -C "$JAVA_HOME_DIR" --strip-components=1
fi

if ! grep -q 'JAVA_HOME="$HOME/development/jdks/jdk-17"' "$BASHRC"; then
  {
    echo ""
    echo "# Java for Android SDK"
    echo 'export JAVA_HOME="$HOME/development/jdks/jdk-17"'
    echo 'export PATH="$JAVA_HOME/bin:$PATH"'
  } >> "$BASHRC"
fi

mkdir -p "$ANDROID_CMDLINE_DIR"
if [ ! -x "$ANDROID_CMDLINE_DIR/bin/sdkmanager" ]; then
  echo "==> Instalando Android command-line tools"
  mkdir -p "$ANDROID_ROOT"
  wget -O "$ANDROID_CMDLINE_ZIP" "https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip"
  rm -rf "$ANDROID_CMDLINE_DIR"/*
  unzip -q -o "$ANDROID_CMDLINE_ZIP" -d "$ANDROID_CMDLINE_DIR"
  if [ -d "$ANDROID_CMDLINE_DIR/cmdline-tools/bin" ]; then
    mv "$ANDROID_CMDLINE_DIR/cmdline-tools"/* "$ANDROID_CMDLINE_DIR"/
    rmdir "$ANDROID_CMDLINE_DIR/cmdline-tools" || true
  fi
fi

if ! grep -q 'ANDROID_SDK_ROOT="$HOME/Android/Sdk"' "$BASHRC"; then
  {
    echo ""
    echo "# Android SDK for Flutter"
    echo 'export ANDROID_SDK_ROOT="$HOME/Android/Sdk"'
    echo 'export ANDROID_HOME="$HOME/Android/Sdk"'
    echo 'export PATH="$PATH:$HOME/Android/Sdk/cmdline-tools/latest/bin:$HOME/Android/Sdk/platform-tools"'
  } >> "$BASHRC"
fi

export PATH="$PATH:$FLUTTER_BIN"
export JAVA_HOME="$JAVA_HOME_DIR"
export PATH="$JAVA_HOME/bin:$PATH:$ANDROID_CMDLINE_DIR/bin:$ANDROID_SDK_ROOT/platform-tools"
export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
if command -v chromium >/dev/null 2>&1; then
  export CHROME_EXECUTABLE=/usr/bin/chromium
fi

echo "==> Instalando paquetes Android requeridos por Flutter"
yes | sdkmanager --licenses >/dev/null
sdkmanager "platform-tools" "platforms;android-35" "platforms;android-36" "build-tools;35.0.0" "build-tools;28.0.3" >/dev/null
flutter config --android-sdk "$ANDROID_SDK_ROOT" >/dev/null
flutter config --enable-web --enable-android >/dev/null

if command -v flutter >/dev/null 2>&1; then
  echo "==> Versión de Flutter"
  flutter --version
  echo "==> Ejecutando flutter doctor (resumen)"
  flutter doctor -v | grep -E 'Flutter \(|Android toolchain|Chrome|Connected device|Doctor found|\[✓\]|\[✗\]|\[!\]'
else
  echo "[ERROR] No se pudo ejecutar Flutter tras la instalación."
  exit 1
fi

echo ""
echo "Listo. Abre una nueva terminal o ejecuta: source ~/.bashrc"