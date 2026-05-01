FROM alpine:latest

# Carpetas de assets comunes 
ARG COMMON_ASSETS_PATH=${COMMON_ASSETS_PATH}
# Carpetas de assets particulares 
ARG ASSETS_PATH=${ASSETS_PATH}

# Valores para usuario y grupo no-root
ARG USER_UID=${USER_UID:-1000}
ARG USER_GID=${USER_GID:-1000}
ARG USERNAME=${USERNAME:-norootuser}
ARG GROUPNAME=${GROUPNAME:-norootusergroup}

# Puerto que la app escucha dentro del contenedor, definido como argumento para flexibilidad
ARG PORT=${PORT:-3000} 

# Path de ejecutables con acceso global dentro del contenedor
ARG BIN_PATH="/usr/local/bin"

# Path para templates y archivos de configuración dentro del contenedor
ARG TEMPLATES_PATH="/usr/local/templates/"

# Crea el directorio para los scripts personalizados si no existe
RUN mkdir -p ${BIN_PATH}

# Agrega scripts comunes al contenedor
COPY ${COMMON_ASSETS_PATH}/scripts/ ${BIN_PATH}/
# Agrega scripts particulares al contenedor
COPY ${ASSETS_PATH}/scripts/ ${BIN_PATH}/
# Da permisos de ejecución a los scripts
RUN chmod +x ${BIN_PATH}/*

# Copia los archivos comunes de configuracion y templates al contenedor
COPY ${COMMON_ASSETS_PATH}/templates/ ${TEMPLATES_PATH}/
# Copia los archivos particulares de configuracion y templates al contenedor
COPY ${ASSETS_PATH}/templates/ ${TEMPLATES_PATH}/

# Dependencias del sistema necesarias para el funcionamiento de la app, los scripts y logrotate.
RUN apk add --no-cache \
  sudo bash curl ca-certificates git openssh logrotate gettext tzdata zlib xz

# Cambia el shell por defecto a bash para que los scripts funcionen correctamente
SHELL ["/bin/bash", "-lc"]

# Create non-root user and group, and set permissions for the home directory
RUN set -ex \
  && addgroup -g "${USER_GID}" "${GROUPNAME}" \
  && adduser -D -u "${USER_UID}" -G "${GROUPNAME}" -h "/home/${USERNAME}" -s "/bin/bash" "${USERNAME}" \
  && mkdir -p "/home/${USERNAME}/" \
  && chown -R "${USERNAME}:${GROUPNAME}" /home/${USERNAME} \
  && echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Se pasan los argumentos como variables de entorno para que estén disponibles en tiempo de ejecución, especialmente para el entrypoint y los scripts.
ENV USERNAME="${USERNAME}"
ENV GROUPNAME="${GROUPNAME}"

# Ejecuta el script de instalación de paquetes base, que puede ser utilizado para instalar dependencias comunes tanto en el frontend como en el backend, manteniendo así la DRY principle y facilitando el mantenimiento.
RUN ${BIN_PATH}/base-packages.sh

# Cambia al directorio de trabajo del usuario no-root
WORKDIR "/home/${USERNAME}"

# Cambia al usuario no-root para la ejecución
USER "${USERNAME}"

EXPOSE "${PORT}"

ENTRYPOINT ["entrypoint.sh"]
