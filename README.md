# phpdevbox
PHP development environment using Docker with Debian and PHP 7.1.24-fpm

## To access the application container:
```
ssh -p 4022 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t phpdevbox@127.0.0.1 "cd /var/www/phpdevbox; bash"
```
User: `phpdevbox`
Password: `phpdevbox`


## To access the mysql console:
```
mysql -h 127.0.0.1 -u"root" -p"root"
```

