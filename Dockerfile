FROM hypriot/rpi-alpine-scratch

MAINTAINER zepptron
ENV HUGO_VERSION=0.31
ENV HUGO_BUILD=latest

RUN rm -rf /var/cache/apk/*

ADD www /www
ADD binary/hugo /usr/local/bin/hugo
WORKDIR /www/
ENTRYPOINT ["hugo"]
EXPOSE 1313