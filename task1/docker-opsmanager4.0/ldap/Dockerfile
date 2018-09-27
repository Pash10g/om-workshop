FROM ubuntu:16.04

# Install and configure OpenLDAP binaries
ENV DEBIAN_FRONTEND=noninteractive
ADD ldap/slapd-deb.conf /tmp
RUN apt-get update && \
    cat /tmp/slapd-deb.conf | debconf-set-selections && \
    apt-get install ldap-utils slapd -y

# Copy ldif files and configure memberOf overlay, users and groups
ADD ldif/*.ldif /tmp/
RUN service slapd start \
    && ldapsearch -x -w DontChangeMe1 -D cn=admin,dc=babypearfoo,dc=com -b dc=babypearfoo,dc=com \
    && ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/memberof.ldif \
    && ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/refint.ldif \
    && ldapadd -x -D cn=admin,dc=babypearfoo,dc=com -w DontChangeMe1 -f /tmp/users.ldif \
    && ldapadd -x -D cn=admin,dc=babypearfoo,dc=com -w DontChangeMe1 -f /tmp/groups.ldif \
    && rm -rf /tmp/slapd-deb.conf /tmp/*.ldif \
    && ldapsearch -x -w DontChangeMe1 -D cn=admin,dc=babypearfoo,dc=com -b dc=babypearfoo,dc=com '(uid=onprem-admin-e2e-test@10gen.com)' \
    && ldapsearch -x -w DontChangeMe1 -D cn=admin,dc=babypearfoo,dc=com -b dc=babypearfoo,dc=com

# EXPOSE 389

CMD /usr/sbin/slapd -d 1 -h 'ldap:/// ldapi:///' -g openldap -u openldap -F /etc/ldap/slapd.d
