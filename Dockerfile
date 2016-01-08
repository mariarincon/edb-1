FROM ubuntu:14.04

MAINTAINER Reinaldo Calderón

# ----------- Commands -------------
RUN \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y vim nano git wget libfreetype6 libfontconfig bzip2 supervisor zip unzip openssh-server && \
  mkdir -p /srv/var /var/log/supervisor /opt

ENV TOMCAT_VERSION 8.0.23
ENV TOMCAT_PORT 8080
ENV TOMCAT_PATH /opt/tomcat

# ----------- Install java 8 -------------
RUN apt-get -y install software-properties-common
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get -y update
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 boolean true" | debconf-set-selections
RUN apt-get -y install oracle-java7-installer
RUN apt-get install oracle-java7-set-default

# ----------- Install tomcat -------------
RUN \
  wget -O /tmp/tomcat.tar.gz http://archive.apache.org/dist/tomcat/tomcat-8/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz && \
  cd /tmp && \
  tar zxf /tmp/tomcat.tar.gz && \
  ls /tmp && \
  mv /tmp/apache-tomcat* $TOMCAT_PATH && \
  rm -rf $TOMCAT_PATH/webapps/*.* && \
  rm -rf $TOMCAT_PATH/webapps/* && \
  rm /tmp/tomcat.tar.gz

EXPOSE $TOMCAT_PORT
EXPOSE 22

# ----------- Configure SSH -------------

#RUN echo deb http://archive.ubuntu.com/ubuntu trusty main universe > /etc/apt/sources.list.d/trusty.list

# Clean
ADD es_docker_key.pub es_docker_key.pub

RUN \
  mkdir ~/.ssh && \
  touch ~/.ssh/authorized_keys && \
  cat es_docker_key.pub >> ~/.ssh/authorized_keys && \
  rm es_docker_key.pub && \
  /etc/init.d/ssh restart

# Files
ADD tomcat_supervisord_wrapper.sh $TOMCAT_PATH/bin/tomcat_supervisord_wrapper.sh
RUN chmod 755 $TOMCAT_PATH/bin/tomcat_supervisord_wrapper.sh

# Set the locale
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  


# Start
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]
