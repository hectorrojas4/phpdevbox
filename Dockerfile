FROM php:7.3-fpm-stretch

MAINTAINER "Hector Rojas"

ARG DEBIAN_FRONTEND=noninteractive

ENV PHP_EXTRA_CONFIGURE_ARGS="--enable-fpm --with-fpm-user=phpdevbox --with-fpm-group=phpdevbox"

ENV PHP_MEMORY_LIMIT 2G
ENV UPLOAD_MAX_FILESIZE 64M
ENV APP_ROOT /app
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
    mailutils \
    dnsutils \
    openssh-server \
    supervisor \
    mariadb-client \
    default-mysql-client \
    ocaml \
    expect \
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

RUN pecl install -o -f geoip-1.1.1 \
    igbinary \
    imagick \
    mailparse \
    msgpack \
    oauth \
    propro \
    raphf \
    redis \
    xdebug-2.7.1 \
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

# Configure gd
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu
RUN docker-php-ext-configure opcache --enable-opcache
RUN docker-php-ext-configure zip --with-libzip
RUN docker-php-ext-configure hash --with-mhash

# PHP extensions
RUN docker-php-ext-install -j$(nproc) bcmath bz2 calendar exif gd gettext gmp iconv imap intl json ldap mysqli mbstring opcache pcntl pdo pdo_mysql pspell recode \
    shmop simplexml soap sockets sysvmsg sysvsem sysvshm tidy xml xmlrpc xsl zip

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

RUN chmod 666 /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && mkdir /var/run/sshd \
    && echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config \
    && a2enmod rewrite \
    && a2enmod proxy \
    && a2enmod proxy_fcgi \
    && a2enmod headers \
    && a2enmod ssl \
    && rm -f /etc/apache2/sites-enabled/000-default.conf \
    && useradd -m -d /home/phpdevbox -s /bin/bash phpdevbox && adduser phpdevbox sudo \
    && echo "phpdevbox:phpdevbox" | chpasswd \
    && touch /etc/sudoers.d/privacy \
    && echo "Defaults        lecture = never" >> /etc/sudoers.d/privacy \
    && sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && rm -r /usr/local/etc/php-fpm.d/* \
    && sed -i 's/www-data/phpdevbox/g' /etc/apache2/envvars \
    && mkdir -p ${APP_ROOT} \
    && chown -R phpdevbox:phpdevbox /home/phpdevbox \
    && chown -R phpdevbox:phpdevbox ${APP_ROOT}

RUN curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash - \
    && apt-get install -y nodejs \
    && npm update -g npm \
    && npm install npm@latest -g \
    && npm install -g grunt-cli && npm install -g gulp-cli

# Install and configure Postfix
RUN echo "postfix postfix/mailname string mail.example.com" | debconf-set-selections \
    && echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections \
    && apt-get install --assume-yes postfix \
    && postconf -e myhostname=mail.example.com \
    && postconf -e mydestination="mail.example.com, example.com, localhost.localdomain, localhost" \
    && postconf -e mail_spool_directory="/var/spool/mail/" \
    && postconf -e mailbox_command=""

# SSL certificate
RUN mkdir /etc/apache2/ssl \
    && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt -subj "/C=US/ST=New York/L=New York/O=PHPDEVBOX/CN=PHPDEVBOX"

# PHP config
ADD conf/php.ini /usr/local/etc/php

# XDebug config
ADD conf/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# SSH config
COPY conf/sshd_config /etc/ssh/sshd_config
RUN chown phpdevbox:phpdevbox /etc/ssh/ssh_config

# supervisord config
ADD conf/supervisord.conf /etc/supervisord.conf

# php-fpm config
ADD conf/php-fpm-phpdevbox.conf /usr/local/etc/php-fpm.d/php-fpm-phpdevbox.conf

# apache config
ADD conf/apache-default.conf /etc/apache2/sites-enabled/apache-default.conf

# entrypoint config
ADD conf/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80 22 443 5000 9000 44100

WORKDIR /home/phpdevbox

USER root

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
