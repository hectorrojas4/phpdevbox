# phpdevbox
PHP development environment for Zend Framework using Docker with Debian and PHP 7.1.24-fpm

## SSH to Docker Container
To access to the docker container using ssh you can add a loopback alias:
#### Mac
```
sudo ifconfig lo0 alias 10.254.254.254 255.255.255.0
```

#### Linux
```
sudo ifconfig lo:0 10.254.254.254 netmask 255.255.255.0 up

### To access the application container:
```
ssh -p 4022 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t phpdevbox@10.254.254.254 "cd /var/www/phpdevbox; bash"
```
User: `phpdevbox`
Password: `phpdevbox`


### To access the mysql console:
```
mysql -h 10.254.254.254 -u"root" -p"root"
```

