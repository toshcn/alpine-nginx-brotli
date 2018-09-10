FROM toshcn/alpine-base:1.0
LABEL maintainer "By toshcn - https://github.com/toshcn"

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]

COPY rootfs /

ENV NGINX_VERSION 1.14.0

RUN set -ex \
  && apk add --no-cache \
    ca-certificates \
    libressl \
    pcre \
    zlib \
  && apk add --no-cache --virtual .build-deps \
    build-base \
    autoconf \
    automake \
    libtool \
    linux-headers \
    libressl-dev \
    pcre-dev \
    wget \
    zlib-dev \
    git \
    \
  && cd /tmp \
  && git clone https://github.com/google/ngx_brotli.git \
  && cd ngx_brotli \
  && git submodule update --init \
  && cd /tmp \
#  && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
  && tar xzf nginx-${NGINX_VERSION}.tar.gz \
  && cd nginx-${NGINX_VERSION} \
  && ./configure \
    \
    --prefix=/usr/local/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    \
    --user=www-data \
    --group=www-data \
    \
    --with-threads \
    \
    --with-file-aio \
    \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_auth_request_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_stub_status_module \
    \
    --http-log-path=/var/log/nginx/access.log \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    \
    --with-mail \
    --with-mail_ssl_module \
    \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    \
     --add-module=/tmp/ngx_brotli \
  && make -j$(getconf _NPROCESSORS_ONLN) \
  && make install \
  && mkdir -p /etc/nginx \
  && mkdir -p /usr/local/nginx/html/default \
  && mv /usr/local/nginx/html/50x.html /usr/local/nginx/html/default \
  && mv /usr/local/nginx/html/index.html /usr/local/nginx/html/default \
  && adduser -D www-data \
  && mkdir -p /var/cache/nginx \
  && apk del .build-deps \
  && chmod +x /usr/local/bin/about \
  && rm -rf /tmp/*
