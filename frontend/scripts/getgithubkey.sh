#!/bin/bash

# 1. Preparar el entorno SSH
mkdir -p ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts

# 2. Iniciar el agente SSH y cargar la llave desde el secret de Docker
# (Asumiendo que el secret se llama 'github_key')
eval $(ssh-agent -s)
ssh-add /run/secrets/github_key