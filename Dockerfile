FROM hypriot/rpi-alpine-scratch

MAINTAINER zepptron <https://github.com/zepptron>
ENV HUGO_VERSION=0.31

ADD www /www
ADD binary/hugo /usr/local/bin/hugo
WORKDIR /www/
EXPOSE 1313

ENTRYPOINT ["hugo"]
