FROM wordpress:php7.4-apache
COPY . /var/www/html

#This copies apache-status.conf from the repo and pastes it into a container named status.conf whose mode status is by default turned off 
COPY apache-status.conf /etc/apache2/conf-available/status.conf   

# Enable Apache's mod_status so the apache-exporter sidecar can scrape it and expose Prometheus-format metrics
RUN a2enmod status && a2enconf status

EXPOSE 80