ARG VERSION=v3.2.1

FROM prom/prometheus:${VERSION}

COPY --chmod=0644 prom.yml.tpl /etc/prometheus/prom.yml.tpl
COPY --chmod=0755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["--config.file=/etc/prometheus/prom.yml", "--storage.tsdb.path=/prometheus"]

