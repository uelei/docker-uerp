FROM debian
MAINTAINER docker@uelei.com
RUN apt-get update && apt-get install -y apache2 php5 php5-curl curl openssh-server git supervisor
RUN mkdir -p  /var/log/supervisor
RUN  export DEBIAN_FRONTEND=noninteractive && apt-get -y install mysql-server php5-mysql && service mysql start
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY config/default /etc/apache2/sites-available/default
RUN git clone https://github.com/uelei/uerp.git /var/www/uerp/
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/var/www/uerp/
RUN cd /var/www/uerp/ && service apache2 start && service mysql start &&php composer.phar update && app/console doctrine:database:create && app/console doctrine:schema:update --force
RUN cd /var/www/uerp/ && chown -R root:www-data app/cache && chown -R root:www-data app/logs && chown -R root:www-data app/config/parameters.yml
RUN cd /var/www/uerp/ && chmod -R 775 app/cache && chmod -R 775 app/logs && chmod -R 775 app/config/parameters.yml
RUN a2enmod rewrite && service apache2 start && service mysql start && cd /var/www/uerp/ && php app/console fos:user:create admin admin@example.com admin &&  php app/console assetic:dump
RUN cd /var/www/uerp/web/ && sed -i'' '7,13 s/^/#/' config.php
EXPOSE 80 22
CMD ["/usr/bin/supervisord"]
