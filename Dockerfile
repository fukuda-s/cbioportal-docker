# cBioPortal (Standalone)
# 
# VERSION       0.1
#
#
# No copyright, license, warranty, or support.
#
# Required: 
#  docker-compose (>= 1.23.1)
#
# Run: 
#  docker-compose up
#       (load http://localhost:8080 with your favorite web browser) 

FROM tomcat:9-jre11

MAINTAINER Shiro FUKUDA

WORKDIR /root

#### Install git, patch, openjdk-8-jdk and python3 ####
RUN apt-get update && \
		apt-get install -y --no-install-recommends \
			git \
      patch \
   		openjdk-8-jdk \
		  python3 \
      python3-dev \
      python3-pip \
      default-libmysqlclient-dev \
		  python3-jinja2 \
		  python3-mysqldb \
		  python3-requests

RUN python3 -m pip install mysqlclient

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Install Connector/J 8
RUN curl -L -O https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java_8.0.13-1ubuntu18.10_all.deb && \
		dpkg -i mysql-connector-java_8.0.13-1ubuntu18.10_all.deb && \
		cp /usr/share/java/mysql-connector-java-8.0.13.jar $CATALINA_HOME/lib/mysql-connector-java.jar
ENV CONNECTOR_JAR $CATALINA_HOME/lib/mysql-connector-java.jar

# Install Maven 3.6
RUN curl -L -O http://ftp.jaist.ac.jp/pub/apache/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz && \
		cd /usr/local && tar xzf /root/apache-maven-3.6.0-bin.tar.gz && \
		ln -s /usr/local/apache-maven-3.6.0 /usr/local/maven
ENV PATH $PATH:/usr/local/maven/bin

# REQUIRED: Register the jdbc connector for cbioportal 
ADD tomcat_context.xml $CATALINA_HOME/conf/context.xml

# Setup cbioportal compilation
RUN mkdir -p /root/.m2
ADD maven_settings.xml  /root/.m2/settings.xml

# Setup cbioportal
RUN git clone https://github.com/cBioPortal/cbioportal.git

ENV PORTAL_HOME /root/cbioportal

ADD log4j.properties $PORTAL_HOME/src/main/resources/log4j.properties
ADD portal.properties $PORTAL_HOME/src/main/resources/portal.properties

WORKDIR $PORTAL_HOME

RUN mvn -DskipTests clean install
RUN cp $PORTAL_HOME/portal/target/cbioportal.war $CATALINA_HOME/webapps/cbioportal.war

# Setup Tomcat
#RUN echo 'CATALINA_OPTS="-Dauthenticate=false $CATALINA_OPTS -Ddbconnector=dbcp"' >>$CATALINA_HOME/bin/setenv.sh
RUN echo 'CATALINA_OPTS="-Dauthenticate=false $CATALINA_OPS"' >>$CATALINA_HOME/bin/setenv.sh
COPY ./catalina_server.xml.patch /root/
RUN patch $CATALINA_HOME/conf/server.xml </root/catalina_server.xml.patch

# Add importer scripts to PATH for easy running in containers
RUN find $PORTAL_HOME/core/src/main/scripts/ -type f -executable \! -name '*.pl'  -print0 | xargs -0 -- ln -st /usr/local/bin
# Migrate DB
COPY migrate_db.sh /root
ENTRYPOINT ["/bin/bash", "-c", "/root/migrate_db.sh"]
