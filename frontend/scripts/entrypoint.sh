#!/bin/sh
# Shell entrypoint para el contenedor frontend.

set -e  # Salir inmediatamente si cualquier comando devuelve código diferente de 0.

export PORT=${PORT:-5173}                 # Puerto en el que Vite/Bun servirá la app (por defecto 5173)
export MODE=${MODE:-development}          # Indica modo lógico (dev/prod)
export APP_REPO
export REPO_NAME=$(basename "$APP_REPO" .git)
export APP_PATH="$HOME/app/$REPO_NAME"

# Preparar el entorno SSH
mkdir -p ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts

# Actualiza o clona la app desde el repositorio Git usando SSH.
source updateapp.sh $APP_REPO $APP_PATH

# Arranca el servidor de desarrollo o producción según el modo configurado.
source runserver.sh $APP_PATH $PORT $MODE


tail -f /dev/null  # Mantiene el contenedor vivo después de que el servidor se detenga (útil para debugging).
