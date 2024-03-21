# Use `php:7.4-apache` as the base image.
FROM php:7.4-apache

# Install `mysqli` extension for PHP.
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && install-php-extensions mysqli

# Copy the application source code to `/var/www/html/`.
COPY ./ /var/www/html/

# Update database connection strings to point to a Kubernetes service named `mysql-service`.
ENV DB_HOST="mysql-service"

# Expose port `80` to allow traffic to the web server.
EXPOSE 80