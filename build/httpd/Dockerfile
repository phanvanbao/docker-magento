FROM httpd

COPY docker-entrypoint.sh /docker-custom-entrypoint.sh

RUN sed -i \
        -e 's/^#\(LoadModule .*mod_deflate.so\)/\1/' \
        -e 's/^#\(LoadModule .*mod_expires.so\)/\1/' \
        -e 's/^#\(LoadModule .*mod_proxy.so\)/\1/' \
        -e 's/^#\(LoadModule .*mod_proxy_fcgi.so\)/\1/' \
        -e 's/^#\(LoadModule .*mod_rewrite.so\)/\1/' \
        -e 's/^#\(Include .*httpd-vhosts.conf\)/\1/' \
        -e 's/^#\(Include .*httpd-default.conf\)/\1/' \
		/usr/local/apache2/conf/httpd.conf \
	&& sed -i 's/^#ServerName .*/ServerName localhost/' /usr/local/apache2/conf/httpd.conf \
	&& chmod +x /docker-custom-entrypoint.sh

ENTRYPOINT ["/docker-custom-entrypoint.sh"]

CMD ["httpd-foreground"]
