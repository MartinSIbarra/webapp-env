#!/bin/bash

set -e

# Instalar Bun (script oficial)
curl -fsSL https://bun.sh/install | bash

# Mueve la instalación de Bun al directorio del usuario no-root para que sea utilizable
mv /root/.bun "/home/${USERNAME}" 

# Asigna permisos al directorio del usuario no-root
chown -R "${USERNAME}:${GROUPNAME}" /home/${USERNAME}
