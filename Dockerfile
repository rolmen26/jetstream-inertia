FROM php:8.1-fpm-alpine3.18 as backend

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=composer@sha256:2dc4166e6ef310e16a9ab898e6bd5d088d1689f75f698559096d962b12c889cc /usr/bin/composer /usr/bin/composer
ENV COMPOSER_HOME /usr/bin/composer

RUN apk update && apk add --no-cache nginx supervisor libpng-dev  && \
    apk add --no-cache $PHPIZE_DEPS && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install gd sockets && \
    rm -rf /var/cache/apk/*

# Copy the Nginx config file
COPY ./docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./docker/php/fpm-pool.conf /usr/local/etc/php-fpm.d/fpm-pool.conf
COPY ./docker/supervisor/supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 8080

WORKDIR /var/www/html

COPY . /var/www/html

RUN composer install --prefer-dist

ENTRYPOINT ["supervisord", "-n"]

CMD ["-c", "/etc/supervisor/supervisord.conf"]