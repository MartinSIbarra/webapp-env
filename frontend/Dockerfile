FROM alpine:latest

ARG USER_UID=${USER_UID:-1000}
ARG USER_GID=${USER_GID:-1000}


ENV PORT=${PORT}
ENV APP_REPO=${APP_REPO}
# Build argument to choose behavior at build time.
ENV MODE=${MODE}
# PATH incluye la instalación de bun en /root/.bun/bin
ENV BIN_PATH="/usr/local/bin"
ENV PATH="/home/frontend/.bun/bin:${BIN_PATH}:$PATH"

# Agrega scripts al contenedor
COPY ./scripts/entrypoint.sh \ 
  ./scripts/updateapp.sh \
  ./scripts/runserver.sh \
  ${BIN_PATH}/

RUN chmod +x \
  ${BIN_PATH}/entrypoint.sh \
  ${BIN_PATH}/updateapp.sh \
  ${BIN_PATH}/runserver.sh

# Dependencias del sistema necesarias para el instalador de Bun y Vite
RUN apk add --no-cache sudo bash curl ca-certificates xz libstdc++ zlib libc6-compat git openssh
SHELL ["/bin/bash", "-lc"]

# Instalar Bun (script oficial)
RUN set -ex \
  && curl -fsSL https://bun.sh/install | bash

  # Create non-root user and move bun installation to their home so it's usable
RUN set -ex \
  && addgroup -g "${USER_GID}" frontendgroup \
  && adduser -D -u "${USER_UID}" -G frontendgroup -h /home/frontend -s /bin/bash frontend \
  && mkdir -p /home/frontend/ \
  && mv /root/.bun /home/frontend \
  && chown -R frontend:frontendgroup /home/frontend \
  && echo "frontend ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY ./scripts/.bashrc /home/frontend

WORKDIR /home/frontend

# Ensure PATH includes non-root bun location

# Copiar manifestos primero para aprovechar cache de Docker
# COPY package.json bun.lockb* ./

# Exponer puerto 
EXPOSE ${PORT}

ENTRYPOINT ["entrypoint.sh"]

# Switch to non-root user for runtime
USER frontend
