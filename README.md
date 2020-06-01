# phpdevbox
PHP development environment using Docker with Debian and PHP 7.3-fpm

## SSH to Docker Container

### To access the application container:
Run in your host terminal:
```
docker exec -it --user phpdevbox [CONTAINER_NAME] /bin/bash
cd /app
```

### Docker Credentials
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

## XDEBUG
The XDEBUG settings of the PHP image were created using a loopback alias:

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

### Linux
```
sudo ifconfig lo:0 10.254.254.254 netmask 255.255.255.0 up
```


### XDEBUG in PHPStorm
*Preferences -> Languages & Frameworks -> PHP -> Xdebug* set `Debug port` to `9000` in the *Xdebug* section. 

Open *Preferences -> Languages & Frameworks -> PHP -> Xdebug -> DBGp Proxy*:<br/>
IDE Key: `PHPSTORM`<br/>
Host: `10.254.254.254`<br/>
Port: `9000`<br/>
