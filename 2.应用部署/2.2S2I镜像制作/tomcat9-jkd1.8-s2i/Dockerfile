# tomcat9-jdk1.8-s2i
FROM openshift/base-centos7

ENV appname NONE
ENV env NONE
ENV url NONE
#ENV war NONE
ENV http NONE

LABEL io.openshift.s2i.scripts-url=image:///usr/libexec/s2i \
    io.k8s.description="Tomcat9 S2I builder" \
    io.k8s.display-name="tomcat s2i builder 1.0" \
    io.openshift.expose-services="8080:http" \ 
    io.openshift.tags="builder,tomcat9"

RUN mkdir -p /etc/yum.repos.d/
RUN mkdir -p /usr/local/
ADD local-mirror.repo /etc/yum.repos.d/

RUN yum -y install curl vim net-tools wget java unzip maven
ENV BUILDER_VERSION 1.0
COPY apache-tomcat-9.0.2.tar.gz /tmp

RUN tar -xvf /tmp/apache-tomcat-9.0.2.tar.gz -C /opt/
RUN mkdir -p /opt/app-root
RUN mv /opt/apache-tomcat-9.0.2 /opt/app-root/tomcat

#RUN useradd -m tomcat -u 1001 && chmod -R a+rwx /usr/local/tomcat

#RUN chown -R 1001:0 /opt/app-root
#RUN chown -R 1001:0 $HOME
RUN chmod -R 777 /opt/app-root
RUN chown -R 1001:0 /opt/app-root
RUN rm -rf /opt/app-root/tomcat/webapps/*

RUN mkdir -p /usr/local/tomcat/logs
RUN chmod -R 777 /usr/local/tomcat/
RUN chown -R 1001:0 /usr/local/tomcat/

COPY ./s2i/bin/ /usr/libexec/s2i

USER 1001
EXPOSE 8080
#ENTRYPOINT []
#CMD ["usage"]
#ADD run.sh /opt/
CMD ["/usr/libexec/s2i/usage"]
#CMD /opt/run.sh $appname $env $url $http



#FROM openshift/base-centos7

# TODO: Put the maintainer name in the image metadata
# MAINTAINER Your Name <your@email.com>

# TODO: Rename the builder environment variable to inform users about application you provide them
# ENV BUILDER_VERSION 1.0

# TODO: Set labels used in OpenShift to describe the builder image
#LABEL io.k8s.description="Platform for building xyz" \
#      io.k8s.display-name="builder x.y.z" \
#      io.openshift.expose-services="8080:http" \
#      io.openshift.tags="builder,x.y.z,etc."

# TODO: Install required packages here:
# RUN yum install -y ... && yum clean all -y
#RUN yum install -y rubygems && yum clean all -y
#RUN gem install asdf

# TODO (optional): Copy the builder files into /opt/app-root
# COPY ./<builder_folder>/ /opt/app-root/

# TODO: Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image
# sets io.openshift.s2i.scripts-url label that way, or update that label
#COPY ./s2i/bin/ /usr/libexec/s2i

# TODO: Drop the root user and make the content of /opt/app-root owned by user 1001
# RUN chown -R 1001:1001 /opt/app-root

# This default user is created in the openshift/base-centos7 image
#USER 1001

# TODO: Set the default port for applications built using this image
# EXPOSE 8080

# TODO: Set the default CMD for the image
# CMD ["/usr/libexec/s2i/usage"]
