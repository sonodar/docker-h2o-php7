FROM centos:7

MAINTAINER ryoheisonoda@outlook.com

CMD /opt/h2o/bin/h2o -c /opt/h2o/h2o.conf

RUN yum install -y epel-release curl tar | true

WORKDIR /tmp

# Download
RUN curl -L https://github.com/h2o/h2o/archive/v1.4.4.tar.gz > h2o-1.4.4.tar.gz && \
    curl -L https://github.com/php/php-src/archive/php-7.0.0RC2.tar.gz > php-7.0.0RC2.tar.gz && \
    tar zxf h2o-1.4.4.tar.gz && tar zxf php-7.0.0RC2.tar.gz && \
    rm -f h2o-1.4.4.tar.gz php-7.0.0RC2.tar.gz

RUN yum install -y \
  autoconf \
  cmake \
  make \
  gcc \
  gcc-c++ \
  bison \
  openssl \
  net-snmp-devel \
  libxml2-devel \
  libyaml-devel \
  openssl-devel \
  freetype-devel \
  mariadb-devel \
  libcurl-devel \
  libpng-devel \
  libjpeg-turbo-devel \
  openldap-devel \
  libmcrypt-devel \
  readline-devel \
  gd-devel \
  bzip2-devel \
  libicu-devel \
  libwebp-devel \
  gmp-devel \
  libtidy-devel \
  libxslt-devel | true

# build h2o
RUN cd h2o-1.4.4; cmake -DCMAKE_INSTALL_PREFIX=/opt/h2o . && make h2o && make install

# create h2o user
RUN groupadd h2o; useradd -g h2o -s /sbin/nologin -d /opt/h2o h2o && chown -R h2o:h2o /opt/h2o

# copy certfiles
RUN cp h2o-1.4.4/examples/h2o/server.* /opt/h2o/ && chmod 600 /opt/h2o/server.* && chown h2o:h2o /opt/h2o/server.*

# build php7
RUN cd php-src-php-7.0.0RC2 && ./buildconf --force && ./configure \
  --prefix=/opt/php7 \
  --with-libdir=lib64 \
  --enable-mbstring \
  --enable-mysqlnd \
  --enable-bcmath \
  --enable-sockets \
  --enable-exif \
  --enable-gd-native-ttf \
  --enable-gd-jis-conv \
  --enable-intl \
  --enable-pcntl \
  --enable-soap \
  --enable-wddx \
  --enable-zip \
  --with-openssl \
  --with-pcre-regex \
  --with-zlib \
  --with-bz2 \
  --with-curl \
  --with-gd \
  --with-webp-dir \
  --with-jpeg-dir \
  --with-png-dir \
  --with-zlib-dir \
  --with-xpm-dir \
  --with-freetype-dir \
  --with-gettext \
  --with-gmp \
  --with-mhash \
  --with-icu-dir=/usr \
  --with-ldap \
  --with-onig \
  --with-mcrypt \
  --with-mysqli=mysqlnd \
  --with-pdo-mysql=mysqlnd \
  --with-readline \
  --with-snmp \
  --with-tidy \
  --with-xsl \
  --with-gnu-ld && make && make install

RUN cp php-src-php-7.0.0RC2/php.ini-production /opt/php7/lib/php/php.ini

# copy config file
ADD h2o.conf /opt/h2o/h2o.conf
