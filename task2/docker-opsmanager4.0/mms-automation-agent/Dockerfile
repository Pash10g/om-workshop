FROM ubuntu:16.04
MAINTAINER pavel duchovny "pavel.duchovny@mongodb.com"

RUN apt-get -qqy update && \
    apt-get install -qqy \
        curl \
        ca-certificates \
        libsasl2-2 \
        numactl \
        openssl \
        rsyslog \
        vim \
        sudo\
        netcat

RUN apt-get -qqy install libcurl3 libgssapi-krb5-2 libkrb5-dbg libldap-2.4-2 libpcap0.8 libpci3 libsasl2-2 libsensors4 libsnmp30 libssl1.0.0 libwrap0

#VOLUME /var/lib/mongodb-mms-automation



#ADD http://opsmanager:8080/download/agent/automation/mongodb-mms-automation-agent-manager_latest_amd64.deb /root/mongodb-mms-automation-agent-manager_latest_amd64.deb

#RUN dpkg -i /root/mongodb-mms-automation-agent-manager_latest_amd64.deb

#Setting /var/lib permissions
RUN chmod -R 777 /var/lib/

RUN service rsyslog start

# MMS automation
# MongoDB data volume
VOLUME /data


RUN mkdir -p  /etc/mongodb/ssl

COPY src/rootCA.pem /etc/mongodb/ssl/rootCA.pem
COPY src/root.crt /etc/mongodb/ssl/root.crt
COPY src/root.key /etc/mongodb/ssl/root.key

RUN chmod 600 /etc/mongodb/ssl/rootCA.pem

COPY startup.sh /tmp/startup.sh
RUN chmod +x /tmp/startup.sh

COPY src/local.config /data/automation-agent.config

COPY config/disable-transparent-hugepages /etc/init.d/disable-transparent-hugepages

RUN chmod 755 /etc/init.d/disable-transparent-hugepages

RUN update-rc.d disable-transparent-hugepages defaults

ENTRYPOINT [ "/tmp/startup.sh" ]
