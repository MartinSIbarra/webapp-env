SHELL := /bin/bash

# Makefile para gestionar el entorno docker-compose
HOST_UID ?= $(shell id -u)
HOST_GID ?= $(shell id -g)

.PHONY: up down it rmi ps prepare help delapp

.ONESHELL:

# Muestra ayuda rápida
help:
	@echo "Targets: help up prepare down ps it rmi delapp"

# Muestra el estado de los servicios
ps:
	docker compose ps

# Levanta los servicios en background reconstruyendo la imagen
up:
	docker compose up --build -d
	docker compose ps

# Baja los servicios y remueve contenedores creados
down:
	docker compose down

# Reinicia los servicios
restart: down rmi up

# Recarga el servidor
reload: down up

# Abre una shell interactiva en el servicio frontend (usa /bin/bash si está disponible)
it:
	@docker compose exec backend bash || docker compose exec backend sh

# Elimina la imagen 'frontend:latest' construida localmente (no hace prune)
rmi:
	docker image rm frontend:latest || true

# Elimina la carpeta de la aplicación frontend (útil para limpiar el entorno)
delapp:
	rm -rf ./frontend/app
