#!/usr/bin/env bash

service apache2 start

supervisord -n -c /etc/supervisord.conf

