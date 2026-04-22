# Makefile para gestionar el entorno docker-compose

HOST_UID ?= $(shell id -u)
HOST_GID ?= $(shell id -g)

.PHONY: up down it rmi ps prepare help delapp

.ONESHELL:

# Muestra ayuda rápida
help:
	@echo "Targets: help up prepare down ps it rmi delapp"


# exporta las variables para desarrollo
exdev:
	export FRONTEND_PORT=5173
	export FRONTEND_HPORT=5173
	export MODE=development

# exporta las variables para producción
exprod:
	export FRONTEND_PORT=5173
	export FRONTEND_HPORT=5173
	export MODE=production

# Muestra el estado de los servicios
ps:
	docker compose ps

# Prepara la carpeta del host para el bind-mount
prepare:
	mkdir -p ./frontend/app
	chown $(HOST_UID):$(HOST_GID) ./frontend/app

# Levanta los servicios en background reconstruyendo la imagen
up: prepare
	docker compose up --build -d
	docker compose ps

# Baja los servicios y remueve contenedores creados
down:
	docker compose down

# Abre una shell interactiva en el servicio frontend (usa /bin/bash si está disponible)
it:
	@docker compose exec frontend bash || docker compose exec frontend sh

# Elimina la imagen 'frontend:latest' construida localmente (no hace prune)
rmi:
	docker image rm frontend:latest || true

# Elimina la carpeta de la aplicación frontend (útil para limpiar el entorno)
delapp:
	rm -rf ./frontend/app
