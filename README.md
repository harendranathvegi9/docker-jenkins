# docker-jenkins

The recommended way to run this is with:

    sudo docker run --name=svds-jenkins -v /mnt/jenkins:/var/jenkins_home  -p 8080:8080 -p 50000:50000 -d svds/jenkins

Where:

 * /mnt/jenkins is a host directory that will have all the jenkins state which you want to last between reboots.
 * 8080 is the port where the jenkins web interface is served.
 * 50000 is the port where jenkins slave nodes communicate with this master.
 * -d runs it in detached mode.

When jenkins-docker starts on an empty home volume, /mnt/jenkins in this case. it fills it with the proper jenkins
directory structure, the default plugins and the secret.key and secret directory.

You should be able to see the interface by going to the public IP of the host and port 8080 if you used -p 8080:8080 and
port 1111 if you used -p 1111:8080

## Configuration

You now have a jenkins that can do, not so much.  You need to configure it for your needs.  Below is a list
of possible things you may need for your installation. The link will take you to the configuration.

 * [Artifactory](#add-artifactory) - For Artifact repository and/or maven proxy.
 * [AWS](#add-aws) - enable aws integration for jenkins user in custom scripts.
 * [GitHub Read Repo](#add-github-read-repo) - Enable reading from Github repos during builds
 * [GitHub Web Hooks](#add-github-web-hooks) - Enable builds to be triggered from GitHub on repo commits
 * [Github Pull Request](#add-github-pull-request) - Utilities to provide build and regression infomation for Pulls
 * [GPG](#add-gpg) - enable encryption in custom scripts
 * [java](#add-java) - configure JDKs
 * [Maven](#add-maven) - enable Maven Builds
 * [Slack](#add-slack) - add notifications to slack
 * [SonarQube](#add-sonarqube) - Integrate quality metrics with builds


<a id='add-artifactory'></a>
## Artifactory

If artifactory is already running then you just have to know:

 * DNS Name or IP Address of the host.
 * port it is listening on. : Instructions below default to 8081
 * User name and password with access to the repos : Instructions below default to jenkins/password
 * names of the release and snapshot repos : Instructions below default to jenkins-release and jenkins-snapshot



If not you will need to [Create a New Docker Instance of Artifactory](#New-Docker-Artifactory) as described
below.


### Setting up the Artifactory Plugin


From the top level go back into `Manage Jenkins` and pick `Manage Plugins`.   Got to the available  tab
and search for `Artifactory`  Choose that install it and any dependencies.


Then to configure go back to `Manage Jenkins` and pick `Configure System`.  Find the artifactory section.

The host port and user name and password are entered here.  The URL that
is needed is of the form http://<dns or ip>:<port>/artifactory

The repos are added to the projects.

In the projects you add a post build action of Deploy Artifacts to Artifactory.

Target release repository and snapshot repositorys can be entered directly.  instructions below assume
you are putting them in jenkins-release and jenkins-snapshot repositories.


<a id='New-Docker-Artifactory'></a>
## Create a New Docker Instance of Artifactory

You need a place on the host with three directories; data, logs, and backup as well as having docker
installed.


    sudo docker run --name svds-artifactory
            -v /mnt/artifactory/data:/artifactory/data
            -v /mnt/artifactory/logs:/artifactory/logs
            -v /mnt/artifactory/backup:/artifactory/backup -p 8081:8080 -d mattgruter/artifactory


login as Admin admin/password

### Create Repo

Logged in as admin I chose repositories. Then on the roght clicked the new button.

1. Jenkins Release
 * repository key :  jenkins-release
 * default but then unchecked the "handle snapshots" so that it only has "handle releases" checked.

2. Jenkins Snapshot
 * repository key: jenkins-snapshot
 * default but then unchecked the "handle releases" so that it only has "handle snapshots" checked.

### create Jenkins user

Logged in as admin.  I chose security/users.  Then on the right I click new.

"New User" dialog:

 * User Name : jenkins
 * email Address : larry@svds.com
 * password : password
 * left the bottom check boxes to only check can update Profile.

### create CI Permissions Group

Loggied in as admin. I chose security/Permissions.  Then on the right I pick new.

"New Permission Target" Dialog:

 * Name: ci-permissions
 * unchecked any local repository and added only jenkins-release and jenkins-snapshot

###  Add The Server To Jenkins

[Go back and Add Artifactory to Jenkins](#add-artifactory)


<a id='add-aws'></a>
## AWS Integration

<a id='add-github-read-repo'></a>
## Git Hub - Read Repo Ability

<a id='add-github-web-hooks'></a>
## Git Hub - Web hooks - Git Hub pushes build with Repo Commit Ability

<a id='add-github-pull-request'></a>
## Git Hub - Pull Request - Utilities to Build and Regress Pull Requests

<a id='add-gpg'></a>
## GPG Integration - encrypting files for deployment with GPG

<a id='add-java'></a>
## Java - Set up JDKs for your Java Programs

<a id='add-maven'></a>
## Maven - Set up Jenkins for Maven Builds

<a id='add-slack'></a>
## Slack - Add notifications to Slack

<a id='add-sonarqube'></a>
## SonarQube Integration - Add Quality Metrics to your Builds

