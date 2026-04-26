#!/bin/bash

# Usa Bun para instalar dependencias, construir o arrancar el servidor
# Se puede parametrizar desde Docker/Compose exportando la variable `PORT`.

APP_PATH=${1:-$APP_PATH}  # Ruta al directorio de la app
PORT=${2:-$PORT}          # Puerto en el que Vite/Bun servirá la app (por defecto 5173)
MODE=${3:-$MODE}          # Indica modo lógico (dev/prod)
NODE_ENV=$MODE            # Convención Node; afecta librerías

cd "$APP_PATH"  # Cambia al directorio de la app (definido en updateapp.sh)

if [ "$MODE" = "production" ]; then
  # Mensaje informativo al log del contenedor
  echo "[entrypoint] production mode: installing deps, building and previewing"

  # Instala solo dependencias necesarias para producción.
  bun install --production    # intenta evitar instalar devDependencies.

  # Ejecuta el script de build definido en package.json (p.ej. vite build)
  bun run build

  # Sirve los archivos construidos en modo 'preview' (útil para poner la app en marcha
  # dentro del contenedor). `--host 0.0.0.0` hace que el servidor acepte conexiones
  # desde fuera del contenedor (necesario para acceder desde el host). `--port` usa `PORT`.
  exec bun x serve dist -p "$PORT" 2>&1 | tee -a "$APP_PATH/server.log"
else # $MODE = "development"
  echo "[entrypoint] development mode: installing deps and starting dev server"

  # Instala todas las dependencias (incluye devDependencies) para permitir hot-reload
  # y otras herramientas de desarrollo dentro del contenedor.
  bun install 

  # Arranca el servidor de desarrollo de Vite/Bun, exponiendo host/port adecuados.
  # `--host 0.0.0.0` permite que Vite sea accesible desde el host (y desde otros contenedores si se enlazan).
  export DEBUG='vite:*,app:*'
  exec bun run dev --host 0.0.0.0 --port "$PORT" 2>&1 | tee -a "$APP_PATH/server.log"
   
fi

# Variables clave usadas:
# - PORT: puerto interno donde corre la app (por defecto 5173). Mapear este puerto con Docker Compose.
# - MODE: modo lógico personalizado (development|production). Puede usarse también en build-time.
# - NODE_ENV: convención Node.js; muchas dependencias la leen para optimizaciones.