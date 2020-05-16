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
User: `phpdevbox`<br/>
Password: `phpdevbox`<br/>


### To access the mysql console:
```
mysql -h 127.0.0.1 -P 3306 -u"root" -p"root"
```

### Settings for MySQL Workbench

Hostname: `127.0.0.1`<br/>
Port: `3306`<br/>
Username: `root`<br/>
Password: `root`<br/>

### Xdebug in PHPStorm
*Preferences -> Languages & Frameworks -> PHP -> Xdebug* set `Debug port` to `9000` in the *Xdebug* section. 

Open *Preferences -> Languages & Frameworks -> PHP -> Xdebug -> DBGp Proxy*:<br/>
IDE Key: `PHPSTORM`<br/>
Host: `127.0.0.1`<br/>
Port: `9000`<br/>

