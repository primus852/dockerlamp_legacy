FROM ubuntu:14.04

MAINTAINER PrimuS <findnibbler@gmail.com>

# Install apache, PHP 5.6, and supplimentary programs. openssh-server, curl, and lynx-cur are for debugging the container.
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
    apache2 \
    php5 \
    php5-cli \
    libapache2-mod-php5 \
    php5-gd \
    php5-curl \
    php5-json \
    php5-mcrypt \
    php5-mysql \
    php5-xsl \
    php5-intl \
    php5-imap \
    libxrender1 \
    libxext6 \
    curl \
    wget \
    zip \
    unzip \
    xfonts-base \
    xfonts-75dpi \
    fontconfig

# Enable apache mods.
RUN a2enmod php5
RUN a2enmod rewrite

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php5/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini
RUN sed -ie 's/memory_limit\ =\ 128M/memory_limit\ =\ 2G/g' /etc/php5/apache2/php.ini
RUN sed -ie 's/\;date\.timezone\ =/date\.timezone\ =\ Europe\/Berlin/g' /etc/php5/apache2/php.ini
RUN sed -ie 's/upload_max_filesize\ =\ 2M/upload_max_filesize\ =\ 200M/g' /etc/php5/apache2/php.ini
RUN sed -ie 's/post_max_size\ =\ 8M/post_max_size\ =\ 200M/g' /etc/php5/apache2/php.ini

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Install Composer 
RUN php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');" \
	&& php /tmp/composer-setup.php --install-dir/usr/local/bin --filename=composer
	
# Install Symfony Installer
RUN mkdir -p /usr/local/bin \
	&& curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony \
	&& chmod a+x /usr/local/bin/symfony
	
# Install NodeJs
RUN apt-get install -y nodejs \
	npm
RUN ln -s /usr/bin/nodejs /usr/bin/node

# Install PHPUnit
RUN wget https://phar.phpunit.de/phpunit.phar
RUN chmod +x phpunit.phar
RUN mv phpunit.phar /usr/local/bin/phpunit

# Install WKHTMLTOX
RUN wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.xenial_amd64.deb
RUN dpkg -i wkhtmltox_0.12.5-1.xenial_amd64.deb

# By default start up apache in the foreground, override with /bin/bash for interative.
CMD chown -R www-data:www-data /var/www/html/var && /usr/sbin/apache2ctl -D FOREGROUND

WORKDIR /var/www/html
