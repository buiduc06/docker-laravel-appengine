FROM gcr.io/google-appengine/php72:latest

ARG COMPOSER_FLAGS='--no-dev --prefer-dist --ignore-platform-reqs --optimize-autoloader'
ENV COMPOSER_FLAGS=${COMPOSER_FLAGS}

RUN apt-get update -y
RUN apt-get install unzip -y
RUN apt-get install autoconf -y
RUN apt-get install build-essential -y

# Install php-decimal
RUN apt-get install libmpdec-dev -y
RUN pecl install decimal

# Install swoole
RUN apt-get install libpq-dev -y
RUN curl -o /tmp/swoole.tar.gz https://github.com/swoole/swoole-src/archive/v4.3.3.tar.gz -L && \
tar zxvf /tmp/swoole.tar.gz && \
cd swoole-src* && \
phpize && \
./configure \
--enable-coroutine \
--enable-async-redis \
--enable-coroutine-postgresql && \
make && \
make install

COPY . $APP_DIR
RUN chown -R www-data.www-data $APP_DIR
RUN /build-scripts/composer.sh;

ENTRYPOINT ["/build-scripts/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

EXPOSE 8080
