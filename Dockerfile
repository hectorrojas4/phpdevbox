FROM php:7.1.27-fpm

MAINTAINER "Hector Rojas"

ARG DEBIAN_FRONTEND=noninteractive

ENV PHP_EXTRA_CONFIGURE_ARGS="--enable-fpm --with-fpm-user=phpdevbox --with-fpm-group=phpdevbox"

RUN apt-get update && apt-get install -y \
    apt-utils \
    sudo \
    nano \
    vim \
    curl \
    wget \
    unzip \
    bzip2 \
    cron \
    git \
    sendmail-bin \
    openssh-server \
    supervisor \
    mysql-client \
    ocaml \
    expect \
    libmcrypt-dev \
    libicu-dev \
    libxml2-dev libxslt1-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure hash --with-mhash \
    && docker-php-ext-install -j$(nproc) bcmath gd intl json mbstring mcrypt opcache mysqli pdo pdo_mysql soap xsl zip iconv xml xmlrpc \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && pecl install xdebug && docker-php-ext-enable xdebug \
    && echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_host=10.254.254.254" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.idekey=XDEBUG" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.max_nesting_level=1000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && chmod 666 /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && mkdir /var/run/sshd \
    && echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config \
    && apt-get install -y apache2 \
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
    && mkdir /var/www/phpdevbox \
    && mkdir /var/www/phpdevbox/public \
    && sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && rm -r /usr/local/etc/php-fpm.d/* \
    && sed -i 's/www-data/phpdevbox/g' /etc/apache2/envvars

# PHP config
ADD conf/php.ini /usr/local/etc/php

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

RUN chown -R phpdevbox:phpdevbox /home/phpdevbox \
    && chown -R phpdevbox:phpdevbox /var/www/phpdevbox \
    && chown -R phpdevbox:phpdevbox /var/www/phpdevbox/public

EXPOSE 80 22 443 5000 9000 44100
WORKDIR /home/phpdevbox

USER root

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
