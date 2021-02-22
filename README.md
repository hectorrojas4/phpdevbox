# phpdevbox
PHP development environment using Docker with Debian and PHP 7.3-fpm.<br>
The configuration of this Docker includes SSMTP and Mailhog to test the sending of emails in the local environment

## Create a new PHP project
Create a new folder for your project and copy the docker-compose.yml file into it.
Change the *docker-compose* configuration according to your requirements, such as MEMORY_LIMIT, project ROOT, volumes to be shared between your local and the container, and the PHP extensions you need.

From you project root run the following command to create and start all the services configured in your `docker-compose.yml` configuration:

```
docker-compose up
```

Enter http://localhost/ or https://localhost/ in your web browser.<br>
> If you want to use a custom URL and not localhost then you should map it to the file `/etc/hosts`

## SSH to Docker Container

### To access the application container:
Run in your host terminal:
```
docker exec -it --user phpdevbox [CONTAINER_NAME] /bin/bash
cd /app
```

#### Docker Credentials
User: `phpdevbox`<br/>
Password: `phpdevbox`<br/>


### To access the mysql console:
```
mysql -h 127.0.0.1 -P 3306 -u"root" -p"root"
```

#### Settings for MySQL Workbench

Hostname: `127.0.0.1`<br/>
Port: `3306`<br/>
Username: `root`<br/>
Password: `root`<br/>

## XDEBUG
The XDEBUG settings of the PHP image were created using a loopback alias:

### Linux
```
sudo ifconfig lo:0 10.254.254.254 netmask 255.255.255.0 up
```

### Mac
```
sudo ifconfig lo0 alias 10.254.254.254 255.255.255.0
```

#### Make the loopback alias at startup - Mac
If you want to make this alias permanently, create a new launch daemon file:
```
sudo vi /Library/LaunchDaemons/com.network.alias.plist
```
Paste the following content:
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
 <dict>
   <key>Label</key>
   <string>com.network.alias</string>
   <key>ProgramArguments</key>
   <array>
        <string>ifconfig</string>
        <string>lo0</string>
        <string>alias</string>
        <string>10.254.254.254</string>
        <string>255.255.255.0</string>
        </array>
   <key>RunAtLoad</key>
   <true/>
   <key>StandardOutPath</key>
   <string>/var/log/com.network.alias.log</string>
   <key>StandardErrorPath</key>
   <string>/var/log/com.network.alias.log</string>
   <key>Debug</key>
   <true/>
 </dict>
</plist>
```

Run the following commands:
```
sudo chmod 0644 /Library/LaunchDaemons/com.network.alias.plist
sudo chown root:wheel /Library/LaunchDaemons/com.network.alias.plist
sudo launchctl load /Library/LaunchDaemons/com.network.alias.plist
```


### XDEBUG in PHPStorm
*Preferences -> Languages & Frameworks -> PHP -> Xdebug* set `Debug port` to `9000` in the *Xdebug* section. 

Open *Preferences -> Languages & Frameworks -> PHP -> Xdebug -> DBGp Proxy*:<br/>
IDE Key: `PHPSTORM`<br/>
Host: `10.254.254.254`<br/>
Port: `9000`<br/>

Go to *Preferences -> Languages & Frameworks -> PHP -> Servers* and create a new Server:<br/>
Name: `Docker`<br/>
Host: `localhost` or `127.0.0.1`<br/>
Port: `80`<br/>
Use path mappings to map your project files to the absolute path on the server.<br/>


## MailHog
This environment uses MailHog, an email testing tool for developers, that allows you to view outgoing emails without actually sending them to customers.

### To access the web interface:
In your web browser enter http://127.0.0.1:8025 or http://localhost:8025 and there you go!

## Elasticsearch
This environment includes the Elasticsearch container for Magento projects, if you don't need Elasticsearch in your project you should remove it from the docker-compose file.
