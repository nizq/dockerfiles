FROM alpine:3.4

RUN apk --update add ca-certificates wget git gcc libc-dev gnupg pcre-dev openssl-dev make linux-headers \
    && addgroup -S nginx \
	&& adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx

VOLUME ["/source"]
