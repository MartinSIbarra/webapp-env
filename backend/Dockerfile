FROM alpine:latest

# Argumentos para configurar el usuario no-root que se usará en el contenedor.

# Puede ser 'development' o 'production', y controla el comportamiento del entrypoint.
ARG MODE=${MODE:-development} 

# Puerto que la app escucha dentro del contenedor.
ARG PORT=${PORT:-5000}

# Valores para usuario y grupo no-root
ARG USER_UID=${USER_UID:-1000}
ARG USER_GID=${USER_GID:-1000}
ARG USERNAME=${USERNAME:-norootuser}
ARG GROUPNAME=${GROUPNAME:-norootusergroup}

# Cantidad de segundos entre cada ejecución de logrotate
ARG LOGROTATE_INTERVAL=${LOGROTATE_INTERVAL:-60}

# Path de ejecutables con acceso global dentro del contenedor
ARG BIN_PATH="/usr/local/bin"

# Crea el directorio para los scripts personalizados si no existe
RUN mkdir -p ${BIN_PATH}

# Agrega scripts al contenedor
COPY ./assets/entrypoint.sh \ 
  ./assets/updateapp.sh \
  ./assets/runserver.sh \
  ./assets/logrotate-schedule.sh \
  ${BIN_PATH}/

# Da permisos de ejecución a los scripts
RUN chmod +x \
  ${BIN_PATH}/entrypoint.sh \
  ${BIN_PATH}/updateapp.sh \
  ${BIN_PATH}/runserver.sh \
  ${BIN_PATH}/logrotate-schedule.sh

# Copia los archivos de configuracion y templates al contenedor
COPY \
  ./assets/bashrc.template \
  ./assets/logrotate.template \
  /usr/local/templates/

# Se pasan los argumentos como variables de entorno para que estén disponibles en tiempo de ejecución, especialmente para el entrypoint y los scripts.
ENV USERNAME="${USERNAME}"
ENV GROUPNAME="${GROUPNAME}"
ENV LOGROTATE_INTERVAL="${LOGROTATE_INTERVAL}"
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk
ENV PATH="${BIN_PATH}:${JAVA_HOME}/bin:$PATH"
# Prompt personalizado para el usuario no-root
ENV PS1="\\u@\\h:\\w\\$ "

# Dependencias del sistema necesarias para el funcionamiento de la app, los scripts y logrotate.
RUN apk add --no-cache \
  sudo bash curl ca-certificates git openssh logrotate gettext tzdata openjdk21

# Cambia el shell por defecto a bash para que los scripts funcionen correctamente
SHELL ["/bin/bash", "-lc"]

# Create non-root user and group, and set permissions for the home directory
RUN set -ex \
  && addgroup -g "${USER_GID}" "${GROUPNAME}" \
  && adduser -D -u "${USER_UID}" -G "${GROUPNAME}" -h "/home/${USERNAME}" -s "/bin/bash" "${USERNAME}" \
  && mkdir -p "/home/${USERNAME}/" \
  && chown -R "${USERNAME}:${GROUPNAME}" /home/${USERNAME} \
  && echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Cambia al directorio de trabajo del usuario no-root
WORKDIR "/home/${USERNAME}"

# Cambia al usuario no-root para la ejecución
USER "${USERNAME}"

EXPOSE "${PORT}"

ENTRYPOINT ["entrypoint.sh"]
