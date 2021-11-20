FROM hortonworks/sandbox-hdp:2.6.5

USER root

COPY assets/systemctl.py /usr/bin/systemctl
COPY assets/docker-start.sh /usr/local/bin/
RUN chmod a+x /usr/bin/systemctl && \
    chmod +x /usr/local/bin/docker-start.sh

CMD ["/usr/local/bin/docker-start.sh"]
