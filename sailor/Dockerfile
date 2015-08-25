FROM ubuntu:14.10

ENV DEBIAN_FRONTEND noninteractive

# python-software-properties for 'apt-add-repository'
RUN apt-get update && apt-get install -y lua5.2 software-properties-common dialog

RUN apt-get install -y apache2 git lua-filesystem ranger

RUN a2enmod lua

RUN apt-get install luarocks -y; luarocks install sailor

RUN update-alternatives --set lua-interpreter /usr/bin/lua5.1

RUN mkdir /var/www/sailor/; \
    echo "<VirtualHost *:8080>" > /etc/apache2/sites-available/sailor.conf; \
    echo "  ServerAdmin webmaster@localhost" >> /etc/apache2/sites-available/sailor.conf; \
    echo "  DocumentRoot /var/www/sailor/" >> /etc/apache2/sites-available/sailor.conf; \
    echo "  ErrorLog \${APACHE_LOG_DIR}/sailor_error.log" >> /etc/apache2/sites-available/sailor.conf; \
    echo "  CustomLog \${APACHE_LOG_DIR}/sailor_access.log combined" >> /etc/apache2/sites-available/sailor.conf; \
    echo "</VirtualHost>" >> /etc/apache2/sites-available/sailor.conf; \
    a2ensite sailor;

EXPOSE 8080
