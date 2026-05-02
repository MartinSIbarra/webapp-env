#!/bin/sh
# Shell entrypoint para el contenedor frontend.

set -e  # Salir inmediatamente si cualquier comando devuelve código diferente de 0.

# Crea el archivo .bashrc a partir del template, reemplazando las variables de entorno.
envsubst < /usr/local/templates/bashrc.template | tee $HOME/.bashrc > /dev/null

# Preparar el entorno SSH
mkdir -p ~/.ssh

if ! grep -q "github.com" ~/.ssh/known_hosts 2>/dev/null; then
    ssh-keyscan github.com >> ~/.ssh/known_hosts
fi

if [ -z "$APP_REPO" ]; then
	echo "No se ha proporcionado APP_REPO. El contenedor se mantendrá inactivo. Proporcione la URL del repositorio Git de la app a través de la variable de entorno APP_REPO para que el contenedor clone o actualice el código y ejecute la aplicación."
	tail -f /dev/null  
	exit 0
fi

# Ejecutar solo si APP_REPO no está vacío
if [ -z "$MODE" ]; then
	echo "No se ha proporcionado MODE, los valores posibles son 'development' o 'production'."
	tail -f /dev/null  
	exit 0
fi

if [ -z "$PORT" ]; then
	echo "No se ha proporcionado PORT."
	tail -f /dev/null  
	exit 0
fi

# Agrega variables de entorno adicionales al .bashrc para que estén disponibles en las sesiones interactivas.
tee -a $HOME/.bashrc <<EOF
# Variables de entorno para la app
export REPO_NAME=$(basename "$APP_REPO" .git) # Nombre del repositorio sin la extensión .git, usado para nombrar carpetas y logs
export APP_PATH="$HOME/app/$(basename "$APP_REPO" .git)"
                                              # Ruta donde se clonará o actualizará la app dentro del contenedor

EOF

# Carga el .bashrc para que las variables de entorno estén disponibles en este script.
source $HOME/.bashrc  

# Inicia el proceso de logrotate en segundo plano para gestionar los logs de la aplicación.
logrotate-schedule.sh "$REPO_NAME" "$LOGROTATE_INTERVAL" &

# Actualiza o clona la app desde el repositorio Git usando SSH.
updateapp.sh "$APP_REPO" "$APP_PATH"

# Arranca el servidor de desarrollo o producción según el modo configurado.
runserver.sh "$APP_PATH" "$PORT" "$MODE" &

# Mantiene el contenedor vivo después de que el servidor se detenga (útil para debugging).
tail -f /dev/null  
