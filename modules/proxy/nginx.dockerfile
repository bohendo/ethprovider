FROM alpine:3.8

RUN apk add --update --no-cache openssl certbot nginx iputils && \
    openssl dhparam -out /etc/ssl/dhparam.pem 2048 && \
    ln -fs /dev/stdout /var/log/nginx/access.log && \
    ln -fs /dev/stderr /var/log/nginx/error.log

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./entry.sh /root/entry.sh

ENTRYPOINT ["sh", "/root/entry.sh"]
