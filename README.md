# docker-jenkins

Things that need to be in the install to run our projects.


    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get -y install openjdk-7-jdk
    sudo apt-get -y install apache2

    wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
    sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
    sudo apt-get update
    sudo apt-get -y install jenkins
    sudo apt-get -y install git

Jenkins home is in /var/lib/jenkins

    sudo apt-get install -y npm

    sudo apt-get install -y node

    sudo apt-get install -y nodejs-legacy


    sudo apt-get install unzip
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
    unzip awscli-bundle.zip
    sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws



Trying to pull together a jenkins command to start up jenkins.

Usind the code in

/etc/inid.d/jenkins and /etc/default/jenkins


This is the line that gets executed

    $SU -l $JENKINS_USER --shell=/bin/bash -c "$DAEMON $DAEMON_ARGS -- $JAVA $JAVA_ARGS -jar $JENKINS_WAR $JENKINS_ARGS" || return 2


$SU is /bin/su from the /etc/init.d/jenkins

That turns into USER

The environment variables in /etc/default/jenkins I create ENV variables here

    USER jenkins

    ENV NAME jenkins
    # Allow graphs etc. to work even when an X server is present
    ENV JAVA_ARGS "-Djava.awt.headless=true"
    ENV JENKINS_WAR "/usr/share/jenkins/jenkins.war"
    ENV JENKINS_HOME "/var/lib/jenkins"
    ENV RUN_STANDALONE "true"
    ENV JENKINS_LOG=/var/log/jenkins/jenkins.log
    ENV MAXOPENFILES 8192
    ENV HTTP_PORT 8080
    ENV AJP_PORT=-1
    ENV PREFIX /jenkins
    ENV JENKINS_ARGS "--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT --ajp13Port=$AJP_PORT"

    ENTRYPOINT ["java","$JAVA_ARGS","-jar","$JENKINS_WAR","JENKINS_ARGS"]




Here is my attempt at a fat ubuntu docker file that stays out of my way.  Turns out it can't install jenkins because the
packages wants to stat the service and then set up certs.  So the dockerfile you see just mods the jenkins official dockerfile.

One annoying thing about the dockerfile is that it runs as jenkins and does not have sudo or even an editor.  But maybe since its perfect...
we can live with that. Debugging with it is a pain.

    FROM ubuntu:14.04
    MAINTAINER Larry Murdock "larry@svds.com

    RUN apt-get install -y wget

    RUN wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add - \
     && sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'

    RUN apt-get update && apt-get install -y \
        openjdk-7-jdk \
        apache2 \
        git \
        npm \
        nodejs-legacy \
        jenkins \
        unzip \
        curl \
     && apt-get clean \
     && rm -rf /var/lib/apt/lists/*

    RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" \
        unzip awscli-bundle.zip \
        ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

    # for main web interface:
    EXPOSE 8080

    # will be used by attached slave agents:
    EXPOSE 50000
    ENV SLAVE_AGENT_PORT 50000


    # Jenkins home directory is a volume, so configuration and build history
    # can be persisted and survive image upgrades
    VOLUME /var/lib/jenkins

    USER jenkins

    ENV NAME jenkins
    # Allow graphs etc. to work even when an X server is present
    ENV JAVA_ARGS "-Djava.awt.headless=true"
    ENV JENKINS_WAR "/usr/share/jenkins/jenkins.war"
    ENV JENKINS_HOME "/var/lib/jenkins"
    ENV RUN_STANDALONE "true"
    ENV JENKINS_LOG "/var/log/jenkins/jenkins.log"
    ENV MAXOPENFILES 8192
    ENV HTTP_PORT 8080
    ENV AJP_PORT -1
    ENV PREFIX "/jenkins"
    ENV JENKINS_ARGS "--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT --ajp13Port=$AJP_PORT"

    ENTRYPOINT ["java","$JAVA_ARGS","-jar","$JENKINS_WAR","JENKINS_ARGS"]