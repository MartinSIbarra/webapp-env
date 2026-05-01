#!/bin/bash

set -e # Salir si ocurre algun error.

# Usa Bun para instalar dependencias, construir o arrancar el servidor
# Se puede parametrizar desde Docker/Compose exportando la variable `PORT`.

APP_PATH=${1:-$APP_PATH}  # Ruta al directorio de la app
PORT=${2:-$PORT}          # Puerto en el que Vite/Bun servirá la app (por defecto 5173)
MODE=${3:-$MODE}          # Indica modo lógico (dev/prod)
NODE_ENV=$MODE            # Convención Node; afecta librerías

cd "$APP_PATH"  # Cambia al directorio de la app (definido en updateapp.sh)

if [ "$MODE" = "production" ]; then
  echo "[runserver] production mode: installing deps, building and previewing"
  # En producción, se construye la app y se sirve con un servidor de producción (Spring Boot).
  ./gradlew clean build -x test

  # Buscamos el archivo JAR más reciente en la carpeta build/libs
  # Excluimos los que terminan en '-plain.jar' que a veces genera Gradle
  JAR_FILE=$(ls -t build/libs/*.jar | grep -v "plain" | head -n 1)

  # Verificamos si encontramos el archivo
  if [ -z "$JAR_FILE" ]; then
      echo "Error: No se encontró ningún archivo .jar en build/libs/"
      echo "Prueba ejecutando: ./gradlew build"
      exit 1
  fi

  # Arranca el servidor de producción de Spring Boot, exponiendo el puerto adecuado.
  java -jar "$JAR_FILE" \ 
    --server.port=$PORT \
    --spring.profiles.active=prod \
    > server.log 2>&1 &

else # $MODE = "development"
  echo "[runserver] development mode: installing deps and starting dev server"

  # Arranca el servidor de desarrollo de Spring Boot, exponiendo el puerto adecuado.
  ./gradlew clean bootRun \
    --refresh-dependencies \
    --args="--server.port=$PORT" \
    > server.log 2>&1 &
fi