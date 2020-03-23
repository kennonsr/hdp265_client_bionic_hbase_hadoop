FROM ubuntu:bionic

MAINTAINER Kennon <kennonsr@>
LABEL version="hdp265_client_bionic_hbase_hadoop"

USER root

# Install system tools
#   apt-get -y upgrade && \

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y vim sudo curl git htop man unzip nano wget mlocate openssl net-tools && \
  rm -rf /var/lib/apt/lists/*

# Kerberos client
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq krb5-user -y
RUN mkdir -p /var/log/kerberos
RUN mkdir -p /etc/security/keytabs/
RUN touch /var/log/kerberos/kadmind.log
ADD hadoop-conf/krb5.conf /etc/
ADD keytabs/* /etc/security/keytabs/

#ARG DEBIAN_FRONTEND=noninteractive
RUN \
   apt-get update && \
   DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
RUN echo "Europe/Amsterdam" >  /etc/timezone
RUN rm -rf /var/lib/apt/lists/*

# Install Java - OpenJDK8

RUN \
  apt-get update && \
  apt-get install -y  openjdk-8-jdk && \
  rm -rf /var/lib/apt/lists/* && \
  Javadir=$(dirname $(dirname $(readlink -f $(which javac)))) && \
  java -version

# Define commonly used JAVA_HOME variable

ENV JAVA_HOME $Javadir

# Install Python.

RUN \
  apt-get update && \
  apt-get install -y python python3 python-dev python-pip python-virtualenv && \
  pip install happybase && \
  rm -rf /var/lib/apt/lists/*

# Add HDP 2.6.5 Repositories to source.lists.d

RUN wget http://public-repo-1.hortonworks.com/HDP/ubuntu16/2.x/updates/2.6.5.0/hdp.list -P  /etc/apt/sources.list.d/
RUN  DEBIAN_FRONTEND=noninteractive apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD
RUN  apt-get update

# Add HDP 2.6.5 Client Packages

RUN \
  apt-get update && \
  apt-get install -y hdp-select && \
  rm -rf /var/lib/apt/lists/*

RUN \
  apt-get update && \
  apt-get install -y hadoop hadoop-hdfs libhdfs0 hadoop-client \
  hbase hbase-rest hbase-thrift \
  zookeeper  && \
  rm -rf /var/lib/apt/lists/*

RUN usermod -s /bin/bash zookeeper
RUN mkdir -p /data/hbase_tmp

# HADOOP CLUSTER CONF
ADD hadoop-conf/hadoop_conf/ /etc/hadoop/conf/
ADD hadoop-conf/hbase_conf/ /etc/hbase/conf/
#ADD hadoop_conf_ite/hive_conf/ /etc/hive/conf/
#ADD hadoop_conf_ite/hive_conf/ /etc/hive2/conf/
#RUN mkdir -p /var/log/spark/lineage && chown spark:hadoop /var/log/spark/lineage
RUN chown hdfs:hadoop -R /etc/hadoop
RUN chown hbase:hadoop -R /etc/hbase

# SPARK ENV AND PORTS
#ENV SPARK_MASTER local[*]
#ENV SPARK_DRIVER_PORT 38001
#ENV SPARK_UI_PORT 38002
#ENV SPARK_BLOCKMGR_PORT 38003
#ENV SPARK_DRIVER_HOST $(hostname -f)
#ENV SPARK_DRIVER_HOST app1300.infra.local
#EXPOSE $SPARK_DRIVER_PORT $SPARK_UI_PORT $SPARK_BLOCKMGR_PORT

#custom TERM
RUN  echo 'PS1="\[$(tput bold)\]\[\033[38;5;193m\]>>>\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;192m\]\u\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]@\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;117m\]\H\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]:[\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;223m\]\w\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]]:[\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;192m\]\T\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]]\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]{\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;208m\]\$?\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]}\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;193m\]>>>\[$(tput sgr0)\]\[\033[38;5;15m\]\n\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;9m\]\\$\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"' >> /etc/bash.bashrc
RUN  echo 'PS1="\[$(tput bold)\]\[\033[38;5;193m\]>>>\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;192m\]\u\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]@\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;117m\]\H\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]:[\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;223m\]\w\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]]:[\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;192m\]\T\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]]\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]{\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;208m\]\$?\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]}\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;193m\]>>>\[$(tput sgr0)\]\[\033[38;5;15m\]\n\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;9m\]\\$\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"' >> ~/.bashrc

#ENTRYPOINT
ENTRYPOINT ["/bin/bash"]
