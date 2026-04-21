#!/bin/bash
set -e

REPO_NAME=$(basename "$APP_REPO" .git)

# 1. Actualizar la información del remoto silenciosamente
git fetch origin main &> /dev/null

# 2. Obtener el hash del último commit local
LOCAL=$(git rev-parse HEAD)

# 3. Obtener el hash del último commit en el remoto
REMOTE=$(git rev-parse origin/main)

# 4. Comparar los hashes
if [ "$LOCAL" != "$REMOTE" ]; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi