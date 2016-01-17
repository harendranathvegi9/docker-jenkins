FROM jenkins:1.625.3
MAINTAINER Larry Murdock "larry@svds.com"
USER root
RUN apt-get update \
  && apt-get install -y npm \
  && apt-get install -y nodejs

RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN echo "172.31.19.128 delorean.svds.io maven.svds.io"  >> /etc/host

USER jenkins
ENV THUNDERBIRDS GO
