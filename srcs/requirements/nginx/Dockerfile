FROM alpine:3.19

RUN apk add nginx

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /etc/nginx/certs && \
    apk add --no-cache openssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/certs/server.key -out /etc/nginx/certs/server.crt -subj \
	"/C=IT/ST=Rome/L=Rome/O=WP/OU=WP/CN=crea.42.it" && \
    apk del openssl

CMD ["nginx", "-g", "daemon off;"]
