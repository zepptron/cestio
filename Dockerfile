FROM hypriot/rpi-alpine-scratch

MAINTAINER zepptron
ENV HUGO_VERSION=0.31
 
# set alpine to version 3.2 instead of edge
RUN apk update && \
	rm -rf /var/cache/apk/*


ADD binary/hugo /usr/local/bin/hugo
WORKDIR /www/
ENTRYPOINT ["hugo"]
EXPOSE 1313