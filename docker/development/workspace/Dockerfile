# docker/development/workspace/Dockerfile
FROM php:8.4-cli

# --------------------------------------------------
# Build arguments
# --------------------------------------------------
ARG UID=1000
ARG GID=1000
ARG NODE_VERSION=22.9.0

ARG XDEBUG_ENABLED=true
ARG XDEBUG_MODE=develop,coverage,debug,profile
ARG XDEBUG_HOST=host.docker.internal
ARG XDEBUG_IDE_KEY=DOCKER
ARG XDEBUG_LOG=/dev/stdout
ARG XDEBUG_LOG_LEVEL=0

# --------------------------------------------------
# System dependencies
# --------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    git \
    sudo \
    libpq-dev \
    libonig-dev \
    libssl-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libicu-dev \
    libzip-dev \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        opcache \
        intl \
        zip \
        bcmath \
        soap \
    && pecl install redis xdebug \
    && docker-php-ext-enable redis \
    && curl -sS https://getcomposer.org/installer | php \
        -- --install-dir=/usr/local/bin --filename=composer \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# --------------------------------------------------
# Xdebug configuration (CLI)
# --------------------------------------------------
RUN if [ "${XDEBUG_ENABLED}" = "true" ]; then \
        docker-php-ext-enable xdebug && \
        echo "xdebug.mode=${XDEBUG_MODE}" > /usr/local/etc/php/conf.d/99-xdebug.ini && \
        echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/99-xdebug.ini && \
        echo "xdebug.client_host=${XDEBUG_HOST}" >> /usr/local/etc/php/conf.d/99-xdebug.ini && \
        echo "xdebug.idekey=${XDEBUG_IDE_KEY}" >> /usr/local/etc/php/conf.d/99-xdebug.ini && \
        echo "xdebug.log=${XDEBUG_LOG}" >> /usr/local/etc/php/conf.d/99-xdebug.ini && \
        echo "xdebug.log_level=${XDEBUG_LOG_LEVEL}" >> /usr/local/etc/php/conf.d/99-xdebug.ini ; \
    else \
        rm -f /usr/local/etc/php/conf.d/*xdebug*.ini ; \
    fi

# --------------------------------------------------
# Create user & group safely
# --------------------------------------------------
RUN if ! getent group ${GID} >/dev/null; then \
        groupadd -g ${GID} www; \
    fi && \
    if ! id -u ${UID} >/dev/null 2>&1; then \
        useradd -m -u ${UID} -g ${GID} -s /bin/bash www; \
    fi && \
    usermod -aG sudo www && \
    echo "www ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/www && \
    chmod 0440 /etc/sudoers.d/www

# --------------------------------------------------
# Switch to non-root user
# --------------------------------------------------
USER www

# --------------------------------------------------
# Install NVM + Node.js
# --------------------------------------------------
RUN export NVM_DIR="$HOME/.nvm" && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install ${NODE_VERSION} && \
    nvm alias default ${NODE_VERSION}

# Persist NVM for future shells
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"' >> ~/.bashrc

# --------------------------------------------------
# Workdir
# --------------------------------------------------
WORKDIR /var/www

# Disable default php entrypoint
ENTRYPOINT []

CMD ["bash"]
