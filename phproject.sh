#!/bin/bash

# SET DEFAULT VARIABLES
ACTION=$1 	# ACTION CAN BE EITHER 'CREATE' OR 'DELETE'
DOMAIN=$2 	# DOMAIN NAME
ROOT_FOLDER=$3 	# ROOT FOLDER OF PHP PROJECT
USER_DIR='/var/www/'
SITES_AVAILABLE='/etc/apache2/sites-available/'
EMAIL='webmaster@localhost'

if [ "$ACTION" != 'create' ] && [ "$ACTION" != 'delete' ]
	then
		echo $"Please choose an action to perform. (create or delete)"
		exit 1;
fi

while [ "$DOMAIN" == "" ]
do
	echo -e $"Provide a domain name."
	read DOMAIN
done

if [ "$ROOT_FOLDER" == "" ]; then
	ROOT_FOLDER=${DOMAIN}
fi

ROOT_FOLDER=$USER_DIR$ROOT_FOLDER
SITES_AVAILABLE_DOMAIN_CONF=$SITES_AVAILABLE$DOMAIN.conf

# Create a new virtual host
if [ "$ACTION" == 'create' ]
	then
		# See if domain already exists
		if [ -e "$SITES_AVAILABLE_DOMAIN_CONF" ]; then
			echo -e $"The domain you entered already exists.\nTry another domain name."
			exit 1;
		fi
		# Create root folder if not exists with proper permissions
		if ! [ -d "$ROOT_FOLDER" ]; then
			sudo mkdir -p $ROOT_FOLDER
			sudo chown -R $USER:$USER $ROOT_FOLDER
			sudo chmod -R 755 $ROOT_FOLDER
			if ! echo "<?php phpinfo(); ?>" > $ROOT_FOLDER/index.php
			then
				echo -e $"ERROR: Not able to write to $ROOT_FOLDER/index.php.\nCheck permissions."
				exit;
			else
				echo -e $"Created $ROOT_FOLDER/index.php"
			fi
		fi

		# Create virtual host
		if ! echo "
	<VirtualHost *:80>
    		ServerAdmin $EMAIL
    		ServerName $DOMAIN
    		ServerAlias $DOMAIN
    		DocumentRoot $ROOT_FOLDER
    		<Directory />
        		AllowOverride All
    		</Directory>
    		<Directory $ROOT_FOLDER>
        		Options Indexes FollowSymLinks MultiViews
        		AllowOverride all
        		Require all granted
    		</Directory>
    		ErrorLog /var/log/apache2/$DOMAIN-error.log
    		LogLevel error
    		CustomLog /var/log/apache2/$DOMAIN-access.log combined
	</VirtualHost>" | sudo tee $SITES_AVAILABLE_DOMAIN_CONF > /dev/null 
	then
		echo $"ERROR: Not able to create $DOMAIN file"
		exit;
	else 
		echo "New virtual host created."
	fi
	# Add domain to /etc/hosts
	if ! echo -e "\n127.0.0.1	$DOMAIN" | sudo dd of=/etc/hosts  oflag=append conv=notrunc > /dev/null
	then
		echo "ERROR: Not able to write in /etc/hosts"
	else
		echo "Host added to /etc/hosts"
	fi
	# Enable website
	sudo a2ensite $DOMAIN
	# Restart apache
	systemctl reload apache2
	echo -e "Done. You have a new virtual host at http://$DOMAIN"
fi
# Delete a virtual host
if [ "$ACTION" == "delete" ]
then
	if ! [ -e $SITES_AVAILABLE_DOMAIN_CONF ]; then
		echo "ERROR: This domain does not exist."
		exit;
	else
	# Remove host from /etc/hosts
        sudo sed -i "/$DOMAIN/d" /etc/hosts
	# Disable website
	sudo a2dissite $DOMAIN
	echo -e "DONE: Disabled website $DOMAIN"
	# Restart apache
	systemctl reload apache2
	echo "DONE: Restarted apache."
	# Delete virtual host conf file
	sudo rm $SITES_AVAILABLE_DOMAIN_CONF
	echo "DONE: Removed domain conf file."
	fi
	# Delete root file
	if [ -d $ROOT_FOLDER ]; then
		echo -e "Removing root folder."
		sudo rm -rf $ROOT_FOLDER
	else
		echo -e "Root folder not found. Ignored."
	fi	
	echo -e "DONE: Removed virtual host $DOMAIN"
	exit 0;
fi
