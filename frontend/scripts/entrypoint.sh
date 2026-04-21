#!/bin/sh
# Shell entrypoint para el contenedor frontend.
# Usa Bun para instalar dependencias, construir o arrancar el servidor de dev.

set -e  # Salir inmediatamente si cualquier comando devuelve código diferente de 0.

# Puerto en el que Vite/Bun servirá la app dentro del contenedor.
# Se puede parametrizar desde Docker/Compose exportando la variable `PORT`.
# Si no se proporciona, usa 5173 por defecto.
PORT=${PORT:-5173}

# Modo de ejecución: si `MODE` o `NODE_ENV` indican 'production', entramos
# en la rama de producción (build + preview). En otro caso arrancamos el dev server.
# - `MODE`: variable personalizada que puedes usar para controlar comportamiento
#   (p.ej. passed como ARG/ENV desde docker-compose).
# - `NODE_ENV`: convención de Node.js/JS; muchas librerías la usan para optimizar.
if [ "$MODE" = "production" ] || [ "$NODE_ENV" = "production" ]; then
  # Mensaje informativo al log del contenedor
  echo "[entrypoint] production mode: installing deps, building and previewing"

  # Instala solo dependencias necesarias para producción.
  # `--production=true` intenta evitar instalar devDependencies.
  # El `|| true` evita que el script falle si bun falla por alguna razón temporal.
  bun install --production=true || true

  # Ejecuta el script de build definido en package.json (p.ej. vite build)
  bun run build

  # Sirve los archivos construidos en modo 'preview' (útil para poner la app en marcha
  # dentro del contenedor). `--host 0.0.0.0` hace que el servidor acepte conexiones
  # desde fuera del contenedor (necesario para acceder desde el host). `--port` usa `PORT`.
  bun run preview --host 0.0.0.0 --port "$PORT"
else
  echo "[entrypoint] development mode: installing deps and starting dev server"

  # Instala todas las dependencias (incluye devDependencies) para permitir hot-reload
  # y otras herramientas de desarrollo dentro del contenedor.
  bun install || true

  # Arranca el servidor de desarrollo de Vite/Bun, exponiendo host/port adecuados.
  # `--host 0.0.0.0` permite que Vite sea accesible desde el host (y desde otros contenedores si se enlazan).
  bun run dev --host 0.0.0.0 --port "$PORT"
fi

# Variables clave usadas:
# - PORT: puerto interno donde corre la app (por defecto 5173). Mapear este puerto con Docker Compose.
# - MODE: modo lógico personalizado (development|production). Puede usarse también en build-time.
# - NODE_ENV: convención Node.js; muchas dependencias la leen para optimizaciones.

