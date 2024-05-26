
# WordPress Installation on AWS EC2 (Ubuntu 24.04 + nginx + php-fpm + MySQL + certbot)

A comprehensive guide to installing and setting up WordPress on an AWS EC2 instance using Ubuntu 24.04, nginx, php-fpm, MySQL, and certbot for SSL.

## Prerequisites

- An AWS account
- Basic knowledge of SSH and command-line operations
- A domain name (optional, but recommended for SSL)

## Step 1: Launch an EC2 Instance

1. Go to the AWS Management Console.
2. Launch an EC2 instance with Ubuntu 24.04 as the AMI.
3. Choose an instance type (e.g., t2.micro).
4. Configure security group to allow HTTP (port 80), HTTPS (port 443), and SSH (port 22) traffic.

## Step 2: Connect

#Use AWS Console


#Use SSH to connect to your instance. (Terminal or Putty)
```
ssh -i your-key.pem ubuntu@your-ec2-instance-ip
```



## Step 3: Software installion

```
sudo apt-get update -y && sudo apt-get upgrade && sudo apt-get install nginx -y & sudo apt install php-fpm php-common php-mysql php-xml php-curl php-gd php-mbstring php-opcache php-zip php-intl -y && sudo apt-get install mysql-server -y && sudo apt-get install ufw -y  && sudo apt install certbot python3-certbot-nginx -y
```

## Step 4: mysql password chanage
```
mysql -u root

MySQL root Password Set
ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'strong_password'; FLUSH PRIVILEGES; exit;
```

## Step 5: nginx Config & WordPress Install

#nginx virtual server blocks
```
sudo nano /etc/nginx/sites-available/example.com.conf
```

#cope this code and make changes

Make sure to check your PHP versions using:
```
php -v
```

before adding this code. Change it accordingly.

Also, remember to replace 'example.com' with your actual domain name."

```
server {
    listen 80;
    listen [::]:80;
    root /var/www/html/example.com;
    index  index.php;
    server_name example.com www.example.com;

    client_max_body_size 10M;
    autoindex off;
    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
         include snippets/fastcgi-php.conf;
         fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
         fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
         include fastcgi_params;
    }
}
```

#site enable
```
sudo ln -s /etc/nginx/sites-available/example.com.conf /etc/nginx/sites-enabled/
```

#nginx status
```
nginx -t
```
#nginx restart
```
sudo systemctl restart nginx
```

## Step 6: get and install free SSL certificate
```
sudo certbot --nginx -d example.com -d www.example.com
```

## Step 7: Database Creation 

You need to enter the root password to log in. Passwords entered in the console are invisible, so you won't see them as you type.

```
mysql -u root -p

CREATE DATABASE database_name;

CREATE USER 'database_name_usr'@'localhost' IDENTIFIED BY 'database_strong_password';

GRANT ALL ON database_name.* TO 'database_name_usr'@'localhost' WITH GRANT OPTION;

FLUSH PRIVILEGES;
EXIT;
```

All done! Now you can use this to create any VPS on WordPress. If you need to change PHP versions, do so either before or after installation.

## Contact

Your Name - [hello@chandimagalahitiyawa.com](mailto:hello@chandimagalahitiyawa.com)

Project Link: [https://github.com/ChandimaGalahitiyawa/ubuntu-24.04-nginx-php-fpm-mysql-wordpress](https://github.com/ChandimaGalahitiyawa/ubuntu-24.04-nginx-php-fpm-mysql-wordpress)
