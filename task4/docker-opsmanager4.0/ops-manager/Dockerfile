FROM ubuntu:14.04

MAINTAINER Anthony Lapenna <lapenna.anthony@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN apt-get update && apt-get install -y curl supervisor openssl

COPY src/mongodb-mms-server* /tmp/

RUN cd /tmp \
	&& dpkg -i mongodb-mms-server*

RUN service rsyslog start

COPY config/conf-mms.properties /opt/mongodb/mms/conf/conf-mms.properties
COPY config/conf-deamon.properties /opt/mongodb/mms-backup-daemon/conf/conf-daemon.properties

RUN mkdir -p /var/lib/mongodb/backup/

RUN mkdir -p /snapshots/

RUN chown mongodb-mms:mongodb-mms /var/lib/mongodb/backup/

RUN chown mongodb-mms:mongodb-mms /snapshots/

COPY config/supervisord.conf /etc/supervisor/conf.d/ops-manager.conf

COPY startup.sh /tmp/startup.sh
RUN chmod +x /tmp/startup.sh

ENTRYPOINT [ "/tmp/startup.sh" ]
