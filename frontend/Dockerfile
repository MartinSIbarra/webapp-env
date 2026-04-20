FROM alpine:latest

# Build argument to choose behavior at build time. Default: development
# ARG MODE=development
# ENV MODE=${MODE}

# PATH incluye la instalación de bun en /root/.bun/bin
ENV PATH="/root/.bun/bin:/usr/local/bin:$PATH"
ENV PORT=5173

# Dependencias del sistema necesarias para el instalador de Bun y Vite
RUN apk add --no-cache sudo bash curl ca-certificates xz libstdc++ zlib libc6-compat
SHELL ["/bin/bash", "-lc"]

# Instalar Bun (script oficial)
RUN set -ex \
  && curl -fsSL https://bun.sh/install | bash

# Create non-root user and move bun installation to their home so it's usable
RUN set -ex \
  && addgroup -g 1000 frontendgroup \
  && adduser -D -u 1000 -G frontendgroup -h /home/frontend -s /bin/bash frontend \
  && mkdir -p /home/frontend/ \
  && mv /root/.bun /home/frontend \  
  && chown -R frontend:frontendgroup /home/frontend \
  && echo "frontend ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


WORKDIR /home/frontend

# Ensure PATH includes non-root bun location
ENV PATH="/home/frontend/.bun/bin:/usr/local/bin:$PATH"

# Copiar manifestos primero para aprovechar cache de Docker
# COPY package.json bun.lockb* ./

# Copiar entrypoint y darle permisos
# COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
# RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Exponer puerto (valor por defecto 5173, puede ser sobrescrito con ENV)
EXPOSE ${PORT}

ENTRYPOINT ["tail", "-f", "/dev/null"]

# Switch to non-root user for runtime
USER frontend
