#!/bin/sh
# Shell entrypoint para el contenedor frontend.

set -e  # Salir inmediatamente si cualquier comando devuelve código diferente de 0.

# Ejecutar solo si APP_REPO no está vacío
if [ -n "$APP_REPO" ]; then
    export PORT=${PORT:-5173}                     # Puerto en el que Vite/Bun servirá la app (por defecto 5173)
    export MODE=${MODE:-development}              # Indica modo lógico (dev/prod)
	export APP_REPO 
	export REPO_NAME=$(basename "$APP_REPO" .git)
	export APP_PATH="$HOME/app/$REPO_NAME"
    export LOGSIZE=${LOGSIZE:-10M}                # Tamaño máximo de los logs antes de rotar (usado por logrotate)
    export LOGCOUNT=${LOGCOUNT:-5}                # Número de archivos de log a mantener (usado por logrotate)
	export USERNAME=${USERNAME:-frontend}         # Usuario no-root para ejecutar la app y gestionar archivos
	export GROUPNAME=${GROUPNAME:-frontendgroup}  # Grupo para el usuario no-root

    # Asegurar que logrotate corra cada 15 minutos
    sudo mv /etc/periodic/daily/logrotate /usr/local/bin/logrotate 2>/dev/null || true

    # Se crea el archivo de configuración de logrotate a partir del template, reemplazando las variables de entorno.
	envsubst < $HOME/templates/logrotate | tee $HOME/logrotate.conf > /dev/null
	
	# Se crea el archivo de estado para logrotate si no existe
	touch $HOME/logrotate.status

	# Preparar el entorno SSH
	mkdir -p ~/.ssh
	ssh-keyscan github.com >> ~/.ssh/known_hosts

	# Actualiza o clona la app desde el repositorio Git usando SSH.
	source updateapp.sh "$APP_REPO" "$APP_PATH"

	# Arranca el servidor de desarrollo o producción según el modo configurado.
	source runserver.sh "$APP_PATH" "$PORT" "$MODE"

    # Mantiene el contenedor vivo después de que el servidor se detenga (útil para debugging).
    tail -f /dev/null  
fi
