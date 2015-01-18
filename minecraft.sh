#!/bin/bash

########## CONFIGURATION ##########
name="server" # Name of the server - configures screen name too
location="/path/to/mc/root" # Minecraft server root folder
ram="2048M" # Ram allocation
serverjar="bukkit.jar" # Server jar
backup="/backup/minecraft" #Root of backup location


########## SCRIPT ##########



currentTerm=`tty`
warn=0
backup="${backup}/${name}" #sets backup location to server specific location

serverStart(){
	cd $location
	screen -Smd $name /usr/bin/java -server -Xms500m -Xmx$RAM -XX:MaxPermSize=128M -jar $bukkit > server.log
}

sendCommand(){
	screen -S $name -p 0 -X stuff "`printf "${1}\r"`";sleep $2
}

if [ -f server.log.lck ]; then
	screen -x $name
	exit
fi

if [ "$2" = "warn" ]; then
	warn=1
fi

#Stops server
if [ "$1" = "stop" ]; then
	echo "Stopping minecraft server..."
        if [ "$warn" = 1 ]; then
		sendCommand "say Server shutting down in 2 minutes" 90
		sendCommand "say Sever shutting down in 30 seconds" 30
	fi
	sendCommand "save-on" 1
	sendCommand "save-all" 0
        sendCommand "Say Sever is shutting down" 0
        sendCommand "stop" 5
	exit
# Restart server
elif [ "$1" = "restart" ]; then
	echo "Restarting minecraft server..."
	if [ "$warn" = 1 ]; then
		sendCommand "say Server restarting in 2 minutes" 90
		sendCommand "say Sever restarting in 30 seconds" 30
	fi
	sendCommand "save-on" 1
	sendCommand "save-all" 0
	sendCommand "say Sever is restarting down, it will be back up in about 30 seconds" 0
	sendCommand "stop" 12
	echo "Starting minecraft server..."
	start
# Starts server
elif [ "$1" = "start" ]; then
	if [ -f server.log.lck ]; then
		screen -x $name
	else
		start
	fi
# Saves map
elif [ "$1" = "save" ]; then
	echo "Saving minecraft map..."
	if [ "$warn" = 1 ]; then
		sendCommand "say Map will be saved in 10 seconds..." 10
		sendCommand "say Map is being saved." 0
	fi
	sendCommand "save-on" 1
	sendCommand "save-all" 1
	if [ "$warn" = 1 ]; then
		sendCommand "say Map was saved." 0
	fi
	exit
# Timed static message
elif [ "$1" = "beep" ]; then
	sendCommand "say Beep Boop" 0
# Back up - indev
elif [ "$1" = "backup" ]; then
	echo "Backing up server"
	if [ "$warn" = 1 ]; then
		sendCommand "say Backing up server in 30 seconds" 20
		sendCommand "say Backing up server in 10 seconds" 10
		sendCommand "say Backing up server..." 1
	fi	
	DATE=$(date +%Y-%m-%d-%Hh%M)
	tar -zcf "$backuploc/arca-back-$DATE.tar.gz" /minecraft/arca/
	if [ "$warn" = 1 ]; then
		sendCommand "say Back up done! Have fun!" 1
	fi
	echo "Finished back up"	
else
	echo "Usage: go.sh stop | start | restart [warn]"
	echo "Warn option will add a 2 minute warning along with a 30 second warning."
fi
exit
