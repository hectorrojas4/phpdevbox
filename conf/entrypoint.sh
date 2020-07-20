#!/bin/bash

# Create ROOT directory
mkdir -p ${APP_ROOT}

# Enable PHP extensions
PHP_EXT_DIR=/usr/local/etc/php/conf.d
PHP_EXT_ENABLE=docker-php-ext-enable
[ -d ${PHP_EXT_DIR} ] && rm -f ${PHP_EXT_DIR}/docker-php-ext-*.ini
if [ -x "$(command -v ${PHP_EXT_ENABLE})" ] && [ ! -z "${PHP_EXTENSIONS}" ]; then
      ${PHP_EXT_ENABLE} ${PHP_EXTENSIONS}
fi

# Override php.ini config
[ ! -z "${PHP_MEMORY_LIMIT}" ] && sed -i "s|PHP_MEMORY_LIMIT|${PHP_MEMORY_LIMIT}|g" /usr/local/etc/php/conf.d/php-config.ini
[ ! -z "${MAX_EXECUTION_TIME}" ] && sed -i "s|MAX_EXECUTION_TIME|${MAX_EXECUTION_TIME}|g" /usr/local/etc/php/conf.d/php-config.ini
[ ! -z "${UPLOAD_MAX_FILESIZE}" ] && sed -i "s|UPLOAD_MAX_FILESIZE|${UPLOAD_MAX_FILESIZE}|g" /usr/local/etc/php/conf.d/php-config.ini
[ ! -z "${POST_MAX_SIZE}" ] && sed -i "s|POST_MAX_SIZE|${POST_MAX_SIZE}|g" /usr/local/etc/php/conf.d/php-config.ini
[ ! -z "${GC_MAXLIFETIME}" ] && sed -i "s|GC_MAXLIFETIME|${GC_MAXLIFETIME}|g" /usr/local/etc/php/conf.d/php-config.ini
[ ! -z "${LOG_ERRORS}" ] && sed -i "s|LOG_ERRORS|${LOG_ERRORS}|g" /usr/local/etc/php/conf.d/php-config.ini

# Override Apache config
[ ! -z "${APP_ROOT}" ] && sed -i "s|APP_ROOT|${APP_ROOT}|g" /etc/apache2/sites-enabled/apache-default.conf

supervisord -n -c /etc/supervisord.conf
