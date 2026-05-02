SHELL := /bin/bash

.PHONY: up down proxy frontend backend rmi ps help delapp

.ONESHELL:

# Muestra ayuda rápida
help:
	@echo "Targets: help up down ps proxy frontend backend rmi delapp"

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

# Abre una shell interactiva en el servicio backend (usa /bin/bash si está disponible)
proxy:
	@docker compose exec proxy bash || docker compose exec proxy sh

# Abre una shell interactiva en el servicio backend (usa /bin/bash si está disponible)
backend:
	@docker compose exec backend bash || docker compose exec backend sh

# Abre una shell interactiva en el servicio frontend (usa /bin/bash si está disponible)
frontend:
	@docker compose exec frontend bash || docker compose exec frontend sh

# Elimina la imagen 'frontend:latest' construida localmente (no hace prune)
rmi:
	docker image rm proxy:latest || true
	docker image rm frontend:latest || true
	docker image rm backend:latest || true

# Elimina la carpeta de la aplicación frontend (útil para limpiar el entorno)
delapp:
	rm -rf ./frontend/app ./backend/app
