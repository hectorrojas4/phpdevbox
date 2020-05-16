# phpdevbox
PHP development environment using Docker with Debian and PHP 7.1.24-fpm

## SSH to Docker Container

### To access the application container:
Run in your host terminal:
```
docker exec -it --user phpdevbox [CONTAINER_NAME] /bin/bash
cd /var/www/phpdevbox
```

## Docker Credentials
User: `phpdevbox`
Password: `phpdevbox`


### To access the mysql console:
```
mysql -h localhost -u"root" -p"root"
```

#### Settrings for MySQL Workbench
Hostname: `localhost`
Port: `3306`
Username: `root`
Password: `root`
