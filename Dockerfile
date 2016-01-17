FROM jenkins:1.625.3
MAINTAINER Larry Murdock "larry@svds.com"

USER root
RUN apt-get update \
      && apt-get install -y npm \
      && apt-get install -y nodejs \
      && apt-get install -y sudo 

RUN ln -s /usr/bin/nodejs /usr/bin/node

USER jenkins
ENV THUNDERBIRDS GO

