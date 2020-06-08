FROM php:7.3-fpm-stretch

MAINTAINER "Hector Rojas"

ARG DEBIAN_FRONTEND=noninteractive

ENV PHP_EXTRA_CONFIGURE_ARGS="--enable-fpm --with-fpm-user=phpdevbox --with-fpm-group=phpdevbox"

ENV APP_ROOT /app
ENV PHP_MEMORY_LIMIT 2G
ENV MAX_EXECUTION_TIME 18000
ENV UPLOAD_MAX_FILESIZE 64M
ENV POST_MAX_SIZE 64M
ENV GC_MAXLIFETIME 7200
ENV LOG_ERRORS 1
ENV PHP_EXTENSIONS bcmath bz2 calendar exif gd gettext intl mysqli opcache pdo_mysql redis soap sockets sysvmsg sysvsem sysvshm xsl zip pcntl

# Dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    apt-utils \
    sudo \
    nano \
    vim \
    wget \
    zip \
    unzip \
    bzip2 \
    cron \
    git \
    apache2 \
    sendmail-bin \
    sendmail \
    mariadb-client \
    default-mysql-client \
    libbz2-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libfreetype6-dev \
    libgeoip-dev \
    libgmp-dev \
    libmagickwand-dev \
    libmagickcore-dev \
    libc-client-dev \
    libkrb5-dev \
    libicu-dev \
    libldap2-dev \
    libpspell-dev \
    librecode0 \
    librecode-dev \
    libtidy-dev \
    libxslt1-dev \
    libyaml-dev \
    libzip-dev \
    libmcrypt-dev \
    libxml2-dev \
    iputils-ping
RUN rm -rf /var/lib/apt/lists/*

# Configure gd
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu
RUN docker-php-ext-configure opcache --enable-opcache
RUN docker-php-ext-configure zip --with-libzip
RUN docker-php-ext-configure hash --with-mhash

# PHP extensions
RUN docker-php-ext-install -j$(nproc) \
    bcmath \
    bz2 \
    calendar \
    exif \
    gd \
    gettext \
    gmp \
    iconv \
    imap \
    intl \
    json \
    ldap \
    mysqli \
    mbstring \
    opcache \
    pcntl \
    pdo \
    pdo_mysql \
    pspell \
    recode \
    shmop \
    simplexml \
    soap \
    sockets \
    sysvmsg \
    sysvsem \
    sysvshm \
    tidy \
    xml \
    xmlrpc \
    xsl \
    zip

RUN pecl install -o -f geoip-1.1.1 \
    igbinary \
    imagick \
    mailparse \
    msgpack \
    oauth \
    propro \
    raphf \
    redis \
    xdebug-2.9.6 \
    yaml

# PHP extension Sodium
RUN rm -f /usr/local/etc/php/conf.d/*sodium.ini \
    && rm -f /usr/local/lib/php/extensions/*/*sodium.so \
    && apt-get remove libsodium* -y  \
    && mkdir -p /tmp/libsodium  \
    && curl -sL https://github.com/jedisct1/libsodium/archive/1.0.18-RELEASE.tar.gz | tar xzf - -C  /tmp/libsodium \
    && cd /tmp/libsodium/libsodium-1.0.18-RELEASE/ \
    && ./configure \
    && make && make check \
    && make install  \
    && cd / \
    && rm -rf /tmp/libsodium  \
    && pecl install -o -f libsodium

RUN docker-php-ext-enable \
    bcmath \
    bz2 \
    calendar \
    exif \
    gd \
    geoip \
    gettext \
    gmp \
    igbinary \
    imagick \
    imap \
    intl \
    ldap \
    mailparse \
    msgpack \
    mysqli \
    oauth \
    opcache \
    pcntl \
    pdo_mysql \
    propro \
    pspell \
    raphf \
    recode \
    redis \
    shmop \
    soap \
    sockets \
    sodium \
    sysvmsg \
    sysvsem \
    sysvshm \
    tidy \
    xdebug \
    xmlrpc \
    xsl \
    yaml \
    zip

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN a2enmod rewrite \
    && a2enmod proxy \
    && a2enmod proxy_fcgi \
    && a2enmod headers \
    && a2enmod ssl \
    && rm -f /etc/apache2/sites-enabled/000-default.conf \
    && useradd -m -d /home/phpdevbox -s /bin/bash phpdevbox && adduser phpdevbox sudo \
    && echo "phpdevbox:phpdevbox" | chpasswd \
    && touch /etc/sudoers.d/privacy \
    && sed -i 's/www-data/phpdevbox/g' /etc/apache2/envvars \
    && mkdir -p ${APP_ROOT} \
    && chown -R phpdevbox:phpdevbox ${APP_ROOT} \
    && chown -R phpdevbox:phpdevbox /home/phpdevbox

RUN curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash - \
    && apt-get install -y nodejs \
    && npm update -g npm \
    && npm install npm@latest -g \
    && npm install -g grunt-cli && npm install -g gulp-cli

# SSL certificate
RUN mkdir /etc/apache2/ssl \
    && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt -subj "/C=US/ST=New York/L=New York/O=PHPDEVBOX/CN=PHPDEVBOX"

# PHP config
COPY conf/php.ini /usr/local/etc/php/conf.d/php-config.ini

# XDebug config
COPY conf/xdebug.ini /usr/local/etc/php/conf.d/xdebug-config.ini

# Mail config
COPY conf/mail.ini /usr/local/etc/php/conf.d/mail-config.ini

# php-fpm config
COPY conf/php-fpm-phpdevbox.conf /usr/local/etc/php-fpm.d/php-fpm-phpdevbox.conf

# apache config
COPY conf/apache-default.conf /etc/apache2/sites-enabled/apache-default.conf

# entrypoint config
ADD conf/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80 22 443 5000 9000 44100

WORKDIR ${APP_ROOT}

USER root

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
