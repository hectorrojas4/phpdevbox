#!/usr/bin/env bash


rm -rf /var/www/phpdevbox/status.html
rm -rf /home/phpdevbox/phpdevbox/status.html

service apache2 start

supervisord -n -c /etc/supervisord.conf

