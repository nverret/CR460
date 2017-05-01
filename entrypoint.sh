#!/bin/bash

envsubst '$DB_PASSWORD:$DB_HOST:$DB_USER:$DB_NAME' < /var/www/html/wordpress/wp-config.php-template > /var/www/html/wordpress/wp-config.php

/usr/sbin/apache2ctl -D FOREGROUND