#!/bin/bash
set -e # Salir si ocurre algun error.

# Iniciar el agente SSH y cargar la llave desde el secret de Docker
eval $(ssh-agent -s)
ssh-add /run/secrets/github_key
APP_REPO=${1:-$APP_REPO}
APP_PATH=${2:-$APP_PATH}

# Verificar si el directorio de la app existe
if [ ! -d "$APP_PATH" ]; then
    echo "Clonando el repositorio por primera vez..."
    git clone "$APP_REPO" "$APP_PATH"
else
    echo "El repositorio ya existe. Verificando actualizaciones..."
    cd "$APP_PATH"
    # 1. Actualizar la información del remoto silenciosamente
    git fetch origin main &> /dev/null

    # 2. Obtener el hash del último commit local de la rama activa
    LOCAL=$(git rev-parse HEAD)

    # 3. Obtener el hash del último commit en el remoto relacionada a la rama activa
    REMOTE=$(git rev-parse @{u})

    # 4. Comparar los hashes
    if [ "$LOCAL" != "$REMOTE" ]; then
        echo "Actualizaciones encontradas. Haciendo pull..."
        git pull origin main
    else
        echo "El repositorio ya está actualizado."
    fi
fi
