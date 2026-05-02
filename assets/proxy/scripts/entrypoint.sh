#!/bin/sh
# Shell entrypoint para el contenedor frontend.

set -e  # Salir inmediatamente si cualquier comando devuelve código diferente de 0.

cp -f /usr/local/templates/proxy.conf $HOME/nginx/proxy.conf  # Copia la plantilla de configuración a la ubicación esperada por nginx.

nginx -g "daemon off;" -c $HOME/nginx/proxy.conf -e /tmp/error.log &

# Mantiene el contenedor vivo después de que el servidor se detenga (útil para debugging).
tail -f /dev/null  
