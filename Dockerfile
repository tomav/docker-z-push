FROM nginx:alpine
MAINTAINER Thomas VIAL

WORKDIR /usr/share/nginx
ADD start-z-push.sh .

RUN apk update && \
	apk add php5 php5-imap php5-fpm php5-posix php5-pdo && \
	rm -rf /var/cache/apk/* && \
	wget http://download.z-push.org/final/2.3/z-push-2.3.6.tar.gz -O z-push.tar.gz && \
	tar xzf z-push.tar.gz && \
	mv z-push-* z-push && \
	rm z-push.tar.gz && \
	mkdir -p /var/log/z-push/ /var/lib/z-push/ && \
	chmod 770 /var/log/z-push/ /var/lib/z-push/ && \
	chown -R nginx:nobody z-push/ /var/log/z-push/ /var/lib/z-push/ && \
	echo "daemon off;" >> /etc/nginx/nginx.conf && \
	chmod +x start-z-push.sh && \
	sed -i "s/define('BACKEND_PROVIDER', '')/define('BACKEND_PROVIDER', 'BackendIMAP')/" ./z-push/config.php && \
	sed -i "s/define('IMAP_FOLDER_CONFIGURED', false)/define('IMAP_FOLDER_CONFIGURED', true)/" ./z-push/backend/imap/config.php && \
	sed -i "s/define('IMAP_FOLDER_PREFIX', '')/define('IMAP_FOLDER_PREFIX', 'INBOX')/" ./z-push/backend/imap/config.php && \
	sed -i "s/define('IMAP_SERVER', 'localhost')/define('IMAP_SERVER', getenv('MAILSERVER_ADDRESS'))/" ./z-push/backend/imap/config.php && \
	sed -i "s/define('IMAP_PORT', 143)/define('IMAP_PORT', getenv('MAILSERVER_PORT'))/" ./z-push/backend/imap/config.php 

ADD default.conf /etc/nginx/conf.d/
ADD php-fpm.conf /etc/php5/

ENV MAILSERVER_ADDRESS= 
ENV MAILSERVER_PORT= 

CMD "./start-z-push.sh"
