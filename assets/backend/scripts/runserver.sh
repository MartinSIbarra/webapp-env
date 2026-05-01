#!/bin/bash

set -e # Salir si ocurre algun error.

# Usa Bun para instalar dependencias, construir o arrancar el servidor
# Se puede parametrizar desde Docker/Compose exportando la variable `PORT`.

APP_PATH=${1:-$APP_PATH}  # Ruta al directorio de la app
PORT=${2:-$PORT}          # Puerto en el que Vite/Bun servirá la app (por defecto 5173)
MODE=${3:-$MODE}          # Indica modo lógico (dev/prod)
NODE_ENV=$MODE            # Convención Node; afecta librerías

cd "$APP_PATH"  # Cambia al directorio de la app (definido en updateapp.sh)

echo "Iniciando servidor en modo $MODE en el puerto $PORT..."
echo "script incompleto...."