FROM ubuntu:14.04
MAINTAINER HC


# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y vim nano git wget libfreetype6 libfontconfig bzip2 supervisor zip unzip openssh-server make g++ patch zlib1g-dev libgif-dev && \
  mkdir -p /srv/var /var/log/supervisor /opt

RUN \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y wget apt-transport-https software-properties-common python python-software-properties g++ make && \
  wget -qO- https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
  echo 'deb https://deb.nodesource.com/node precise main' > /etc/apt/sources.list.d/nodesource.list && \
  echo 'deb-src https://deb.nodesource.com/node precise main' >> /etc/apt/sources.list.d/nodesource.list && \
  apt-get update && \
  apt-get install -y nodejs && \
  #apt-get purge -y wget apt-transport-https software-properties-common python python-software-properties g++ make && \
  apt-get autoremove -y && \
  apt-get clean all

ENV PATH $PATH:/nodejs/bin
RUN node -v

ENV TERM=xterm-color


RUN apt-get update; \
    apt-get install -y wget openssh-server && \
    npm install pm2 -g && \
    apt-get autoremove -y && \
    apt-get clean all


# ----------- Install java 7 -------------
RUN \
wget -c -O "jdk-7u79-linux-x64.tar.gz" --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.tar.gz" && \

	tar -zxvf  jdk-7u79-linux-x64.tar.gz -C /  && \
	rm jdk-7u79-linux-x64.tar.gz  && \
	mv /jdk1.7.0_79 /jdk

# ------------ Port for collectorApp.js ---------
EXPOSE 930


EXPOSE 22

# ----------- Create directory for app.js-------------
RUN mkdir -p /opt/nodejs/sender/
RUN mkdir -p /opt/nodejs/tmp/
RUN mkdir -p /opt/java/


# ----------- Add Files to directory for app.js-------------
ADD collector-sender-app/* /opt/nodejs/
ADD collector-sender-app/sender/* /opt/nodejs/sender/
ADD collector-sender-app/tmp/* /opt/nodejs/tmp/

ADD collector-sender-app/analyzer/* /opt/java/




# ----------- Configure SSH -------------
#RUN echo deb http://archive.ubuntu.com/ubuntu trusty main universe > /etc/apt/sources.list.d/trusty.list

# Clean
ADD es_docker_key.pub es_docker_key.pub
#RUN \
#  mkdir ~/.ssh && \
#  touch ~/.ssh/authorized_keys && \
#  cat es_docker_key.pub >> ~/.ssh/authorized_keys && \
#  rm es_docker_key.pub && \
#  /etc/init.d/ssh restart
RUN mkdir ~/.ssh && touch ~/.ssh/authorized_keys & cat es_docker_key.pub
    #  rm es_docker_key.pub && \
    #  /etc/init.d/ssh restart


RUN echo 'root:3asyso1' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

ADD init.sh /init.sh

RUN chmod 777 /init.sh
RUN cd /opt/nodejs; npm install
# ------------ Port for collectorApp.js ---------
EXPOSE 9301



 ENV JAVA_HOME /jdk
 ENV JRE_HOME  $JAVA_HOME/jre
 ENV PATH $PATH:$JAVA_HOME/bin
 RUN java -version

RUN pm2 startup ubuntu
CMD ["sh","/init.sh"]
RUN echo "finish"
