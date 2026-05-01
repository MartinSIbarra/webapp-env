FROM alpine:latest

# Declaración de argumentos de construcción con valores por defecto, que pueden ser sobreescritos al construir la imagen o a través de variables de entorno en docker-compose.
# Carpeta de assets (scripts, templates, etc) que se copiarán al contenedor, definida como argumento para flexibilidad
ARG ASSETS_PATH=${ASSETS_PATH}

# Valores para usuario y grupo no-root
ARG USER_UID=${USER_UID:-1000}
ARG USER_GID=${USER_GID:-1000}
ARG USERNAME=${USERNAME:-norootuser}
ARG GROUPNAME=${GROUPNAME:-norootusergroup}

ARG PORT=${PORT:-3000} # Puerto que la app escucha dentro del contenedor, definido como argumento para flexibilidad

# Path de ejecutables con acceso global dentro del contenedor
ARG BIN_PATH="/usr/local/bin"

# Crea el directorio para los scripts personalizados si no existe
RUN mkdir -p ${BIN_PATH}

# Agrega scripts al contenedor
COPY ${ASSETS_PATH}/base-packages.sh \
  ${ASSETS_PATH}/entrypoint.sh \
  ${ASSETS_PATH}/updateapp.sh \
  ${ASSETS_PATH}/runserver.sh \
  ${ASSETS_PATH}/logrotate-schedule.sh \
  ${BIN_PATH}/

# Da permisos de ejecución a los scripts
RUN chmod +x \
  ${BIN_PATH}/base-packages.sh \
  ${BIN_PATH}/entrypoint.sh \
  ${BIN_PATH}/updateapp.sh \
  ${BIN_PATH}/runserver.sh \
  ${BIN_PATH}/logrotate-schedule.sh

# Copia los archivos de configuracion y templates al contenedor
COPY \
  ${ASSETS_PATH}/bashrc.template \
  ${ASSETS_PATH}/logrotate.template \
  /usr/local/templates/

# Prompt personalizado para el usuario no-root
ENV PS1="\\u@\\h:\\w\\$ "

# Dependencias del sistema necesarias para el funcionamiento de la app, los scripts y logrotate.
RUN apk add --no-cache \
  sudo bash curl ca-certificates git openssh logrotate gettext tzdata

# Cambia el shell por defecto a bash para que los scripts funcionen correctamente
SHELL ["/bin/bash", "-lc"]

# Create non-root user and group, and set permissions for the home directory
RUN set -ex \
  && addgroup -g "${USER_GID}" "${GROUPNAME}" \
  && adduser -D -u "${USER_UID}" -G "${GROUPNAME}" -h "/home/${USERNAME}" -s "/bin/bash" "${USERNAME}" \
  && mkdir -p "/home/${USERNAME}/" \
  && chown -R "${USERNAME}:${GROUPNAME}" /home/${USERNAME} \
  && echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN ${BIN_PATH}/base-packages.sh

# Cambia al directorio de trabajo del usuario no-root
WORKDIR "/home/${USERNAME}"

# Cambia al usuario no-root para la ejecución
USER "${USERNAME}"

EXPOSE "${PORT}"

ENTRYPOINT ["entrypoint.sh"]
