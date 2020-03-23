# hdp265_client_bionic_hbase_hadoop - With KERBEROS

DOCKER Hortonworks Data Platform 2.6.5 Client Template

## Docker for HDFS and HBASE with Rest and Thrift Server to run against a cluster.

This Docker container is based on ubuntu:bionic running a HDP 2.6.5 as edge/application node.

### Prerequisites - hadoop-conf files and Keytab files 

It is needed to get from the environment that it is being connected the following files and add to the following directories before run docker build.

Update krb5.conf according to the kerberos server that you are connecting.

hadoop-env.sh and hbase-env.sh are standard files for the container.

```
├── hadoop-conf
│   ├── hadoop_conf
│   │   ├── core-site.xml
│   │   ├── hdfs-site.xml
│   │   └── log4j.properties
│   ├── hbase_conf
│   │   ├── hbase-policy.xml
│   │   ├── hbase-site.xml
│   │   ├── hbase_client_jaas.conf
│   │   └── log4j.properties
│   └── krb5.conf
└── keytabs
    ├── hbase.service.keytab
    └── spnego.service.keytab
```

### Building Dockerfile

It is very important to define the same FQDN (FULL HOSTNAME) used to create the Keytabs

```
DOCKER_HOSTNAME="docker01.is.net"

docker build -t hdp265-docker-edge .

docker run -it -d -p 16010:16010 -p 9090:9090 -p 9091:9091 -p 8080:8080 -p 8085:8085 -p 2181:2181 --name=hdp265-docker-edge -h $DOCKER_HOSTNAME  hdp265-docker-edge:latest

docker exec -it hdp-docker-edge /bin/bash

```
Updtae /etc/hosts adding DOCKER_HOSTNAME and the current Docker IP.

## Running HBASE Thrift and REST server

Authentication with kerberos using the hbase keytab corresponding FQDN (docker01.is.net).

PS: HBASE and SPNEGO KEYTAB must be created by Kerberos System Administrator

```
kinit -kt /etc/security/keytabs/hbase.service.keytab hbase/$DOCKER_HOSTNAME@EXAMPLE.COM

/usr/hdp/2.6.5.0-292/hbase/bin/hbase-daemon.sh restart thrift -p 9090 --infoport 9091

/usr/hdp/2.6.5.0-292/hbase/bin/hbase-daemon.sh restart rest -p 17000 --infoport 17001
```

### Test HBASE Thrift and REST servers


```
hbase org.apache.hadoop.hbase.thrift.HttpDoAsClient docker01.is.net 9090 hbase true

curl --negotiate -u : 'http://docker01.is.net:17000/status/cluster'
```

