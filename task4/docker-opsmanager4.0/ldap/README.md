# Test LDAP server

These scripts can be used to test Ops Manager - LDAP integrations.  I will spin up a Docker container which contains a pre-configured instance of OpenLDAP.

### Quickstart

1\. Install [Docker](https://www.docker.com/get-docker)

2\. Run `make fresh` to build and run the image

3\. [optional] Execute the the LDAP directory integration tests in MMS:

```
cd /mms/server
ant mms.test.single -Dtest=com.xgen.svc.mms.svc.user.UserSvcLdapDirectoryIntTests -Djvm.extra.arg=-DuseLocalLdapServer=true
```

### Additional commands

- Test the OpenLDAP deployment 
  `ldapsearch -h localhost -p 1389 -b dc=babypearfoo,dc=com -W -x -D cn=admin '(uid=cnelson)' memberof dn`

- See the available OpenLDAP build options
  `make`

- Deploy an overrides file that can be passed to MMS with `-Dmms.extraPropFile=ldap-overrides.properties`
  `make copy-overrides`

- Test accounts:

```
admin:Password1!
cnelson:Password1!
bbloom:Password1!
cmintz:Password1!
```

### References

- https://wiki.corp.mongodb.com/display/MMS/MMS+OpenLDAP+Test+Server
