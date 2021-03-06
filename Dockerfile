FROM php:7.1.6

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

# UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]

#
# Essentials
#
RUN apt-get update
RUN apt-get install -y \
        software-properties-common \
        python-software-properties \
        wget \
        curl \
        vim \
        htop \
        git

#
# nginx
#
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y nginx
#
ADD ./files/config/nginx.conf /etc/nginx/nginx.conf
ADD ./files/config/default.conf   /etc/nginx/sites-available/default

#
# php
#
#RUN \
#    apt-get install -y language-pack-en-base && \
#    LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php && \
#    apt-get update && \
#    apt-get install -y \
#        libapache2-mod-php7.0 \
#        php7.0 \
#        php7.0-fpm \
#        php7.0-cli \
#        php7.0-common \
#        libpcre3-dev \
#        php7.0-dev \
#        php7.0-gd \
#        php7.0-curl \
#        php7.0-mcrypt \
#        php7.0-intl \
#        php7.0-mysql \
#        php7.0-pgsql \
#        php7.0-mbstring \
#        php7.0-json \
#        php7.0-opcache \
#        php7.0-xml \
#        php7.0-odbc \
#        php7.0-zip \
#        php7.0-bcmath \
#        php-pear \
#        libsasl2-dev
#
#RUN mkdir -p /usr/local/openssl/include/openssl/ && \
#    ln -s /usr/include/openssl/evp.h /usr/local/openssl/include/openssl/evp.h && \
#    mkdir -p /usr/local/openssl/lib/ && \
#    ln -s /usr/lib/x86_64-linux-gnu/libssl.a /usr/local/openssl/lib/libssl.a && \
#    ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/local/openssl/lib/
#
#
#
#RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/7.0/fpm/php.ini
#RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/7.0/cli/php.ini
#RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf
#RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini

ADD ./files/public/index.php /server/http/public/index.php

# Setup runit
#RUN mkdir                       /etc/service/nginx
#COPY ./files/runit/nginx.sh     /etc/service/nginx/run
#RUN chmod +x                    /etc/service/nginx/run
#RUN mkdir                       /etc/service/phpfpm
#ADD ./files/runit/phpfpm.sh     /etc/service/phpfpm/run
#RUN chmod +x                    /etc/service/phpfpm/run

# Install composer
RUN \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '55d6ead61b29c7bdee5cccfb50076874187bd9f21f65d8991d46ec5cc90518f447387fb9f76ebae1fbbacf329e583e30') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"  && \
    php composer-setup.php  && \
    php -r "unlink('composer-setup.php');"

# Add xdebug cli/fpm
#RUN pecl install xdebug \
#    && echo "zend_extension=$(find /usr/lib/php/ -name xdebug.so)" > /etc/php/7.0/mods-available/xdebug.ini \
#
#    && echo "xdebug.remote_enable=1" >> /etc/php/7.0/mods-available/xdebug.ini \
#    && echo "xdebug.remote_handler=dbgp" >> /etc/php/7.0/mods-available/xdebug.ini \
#    && echo "xdebug.remote_port=9000" >> /etc/php/7.0/mods-available/xdebug.ini \
#    && echo "xdebug.remote_autostart=1" >> /etc/php/7.0/mods-available/xdebug.ini \
#    && echo "xdebug.remote_connect_back=1" >> /etc/php/7.0/mods-available/xdebug.ini \
#    && echo "xdebug.idekey=debugit" >> /etc/php/7.0/mods-available/xdebug.ini \
#
#    && ln -s /etc/php/7.0/mods-available/xdebug.ini /etc/php/7.0/cli/conf.d/20-xdebug.ini \
#    && ln -s /etc/php/7.0/mods-available/xdebug.ini /etc/php/7.0/fpm/conf.d/20-xdebug.ini


# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 80
