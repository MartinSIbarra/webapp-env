#!/bin/sh
# Shell entrypoint para el contenedor frontend.

set -e  # Salir inmediatamente si cualquier comando devuelve código diferente de 0.

if [ -z "$APP_REPO" ]; then
	echo "No se ha proporcionado APP_REPO. El contenedor se mantendrá inactivo. Proporcione la URL del repositorio Git de la app a través de la variable de entorno APP_REPO para que el contenedor clone o actualice el código y ejecute la aplicación."
	exit 0
fi

# Ejecutar solo si APP_REPO no está vacío
if [ -z "$MODE" ]; then
	echo "No se ha proporcionado MODE. Usando 'development' por defecto."
	MODE="development"
fi

if [ -z "$PORT" ]; then
	echo "No se ha proporcionado PORT. Usando 5173 por defecto."
	PORT=5173
fi

export APP_REPO                               # URL del repositorio Git de la app, usado por updateapp.sh para clonar o actualizar el código
export PORT                     	          # Puerto en el que Vite/Bun servirá la app (por defecto 5173)
export MODE                                   # Indica modo lógico (dev/prod)
export USERNAME                               # Usuario no-root para ejecutar la app y gestionar archivos
export GROUPNAME                              # Grupo para el usuario no-root
export REPO_NAME=$(basename "$APP_REPO" .git) # Nombre del repositorio sin la extensión .git, usado para nombrar carpetas y logs
export APP_PATH="$HOME/app/$REPO_NAME"        # Ruta donde se clonará o actualizará la app dentro del contenedor
export LOGSIZE=${LOGSIZE:-10M}                # Tamaño máximo de los logs antes de rotar (usado por logrotate)
export LOGCOUNT=${LOGCOUNT:-5}                # Número de archivos de log a mantener (usado por logrotate)
export LOGROTATE_INTERVAL=${LOGROTATE_INTERVAL:-60} 
											  # Intervalo en segundos para ejecutar logrotate (usado por el script de scheduling)

# Crea el archivo .bashrc a partir del template, reemplazando las variables de entorno.
envsubst < /usr/local/templates/bashrc.template | tee $HOME/.bashrc > /dev/null

# Inicia el proceso de logrotate en segundo plano para gestionar los logs de la aplicación.
source logrotate-schedule.sh "$REPO_NAME" "$LOGROTATE_INTERVAL" &

# Preparar el entorno SSH
mkdir -p ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts

# Actualiza o clona la app desde el repositorio Git usando SSH.
source updateapp.sh "$APP_REPO" "$APP_PATH"

# Arranca el servidor de desarrollo o producción según el modo configurado.
source runserver.sh "$APP_PATH" "$PORT" "$MODE"

# Mantiene el contenedor vivo después de que el servidor se detenga (útil para debugging).
tail -f /dev/null  
