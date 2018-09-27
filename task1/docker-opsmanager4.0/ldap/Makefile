IMAGE = mongodb/openldap-test-server
CONTAINER = openldap-test-server

usage:
	@ echo "MongoDB OpenLDAP test server, preconfigured with users/groups"
	@ echo
	@ echo "Usage:"
	@ echo "  fresh:	      performs a clean rebuild and runs the OpenLDAP container"
	@ echo "  clean: 	      deletes any existing containers/images"
	@ echo "  build: 	      builds/re-builds the Docker image"
	@ echo "  run: 		      runs a previously built Docker image"
	@ echo "  shell: 		  connects to a running container"
	@ echo "  clean-build:    runs the clean target and rebuilds the image without intermediary containers"
	@ echo "  copy-overrides: copies the LDAP Ops Manager property override file into server/conf"
	@ echo

clean:
	- docker rm -f $(CONTAINER)
	- docker rmi $(IMAGE)

build:
	docker build $(EXTRA_PARAM) -t $(IMAGE) .

clean-build:
	@ $(MAKE) EXTRA_PARAM="--force-rm --rm" clean build

run:
	@ docker run --rm -i --name $(CONTAINER) -p 1389:389 -t $(IMAGE)

fresh: 
	$(MAKE) clean build run

copy-overrides:
	@ cp ldap/ldap-overrides.properties ../../../server/conf/
	@ echo "Deployed override file at: "`cd ../../../server/conf/ && pwd -P`/ldap-overrides.properties
	@ echo "Start MMS with: ant... -Dmms.extraPropFile=ldap-overrides.properties"
	@ echo

shell:
	docker exec -it $(CONTAINER) /bin/bash
