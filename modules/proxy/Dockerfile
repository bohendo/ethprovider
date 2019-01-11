FROM alpine:3.8
WORKDIR /root
ENV HOME /root

RUN apk add --update --no-cache bash certbot nginx openssl && \
    openssl dhparam -out /etc/ssl/dhparam.pem 2048 && \
    ln -fs /dev/stdout /var/log/nginx/access.log && \
    ln -fs /dev/stdout /var/log/nginx/error.log

COPY wait-for.sh /root/wait-for.sh
COPY entry.sh /root/entry.sh
COPY nginx.conf /etc/nginx/nginx.conf

VOLUME /etc/letsencrypt
EXPOSE 80 443

ENTRYPOINT ["bash", "/root/entry.sh"]
