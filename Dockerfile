FROM wordpress:php7.4-apache
COPY . /var/www/html

#This copies apache-status.conf from the repo and pastes it into a container named status.conf whose mode status is by default turned off 
COPY apache-status.conf /etc/apache2/conf-available/status.conf   

#What this code below does is for is to turn on mod_status which is always turned off by default but needs to be turned on because we are using apache-exporter
#to get live metrics from apache about the behaviour of our website in prometheus format
RUN a2enmod status && a2enconf status

EXPOSE 80