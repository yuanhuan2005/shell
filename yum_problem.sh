#!/bin/bash

createrepo -s md5 -o /opt/rhel/Server/ -g /opt/rhel/Server/repodata/1a7fc54d30d0d44222742c63069ab0126afef9f160931cc15e564dbe6414f268-comps-rhel6-Server.xml /opt/rhel/Server/
yum clean all
rm -rf /var/lib/rpm/__db*
rpm --rebuilddb
