#!/bin/bash

set -e  # Salir inmediatamente si cualquier comando devuelve código diferente de 0.

REPO_NAME=${1:-$REPO_NAME}
INTERVAL=${2:-$LOGROTATE_INTERVAL}

# Se mueve el script de logrotate a un lugar accesible
sudo mv /etc/periodic/daily/logrotate /usr/local/bin/logrotate 2>/dev/null || true

# Se crea el archivo de configuración de logrotate a partir del template, reemplazando las variables de entorno.
envsubst < /usr/local/templates/logrotate.template | sudo tee /etc/logrotate.d/$REPO_NAME > /dev/null

# Si no se ha proporcionado un intervalo, se establece un valor predeterminado de 60 segundos.
if [ -z "$INTERVAL" ]; then
    INTERVAL=60
fi

#Rota los logs cada $INTERVAL segundos
while true; do
    sudo logrotate -v
    sleep $INTERVAL
done
