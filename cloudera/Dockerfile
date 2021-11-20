FROM cloudera/quickstart:latest

USER root

COPY docker-quickstart.sh CentOS-Base.repo epel.repo *.rpm /tmp/qs-install/

WORKDIR /tmp/qs-install

RUN mv -f docker-quickstart.sh /usr/local/bin/ && \
    chmod +x /usr/local/bin/docker-quickstart.sh && \
    rm -f /usr/bin/docker-quickstart && \
    rm -f /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/epel.repo && \
    mv -f CentOS-Base.repo /etc/yum.repos.d/ && \
    mkdir /etc/repos.bak && mv /etc/yum.repos.d/cloudera* /etc/repos.bak/ && \
    yum -y '--disablerepo=*' localinstall *.rpm && \
    yum -y install nss yum && mv epel.repo /etc/yum.repos.d/ && \
    yum -y erase oracle-j2sdk1.7 && \
    yum -y install java-1.8.0-openjdk-devel gcc openssl-devel bzip2-devel nss && \
    echo 'export JAVA_HOME=/usr/lib/jvm/java' >> /etc/default/cloudera-scm-server && \
    curl -LO https://www.python.org/ftp/python/3.9.9/Python-3.9.9.tgz && \
    tar xzf Python-3.9.9.tgz && cd Python-3.9.9 && \
    ./configure --enable-optimizations && make altinstall && \
    alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.9 90 && \
    yum -y erase gcc bzip2-devel && \
    yum -y clean all && cd /root && rm -rf /tmp/qs-install

WORKDIR /root

ENTRYPOINT ["/usr/local/bin/docker-quickstart.sh"]
CMD ["start"]
