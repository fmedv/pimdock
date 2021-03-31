FROM php:7.4.15-fpm

# Adapted from: https://github.com/markhilton/docker-php-fpm/blob/master/7.4/Dockerfile

#--------------------------------------------------------------------------
# Setting enviroment variables and arguments
#--------------------------------------------------------------------------

ENV DEBIAN_FRONTEND=noninteractive TERM=xterm
# Arguments defined in docker-compose.yml
ARG app_name
ARG app_uid
ARG app_user
#ARG app_password
#ARG app_env
#ARG db_user
#ARG db_password
#ARG db_name
#ARG db_host
#ARG db_port


#--------------------------------------------------------------------------
# Install and configure extensions
#--------------------------------------------------------------------------

RUN apt-get update -y
# RUN apt-get -y install gcc make autoconf libc-dev pkg-config
# Install system dependencies
RUN apt-get install -y --no-install-recommends \
	git \
	acl \
	net-tools \
    libzip-dev \
	libmemcached-dev \
	libz-dev \
	libpq-dev \
	libssl-dev libssl-doc libsasl2-dev \
	libmcrypt-dev \
	libxml2-dev \
	libicu-dev g++ \
	libldap2-dev libbz2-dev \
	curl libcurl4-openssl-dev openssl \
	libenchant-dev libgmp-dev firebird-dev libib-util \
	re2c libpng++-dev \
	libwebp-dev libjpeg-dev libjpeg62-turbo-dev libpng-dev libxpm-dev libvpx-dev libfreetype6-dev \
	libmagick++-dev \
	libmagickwand-dev \
    libgd-dev \
	libtidy-dev libxslt1-dev libmagic-dev libexif-dev file \
	sqlite3 libsqlite3-dev libxslt-dev \
	libmhash2 libmhash-dev libc-client-dev libkrb5-dev libssh2-1-dev \
	unzip libpcre3 libpcre3-dev \
	poppler-utils ghostscript libmagickwand-6.q16-dev libsnmp-dev libreadline6-dev \
	freetds-bin freetds-dev freetds-common libct4 libsybdb5 tdsodbc libedit-dev libreadline-dev librecode-dev libpspell-dev libonig-dev
# RUN apt-get install -y --no-install-recommends zlib1g-dev libsodium-dev
# RUN apt-get install ffmpeg facedetect
# RUN apt-get install libreoffice libreoffice-script-provider-python libreoffice-math xfonts-75dpi poppler-utils inkscape libxrender1 libfontconfig1 ghostscript

# Install PHP extensions
# RUN docker-php-ext-configure hash --with-mhash && \
#	  docker-php-ext-install hash
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
	docker-php-ext-install imap iconv && \
	docker-php-ext-install bcmath bz2 calendar ctype dba dom enchant && \
    docker-php-ext-install fileinfo exif gettext gmp && \
    docker-php-ext-install intl json ldap mysqli && \
    docker-php-ext-install opcache pcntl pspell

# Fix for docker-php-ext-install pdo_dblib
# https://stackoverflow.com/questions/43617752/docker-php-and-freetds-cannot-find-freetds-in-know-installation-directories
RUN ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/ && \
	docker-php-ext-install pdo pdo_dblib && \
	docker-php-ext-install pdo_mysql pdo_pgsql pdo_sqlite pgsql phar posix && \
	docker-php-ext-install readline && \
	docker-php-ext-install session shmop simplexml soap sockets && \
	docker-php-ext-install sysvmsg sysvsem sysvshm
# RUN docker-php-ext-install snmp

# Fix for docker-php-ext-install xmlreader
# https://github.com/docker-library/php/issues/373
RUN export CFLAGS="-I/usr/src/php" && docker-php-ext-install xmlreader xmlwriter xml xmlrpc xsl

RUN docker-php-ext-install tidy tokenizer zend_test zip
# RUN docker-php-ext-install filter reflection spl standard
# RUN docker-php-ext-install pdo_firebird pdo_oci

# 'Package "xxx" does not have REST xml available'
# Turn on proxy (The proxy IP may be docker host IP or others):
# RUN pear config-set http_proxy http://47.93.198.182:8888
# Install pecl extensions
RUN pecl install ds && docker-php-ext-enable ds
RUN pecl install imagick && docker-php-ext-enable imagick
RUN pecl install igbinary && docker-php-ext-enable igbinary
RUN pecl install memcached && docker-php-ext-enable memcached
RUN pecl install mcrypt-1.0.3 && docker-php-ext-enable mcrypt
RUN pecl install redis-5.1.0 && docker-php-ext-enable redis

# https://serverpilot.io/docs/how-to-install-the-php-ssh2-extension
# RUN pecl install ssh2-1.1.2 && docker-php-ext-enable ssh2

# Install MongoDB
# RUN pecl install mongodb && docker-php-ext-enable mongodb

# Install Xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug

RUN yes "" | pecl install msgpack && \
	docker-php-ext-enable msgpack

# Install APCu
RUN pecl install apcu && \
	docker-php-ext-enable apcu --ini-name docker-php-ext-10-apcu.ini

# Install and configure locale
RUN apt-get update -y && apt-get install -y apt-transport-https gnupg locales && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales
ENV LANG='en_US.UTF-8' LANGUAGE='en_US.UTF-8' LC_ALL='en_US.UTF-8'

# Install MSSQL support and ODBC driver
# RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
# 	curl https://packages.microsoft.com/config/debian/8/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
# 	export DEBIAN_FRONTEND=noninteractive && apt-get update -y && \
# 	ACCEPT_EULA=Y apt-get install -y msodbcsql unixodbc-dev
# RUN set -xe && \
#	pecl install pdo_sqlsrv && \
# 	docker-php-ext-enable pdo_sqlsrv && \
# 	apt-get purge -y unixodbc-dev && apt-get autoremove -y && apt-get clean

# RUN docker-php-ext-configure spl && docker-php-ext-install spl

# install GD
RUN docker-php-ext-configure gd \
	#	--with-png \
	--with-jpeg \
	--with-xpm \
	--with-webp \
	--with-freetype \
	&& docker-php-ext-install -j$(nproc) gd

#--------------------------------------------------------------------------
# Final Touches
#--------------------------------------------------------------------------

# Install required libs for Healthcheck
RUN apt-get -y install libfcgi0ldbl nano htop iotop lsof cron redis-tools
# RUN apt-get -y install mariadb-client

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin

# Install NewRelic agent
# RUN echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list && \
#	  curl https://download.newrelic.com/548C16BF.gpg | apt-key add - && \
#	  apt-get -y update && \
#	  DEBIAN_FRONTEND=noninteractive apt-get -y install newrelic-php5 newrelic-sysmond && \
#	  export NR_INSTALL_SILENT=1 && newrelic-install install

# Install SendGrid
# RUN echo "postfix postfix/mailname string localhost" | debconf-set-selections && \
#	  echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections && \
#	  DEBIAN_FRONTEND=noninteractive apt-get install postfix libsasl2-modules -y

# Add scripts and set chmod +execute
# ADD scripts/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# Health check
#RUN echo '#!/bin/bash' > /healthcheck && \
#	echo 'env -i SCRIPT_NAME=/health SCRIPT_FILENAME=/health REQUEST_METHOD=GET cgi-fcgi -bind -connect 127.0.0.1:9000 || exit 1' >> /healthcheck && \
#	chmod +x /healthcheck

# Clean up
#apt-get remove -y git
RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apk/*


#--------------------------------------------------------------------------
# User configuration
#--------------------------------------------------------------------------

# Setting file/folder permissions; Source: https://www.codegrepper.com/code-examples/php/laravel+public+folder+permissions
#                                      and https://gist.github.com/stefanbc/9956ed211cd32571e73f
# Create system user and webmasters group
RUN useradd -G www-data,root -u $app_uid -d /home/$app_user $app_user && \
	groupadd webmasters && \
	usermod -a -G webmasters $app_user
RUN mkdir -p /home/$app_user/.composer && \
    chown -R $app_user:$app_user /home/$app_user


#--------------------------------------------------------------------------
# File permission configuration
#--------------------------------------------------------------------------

# Setting permission to /var
RUN chown -R $app_user:webmasters /var

# Setting additional permissions
# Source: https://symfony.com/doc/3.4/setup/file_permissions.html#using-acl-on-a-system-that-supports-setfacl-linux-bsd
RUN setfacl -dR -m u:$app_user:rwX -m g:webmasters:rwX /var && \
	setfacl -R -m u:$app_user:rwX -m g:webmasters:rwX /var

# Set working directory
WORKDIR /var/www

USER $app_user


#--------------------------------------------------------------------------
# Install Pimcore (db server must run to complete installation)
#--------------------------------------------------------------------------

#RUN COMPOSER_MEMORY_LIMIT=-1 composer create-project pimcore/skeleton $app_name

#WORKDIR /var/www/$app_name

# Copy installer.yml configuration and install Pimcore
#COPY ./.docker/pimcore/installer.yml var/www/pimcore/app/config/installer.yml
#RUN PIMCORE_INSTALL_ADMIN_USERNAME=$app_user PIMCORE_INSTALL_ADMIN_PASSWORD=$app_password \
#    ./vendor/bin/pimcore-install \
#    --no-interaction
