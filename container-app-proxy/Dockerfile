FROM haproxy:2.9-alpine

COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

EXPOSE 8080

CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]