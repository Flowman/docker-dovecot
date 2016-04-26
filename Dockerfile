FROM alpine:edge

RUN \
	apk add --no-cache \
		dovecot \
		dovecot-mysql \
		dovecot-pigeonhole-plugin \
	&& mkdir /data \
	&& chown mail:mail /data

COPY ./dovecot /etc/dovecot

COPY ./docker-entrypoint.sh ./gencert.sh /

RUN chmod +x /docker-entrypoint.sh /gencert.sh

VOLUME ["/data"]

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 143 993 4190

CMD ["dovecot", "-F"]