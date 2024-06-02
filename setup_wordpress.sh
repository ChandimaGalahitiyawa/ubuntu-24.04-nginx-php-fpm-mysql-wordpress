#!/bin/bash

# Check if a domain name is passed as an argument
if [ -z "$1" ]; then
    # Prompt user for the domain name if not provided as an argument
    read -p "Enter your domain name (e.g., example.com): " DOMAIN_NAME
else
    DOMAIN_NAME=$1
fi

# Exit if no domain name is provided
if [ -z "$DOMAIN_NAME" ]; then
    echo "No domain name provided. Exiting script."
    exit 1
fi

# Generate a strong password for MySQL root user
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32)

# Update and upgrade the system
sudo apt-get update -y && sudo apt-get upgrade -y

# Install Nginx
sudo apt-get install nginx -y

# Install PHP and required PHP extensions
sudo apt-get install php8.3-fpm php8.3-common php8.3-mysql php8.3-xml php8.3-curl php8.3-gd php8.3-mbstring php8.3-opcache php8.3-zip php8.3-intl -y

# Install MySQL
sudo apt-get install mysql-server -y

# Set MySQL root password
sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '${MYSQL_ROOT_PASSWORD}'; FLUSH PRIVILEGES;"

# Save MySQL root password to a file
echo "MySQL Root Password: ${MYSQL_ROOT_PASSWORD}" > /var/www/db_details.txt
sudo chown www-data:www-data /var/www/db_details.txt
sudo chmod 600 /var/www/db_details.txt

# Install Certbot for SSL
sudo apt-get install certbot python3-certbot-nginx -y

# Create Nginx server block
sudo tee /etc/nginx/sites-available/${DOMAIN_NAME}.conf > /dev/null <<EOL
server {
    listen 80;
    listen [::]:80;
    root /var/www/html/${DOMAIN_NAME};
    index index.php;
    server_name ${DOMAIN_NAME} www.${DOMAIN_NAME};

    client_max_body_size 10M;
    autoindex off;
    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
         include snippets/fastcgi-php.conf;
         fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
         fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
         include fastcgi_params;
    }
}
EOL

# Enable the server block
sudo ln -s /etc/nginx/sites-available/${DOMAIN_NAME}.conf /etc/nginx/sites-enabled/

# Test Nginx configuration and restart
sudo nginx -t
sudo systemctl restart nginx

# Obtain and install SSL certificate
sudo certbot --nginx -d ${DOMAIN_NAME} -d www.${DOMAIN_NAME}

# Prompt user for database details
read -p "Enter your database name: " DB_NAME
read -p "Enter your database user: " DB_USER
DB_PASSWORD=$(openssl rand -base64 32)

# Create MySQL database and user
sudo mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "
CREATE DATABASE ${DB_NAME};
CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL ON ${DB_NAME}.* TO '${DB_USER}'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;
"

# Save database details to the file
echo "Database Name: ${DB_NAME}" >> /var/www/db_details.txt
echo "Database User: ${DB_USER}" >> /var/www/db_details.txt
echo "Database Password: ${DB_PASSWORD}" >> /var/www/db_details.txt

# Download and set up WordPress
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
sudo mv wordpress /var/www/html/${DOMAIN_NAME}
sudo chown -R www-data:www-data /var/www/html/${DOMAIN_NAME}
sudo chmod -R 755 /var/www/html/${DOMAIN_NAME}

echo "All done! Now you can complete the WordPress setup through your web browser."
echo "Database details are saved in /var/www/db_details.txt"
