# Pimdock

Straightforward Docker setup for Pimcore.
Current configuration: Nginx:alpine, PHP:7.4.15-fpm, MySQL:5.7.22, Portainer:latest and PHPMyAdmin:latest.
___

# Setup

1. `git clone https://github.com/Frame05/Pimdock.git`
1. `docker-compose pull`
1. `docker-compose build app`
1. repeat previous step as long as pecl install throws: 
    * `Package "package_name" Version "package_version" does not have REST dependency information available` or
    * `Package "package_name" Version "package_version" does not have REST xml available`
1. `docker-compose up -d`
1. `docker exec -u ${APP_USER} -it APP_CONTAINER_ID /bin/bash`
1. if pimcore project does not exist in `/webroot`:
    1. `cd /var/www`
    1. `COMPOSER_MEMORY_LIMIT=-1 composer create-project pimcore/skeleton ${APP_NAME}`
1. `cd /var/www/${APP_NAME}`
1. `PIMCORE_INSTALL_ADMIN_USERNAME=${APP_USER} PIMCORE_INSTALL_ADMIN_PASSWORD=${APP_PASSWORD} PIMCORE_INSTALL_MYSQL_USERNAME=${MYSQL_USER} PIMCORE_INSTALL_MYSQL_PASSWORD=${MYSQL_PASSWORD} PIMCORE_ENVIRONMENT=${APP_ENV} ./vendor/bin/pimcore-install --mysql-host-socket ${MYSQL_HOST} --mysql-port ${MYSQL_PORT} --mysql-database ${MYSQL_DATABASE} --no-interaction`
1. `chown -R ${APP_USER}:webmasters /var`
1. `setfacl -dR -m u:${APP_USER}:rwX -m g:webmasters:rwX /var`
1. `setfacl -R -m u:${APP_USER}:rwX -m g:webmasters:rwX /var`
1. enjoy.