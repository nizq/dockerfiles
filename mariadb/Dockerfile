FROM alpine:3.4

RUN apk add --update mariadb mariadb-client bash \
    && rm -f /var/cache/apk/*

COPY entrypoint.sh /

VOLUME /var/lib/mysql

EXPOSE 3306
CMD ["/entrypoint.sh"]
