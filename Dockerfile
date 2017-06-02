FROM nginx:alpine
MAINTAINER Thomas VIAL

WORKDIR /usr/share/nginx
ADD start-z-push.sh .

RUN apk update && \
	apk add php5 php5-imap php5-fpm && \
	rm -rf /var/cache/apk/* && \
	wget http://download.z-push.org/final/2.3/z-push-2.3.6.tar.gz -O z-push.tar.gz && \
	tar xzf z-push.tar.gz && \
	mv z-push-* z-push && \
	rm z-push.tar.gz && \
	chown -R nginx:nobody z-push && \
	echo "daemon off;" >> /etc/nginx/nginx.conf && \
	chmod +x start-z-push.sh

ADD default.conf /etc/nginx/conf.d/
ADD php-fpm.conf /etc/php5/

CMD "./start-z-push.sh"
