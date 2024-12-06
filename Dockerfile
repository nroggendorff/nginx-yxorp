FROM nginx:latest

RUN apt-get update && \
    apt-get install -y certbot python3-certbot-nginx

COPY host.sh /host.sh
RUN chmod +x /host.sh

EXPOSE 80 443

CMD ["bash", "/host.sh"]
