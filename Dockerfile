FROM debian:7 as builder

ENV NGINX_VERSION=1.18.0 \
    NGINX_BUILD_ASSETS_DIR=/var/lib/docker-nginx \
    NGINX_BUILD_ROOT_DIR=/var/lib/docker-nginx/rootfs

ARG WITH_DEBUG=false

RUN apt-get update \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
      wget ca-certificates make gcc g++ pkg-config

COPY nginx-build/ ${NGINX_BUILD_ASSETS_DIR}

RUN chmod +x ${NGINX_BUILD_ASSETS_DIR}/install.sh

RUN ${NGINX_BUILD_ASSETS_DIR}/install.sh

COPY entrypoint.sh ${NGINX_BUILD_ROOT_DIR}/sbin/entrypoint.sh

COPY entrypoint.sh ${NGINX_BUILD_ROOT_DIR}/sbin/entrypoint.sh

RUN chmod 755 ${NGINX_BUILD_ROOT_DIR}/sbin/entrypoint.sh

FROM debian:7

LABEL maintainer="mohsal.saleem@gmail.com"

ENV NGINX_USER=www-data \
    NGINX_SITECONF_DIR=/etc/nginx/sites-enabled \
    NGINX_LOG_DIR=/var/log/nginx \
    NGINX_TEMP_DIR=/varlib/nginx

COPY --from=builder /var/lib/docker-nginx/rootfs /

EXPOSE 80/tcp 443/tcp

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["/usr/sbin/nginx"]
