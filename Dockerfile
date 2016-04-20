FROM alpine:latest

RUN \
	apk add --no-cache \
		dovecot \
		dovecot-mysql

COPY ./dovecot /etc/dovecot

COPY ./docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 143 993

CMD ["dovecot", "-F"]