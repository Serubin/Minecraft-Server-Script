#!/bin/bash
currentTerm=`tty`
SCREEN_NAME="render"

RAM="2048M"
bukkitloc="/minecraft/rit"
bukkit="./Rainbow.jar"

backuploc="/backup/minecraft"

warn=0

start(){
	cd $bukkitloc
	screen -Smd $SCREEN_NAME /usr/bin/java -server -Xms500m -Xmx$RAM -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:ParallelGCThreads=4 -XX:+CMSParallelRemarkEnabled -XX:+DisableExplicitGC -XX:MaxGCPauseMillis=500 -XX:SurvivorRatio=16 -XX:TargetSurvivorRatio=90 -jar $bukkit > server.log
}

if [ -f server.log.lck ]; then
	screen -x $SCREEN_NAME
	exit
fi

if [ "$2" = "warn" ]; then
	warn=1
fi

if [ "$1" = "stop" ]; then
	echo "Stopping minecraft server..."
        if [ "$warn" = 1 ]; then
		screen -S $SCREEN_NAME -p 0 -X stuff "`printf "say Server shutting down in 2 minutes\r"`";sleep 90
		screen -S $SCREEN_NAME -p 0 -X stuff "`printf "say Sever shutting down in 30 seconds\r"`"; sleep 30
	fi
	screen -S $SCREEN_NAME -p 0 -X stuff "`printf "save-on\r"`"; sleep 1
	screen -S $SCREEN_NAME -p 0 -X stuff "`printf "save-all\r"`";
        screen -S $SCREEN_NAME -p 0 -X stuff "`printf "Say Sever is shutting down\r"`"
        screen -S $SCREEN_NAME -p 0 -X stuff "`printf "stop\r"`"; sleep 5
	exit
elif [ "$1" = "restart" ]; then
	echo "Restarting minecraft server..."
	if [ "$warn" = 1 ]; then
		screen -S $SCREEN_NAME -p 0 -X stuff "`printf "say Server restarting in 2 minutes\r"`";sleep 90
		screen -S $SCREEN_NAME -p 0 -X stuff "`printf "say Sever restarting in 30 seconds\r"`"; sleep 30
	fi
	screen -S $SCREEN_NAME -p 0 -X stuff "`printf "save-on\r"`"; sleep 1
	screen -S $SCREEN_NAME -p 0 -X stuff "`printf "save-all\r"`";
	screen -S $SCREEN_NAME -p 0 -X stuff "`printf "say Sever is restarting down, it will be back up in about 30 seconds\r"`"
	screen -S $SCREEN_NAME -p 0 -X stuff "`printf "stop\r"`"; sleep 12
	echo "Starting minecraft server..."
	start
	#screen -Sm $SCREEN_NAME java -server -Xmx$RAM -jar $bukkit
elif [ "$1" = "start" ]; then
	if [ -f server.log.lck ]; then
		screen -x $SCREEN_NAME
	else
		start
		#screen -Sm $SCREEN_NAME java -server -Xmx$RAM -jar $bukkit
	fi
elif [ "$1" = "save" ]; then
	echo "Saving minecraft map..."
	if [ "$warn" = 1 ]; then
		screen -S $SCREEN_NAME -p 0 -X stuff "`printf "say Map will be saved in 10 seconds...\r"`"; sleep 10
		screen -S $SCREEN_NAME -p 0 -X stuff "`printf "say Map is being saved.\r"`"
	fi
	screen -S $SCREEN_NAME -p 0 -X stuff "`printf "save-on\r"`"; sleep 1
	screen -S $SCREEN_NAME -p 0 -X stuff "`printf "save-all\r"`"; sleep 1
	if [ "$warn" = 1 ]; then
		screen -S $SCREEN_NAME -p 0 -X stuff "`printf "say Map was saved.\r"`"
	fi
	exit
elif [ "$1" = "beep" ]; then
	screen -S $SCREEN_NAME -p 0 -X stuff "`printf "say Beep Boop\r"`";
elif [ "$1" = "janitor" ]; then
	if [ "$warn" ]; then
		screen -S $SCREEN_NAME -p 0 -X stuff "`printf "say Janitor turning in 10 minutes\r"`"; sleep 300
		screen -S $SCREEN_NAME -p 0 -X stuff "`printf "say Janitor turning in 5 minutes\r"`"; sleep 270
		screen -S $SCREEN_NAME -p 0 -X stuff "`printf "say Janitor turning in 30 seconds\r"`"; sleep 270
	fi
	screen -s $SCREEN_NAME -p 0 -X stuff "`printf "diw toggle janitor\r"`"; sleep 300
	screen -s $SCREEN_NAME -p 0 -X stuff "`printf "diw toggle janitor\r"`"; sleep 10
	if [ "$warn" ]; then
		screen -s $SCREEN_NAME -p 0 -X stuff "`printf "say Janitor done!\r"`"; sleep 300
	fi
elif [ "$1" = "backup" ]; then
	echo "Backing up server"
	if [ "$warn" = 1 ]; then
		screen -S $SCREEN_NAME -p 0 -X stuff "`printf "say Backing up server in 30 seconds\r"`"; sleep 20
		screen -S $SCREEN_NAME -p 0 -X stuff "`printf "say Backing up server in 10 seconds\r"`"; sleep 10
		screen -S $SCREEN_NAME -p 0 -X stuff "`printf "say Backing up server...\r"`"; sleep 1
	fi	
	DATE=$(date +%Y-%m-%d-%Hh%M)
	tar -zcf "$backuploc/arca-back-$DATE.tar.gz" /minecraft/arca/
	if [ "$warn" = 1 ]; then
		screen -S $SCREEN_NAME -p 0 -X stuff "`printf "say Back up done! Have fun!\r"`"; sleep 1
	fi
	echo "Finished back up"	
else
	echo "Usage: go.sh stop | start | restart [warn]"
	echo "Warn option will add a 2 minute warning along with a 30 second warning."
fi
exit
