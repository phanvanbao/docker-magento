FROM nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY snippets /etc/nginx/snippets
COPY docker-entrypoint.sh /docker-entrypoint.d/docker-entrypoint-custom.sh
COPY local-ssl-entrypoint.sh /docker-entrypoint.d/local-ssl-entrypoint.sh

RUN chmod +x /docker-entrypoint.d/docker-entrypoint-custom.sh \
	&& chmod +x /docker-entrypoint.d/local-ssl-entrypoint.sh
