FROM hypriot/rpi-alpine-scratch

MAINTAINER zepptron
ENV HUGO_VERSION=0.31

RUN apk update \
    && apk upgrade \
	rm -rf /var/cache/apk/*

ADD www /www
ADD binary/hugo /usr/local/bin/hugo
WORKDIR /www/
ENTRYPOINT ["hugo"]
EXPOSE 1313