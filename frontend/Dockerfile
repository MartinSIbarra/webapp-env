FROM alpine:latest

# Argumentos para configurar el usuario no-root que se usará en el contenedor.
ARG USER_UID=${USER_UID:-1000}
ARG USER_GID=${USER_GID:-1000}
ARG USERNAME=${USERNAME:-norootuser}
ARG GROUPNAME=${GROUPNAME:-norootusergroup}


# Variables de entorno para configurar el puerto, el repositorio de la app y el modo (desarrollo/producción).
ENV PORT=${PORT:-5173}
# Puede ser 'development' o 'production', y controla el comportamiento del entrypoint.
ENV MODE=${MODE:-development}            
# Se tiene que pasar el path del repositorio para que el entrypoint pueda clonar la app
ENV APP_REPO=${APP_REPO}            
# PATH incluye la instalación de bun en /root/.bun/bin
ENV BIN_PATH="/usr/local/bin"
ENV PATH="/home/${USERNAME}/.bun/bin:${BIN_PATH}:$PATH"

# Agrega scripts al contenedor
COPY ./assets/entrypoint.sh \ 
  ./assets/updateapp.sh \
  ./assets/runserver.sh \
  ${BIN_PATH}/

# Da permisos de ejecución a los scripts
RUN chmod +x \
  ${BIN_PATH}/entrypoint.sh \
  ${BIN_PATH}/updateapp.sh \
  ${BIN_PATH}/runserver.sh

# Dependencias del sistema necesarias para el instalador de Bun y Vite
RUN apk add --no-cache \
  sudo bash curl ca-certificates xz libstdc++ zlib libc6-compat git openssh logrotate gettext

# Cambia el shell por defecto a bash para que los scripts funcionen correctamente
SHELL ["/bin/bash", "-lc"]

# Instalar Bun (script oficial)
RUN set -ex \
  && curl -fsSL https://bun.sh/install | bash

# Create non-root user and move bun installation to their home so it's usable
RUN set -ex \
  && addgroup -g "${USER_GID}" "${GROUPNAME}" \
  && adduser -D -u "${USER_UID}" -G "${GROUPNAME}" -h /home/${USERNAME} -s /bin/bash "${USERNAME}" \
  && mkdir -p /home/${USERNAME}/ \
  && mv /root/.bun /home/${USERNAME} \
  && chown -R "${USERNAME}:${GROUPNAME}" /home/${USERNAME} \
  && echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Cambia al directorio de trabajo del usuario no-root
WORKDIR /home/${USERNAME}

# Cambia al usuario no-root para la ejecución
USER ${USERNAME}

# Copia el archivo de configuración de bash para el usuario no-root
COPY ./assets/.bashrc /home/${USERNAME}/

# Copia el template de logrotate al contenedor
COPY ./assets/logrotate.template ./templates/logrotate

# Exponer puerto 
EXPOSE ${PORT}

ENTRYPOINT ["entrypoint.sh"]
