#!/bin/sh

NGINX_VERSION=1.9.13
NAXSI_VERSION=0.54

SOURCE_PATH=/source
BUILD_PATH=${SOURCE_PATH}/build
DIST_PATH=${SOURCE_PATH}/dist
FINAL_PATH=${SOURCE_PATH}/final

rm -rf $BUILD_PATH
mkdir -p $BUILD_PATH
cd $BUILD_PATH
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz.asc
wget https://github.com/nbs-system/naxsi/archive/${NAXSI_VERSION}.tar.gz
wget https://github.com/nbs-system/naxsi/releases/download/${NAXSI_VERSION}/${NAXSI_VERSION}.tar.gz.asc

gpg --keyserver pgp.mit.edu --recv-keys 2685AED4 7BD9BF62 A1C052F8
gpg --verify nginx-${NGINX_VERSION}.tar.gz.asc nginx-${NGINX_VERSION}.tar.gz
gpg --verify ${NAXSI_VERSION}.tar.gz.asc ${NAXSI_VERSION}.tar.gz

tar -xvzf nginx-${NGINX_VERSION}.tar.gz
tar -xvzf ${NAXSI_VERSION}.tar.gz

cd nginx-${NGINX_VERSION}
./configure --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
	--http-log-path=/var/log/nginx/access.log \
	--pid-path=/var/run/nginx.pid \
	--lock-path=/var/run/nginx.lock \
	--http-client-body-temp-path=/var/cache/nginx/client_temp \
	--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
	--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
	--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
	--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
	--with-http_ssl_module \
	--with-http_realip_module \
	--with-http_addition_module \
	--with-http_sub_module \
	--with-http_dav_module \
	--with-http_flv_module \
	--with-http_mp4_module \
	--with-http_gunzip_module \
	--with-http_gzip_static_module \
	--with-http_random_index_module \
	--with-http_secure_link_module \
	--with-http_stub_status_module \
	--with-http_auth_request_module \
	--with-mail \
	--with-mail_ssl_module \
	--with-file-aio \
	--with-ipv6 \
    --with-http_ssl_module \
    --user=nginx \
	--group=nginx \
    --add-module=../naxsi-${NAXSI_VERSION}/naxsi_src/
make
rm -rf $DIST_PATH
mkdir -p $DIST_PATH
DESTDIR=$DIST_PATH make install

rm -f ${FINAL_PATH}/*
mkdir -p ${FINAL_PATH}
(cd $DIST_PATH; tar zcvf ${FINAL_PATH}/nginx-bin.tar.gz *)

