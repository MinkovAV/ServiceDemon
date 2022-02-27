#!/bin/bash

#set colors
red='\033[1;31m'
gray='\033[0;37m'
green='\033[1;32m'
reset='\033[0m'

[[ -z "$1" ]] && { echo -e "${red}Error: name of service not found plese set it! ${reset} "; exit 1; }

SERVICE_NAME=$1
SERVICE_FILE="service-$SERVICE_NAME.sh"
SERVICE_FILE_PID="$SERVICE_NAME.pid"
SERVICE_FILE_LOG="$SERVICE_NAME.log"
SERVICE_FILE_CFG="$SERVICE_NAME.cfg"
SERVISE_LOG_DIR="/var/log/$SERVICE_NAME"
SERVISE_PID_DIR="/run/$SERVICE_NAME"
SERVISE_FILE_LOCATION="/usr/local/bin"

useradd -M -s /bin/bash "$SERVICE_NAME"

mkdir $SERVICE_NAME

cd $SERVICE_NAME

#exec &> /dev/null

########################################################################################
exec 3>&1 1>"$SERVICE_FILE"
echo '#!/bin/bash'
echo ''
echo "source /etc/${SERVICE_FILE_CFG}"
echo ''
echo '#################################################################################'
echo '# There You can write yore own code'
echo '#################################################################################'
echo 'exec ping -i $PING_DELAY  $HOST_FOR_PING'
echo ''
exec 1>&3 3>&-
chown $SERVICE_NAME:$SERVICE_NAME $SERVICE_FILE
chmod 711 $SERVICE_FILE 



#########################################################################################
touch {"$SERVICE_FILE_LOG","$SERVICE_FILE_PID","$SERVICE_FILE_CFG"}
chown $SERVICE_NAME:$SERVICE_NAME {"$SERVICE_FILE_LOG","$SERVICE_FILE_PID","$SERVICE_FILE_CFG"}
chmod 644 {"$SERVICE_FILE_LOG","$SERVICE_FILE_PID","$SERVICE_FILE_CFG"}



#########################################################################################
exec 3>&1 1>"start-$SERVICE_NAME.sh"
echo '#!/bin/bash'
echo ''
echo "nohup $SERVISE_FILE_LOCATION/$SERVICE_FILE >>$SERVISE_LOG_DIR/$SERVICE_FILE_LOG 2>>$SERVISE_LOG_DIR/$SERVICE_FILE_LOG &"
echo "echo \$! > $SERVISE_PID_DIR/$SERVICE_FILE_PID"
exec 1>&3 3>&-
chown $SERVICE_NAME:$SERVICE_NAME start-$SERVICE_NAME.sh
chmod 711 start-$SERVICE_NAME.sh

#########################################################################################
exec 3>&1 1>"stop-$SERVICE_NAME.sh"
echo '#!/bin/bash'
echo ''
echo "pid_file=\"/run/$SERVICE_NAME/$SERVICE_FILE_PID\""
echo 'pid=$(cat "$pid_file")'
echo 'kill -9 $pid'
echo 'echo "" > "$pid_file"'
exec 1>&3 3>&-
chown $SERVICE_NAME:$SERVICE_NAME stop-$SERVICE_NAME.sh
chmod 711 stop-$SERVICE_NAME.sh

#########################################################################################
exec 3>&1 1>"restart-$SERVICE_NAME.sh"
echo '#!/bin/bash'
echo ''
echo "pid_file=\"/run/$SERVICE_NAME/$SERVICE_FILE_PID\""
echo 'pid=$(cat "$pid_file")'
echo 'kill -9 $pid'
echo ''
echo "./start-$SERVICE_NAME.sh"
echo ''
exec 1>&3 3>&-
chown $SERVICE_NAME:$SERVICE_NAME restart-$SERVICE_NAME.sh
chmod 711 restart-$SERVICE_NAME.sh

#########################################################################################
exec 3>&1 1>"$SERVICE_NAME.conf"
echo '[Unit]'
echo "Description=${SERVICE_NAME} service"
echo 'After=network.target network-online.target'
echo ''
echo '[Install]'
echo 'WantedBy=multi-user.target'
echo ''
echo '[Service]'
echo 'Type=forking'
echo "User=$SERVICE_NAME"
echo "Group=$SERVICE_NAME"
echo "ExecStart=$SERVISE_FILE_LOCATION/start-$SERVICE_NAME.sh"
echo "ExecStop=$SERVISE_FILE_LOCATION/stop-$SERVICE_NAME.sh"
echo "ExecReload=$SERVISE_FILE_LOCATION/restart-$SERVICE_NAME.sh"
echo 'LimitNOFILE=65536'
echo 'Restart=on-failure'
echo 'KillMode=process'
echo ''
exec 1>&3 3>&-


#########################################################################################
exec 3>&1 1>"INSTALL.sh"
echo '#!/bin/bash'
echo ''
echo "cp -p $SERVICE_FILE $SERVISE_FILE_LOCATION"
echo "cp -p start-$SERVICE_NAME.sh $SERVISE_FILE_LOCATION"
echo "cp -p stop-$SERVICE_NAME.sh $SERVISE_FILE_LOCATION"
echo "cp -p restart-$SERVICE_NAME.sh $SERVISE_FILE_LOCATION"
echo "mkdir /run/$SERVICE_NAME"
echo "cp -p $SERVICE_FILE_PID /run/$SERVICE_NAME/"
echo "mkdir /var/log/$SERVICE_NAME"
echo "cp -p $SERVICE_FILE_LOG /var/log/$SERVICE_NAME"
echo "cp -p $SERVICE_NAME.conf /etc/systemd/system/$SERVICE_NAME.service"
echo "cp -p $SERVICE_FILE_CFG /etc/"
echo "cp -p ${SERVICE_NAME}_logrotate.conf /etc/logrotate.d/"
echo "systemctl daemon-reload"
echo "logrotate -d /etc/logrotate.d/$SERVICE_NAME_logrotate.conf"
echo ""
exec 1>&3 3>&-
chmod 711 INSTALL.sh

#########################################################################################
exec 3>&1 1>"UNINSTALL.sh"
echo '#!/bin/bash'
echo ''
echo "rm $SERVISE_FILE_LOCATION/start-$SERVICE_NAME.sh"
echo "rm $SERVISE_FILE_LOCATION/stop-$SERVICE_NAME.sh"
echo "rm $SERVISE_FILE_LOCATION/restart-$SERVICE_NAME.sh"
echo "rm $SERVISE_FILE_LOCATION/$SERVICE_FILE"
echo "rm -r /run/$SERVICE_NAME"
echo "rm -r /var/log/${SERVICE_NAME}"
echo "rm /etc/systemd/system/$SERVICE_NAME.service"
echo "rm /etc/$SERVICE_FILE_CFG"
echo "rm /etc/logrotate.d/${SERVICE_NAME}_logrotate.conf"
echo "deluser $SERVICE_NAME"
echo "groupdel $SERVICE_NAME"
echo ""
exec 1>&3 3>&-
chmod 711 UNINSTALL.sh

#########################################################################################
exec 3>&1 1>"${SERVICE_NAME}_logrotate.conf"
echo "/var/log/$SERVICE_NAME/$SERVICE_FILE_LOG{"
echo "daily"
echo "rotate 3"
echo "size 10M"
echo "compress"
echo "delaycompress"
echo "}"
echo ""
exec 1>&3 3>&-




exec >/dev/tty
echo -e "${green}Done. Structure for service/demon ${name} was created.${reset}"



