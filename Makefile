# Makefile para gestionar el entorno docker-compose

HOST_UID ?= $(shell id -u)
HOST_GID ?= $(shell id -g)

.PHONY: up down it rmi ps prepare help

.ONESHELL:

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

# Muestra ayuda rápida
help:
	@echo "Targets: up prepare down ps it rmi help"

# Elimina la imagen 'frontend:latest' construida localmente (no hace prune)
rmi:
	docker image rm frontend:latest || true
