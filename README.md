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
 * [GitHub Key Security](#add-github-keys) - Enable access to private GitHub repos
 * [GitHub Web Hooks](#add-github-web-hooks) - Enable builds to be triggered from GitHub on repo commits
 * [Github Pull Request](#add-github-pull-request) - Utilities to provide build and regression infomation for Pulls
 * [GPG](#add-gpg) - enable encryption in custom scripts
 * [java](#add-java) - configure JDKs
 * [Maven](#add-maven) - enable Maven Builds
 * [Slack](#add-slack) - add notifications to slack
 * [SonarQube](#add-sonarqube) - Integrate quality metrics with builds

Appendix

 * [Create a New Artifactory Instance](#New-Docker-Artifactory)


<a id='add-artifactory'></a>
## Artifactory

If artifactory is already running then you just have to know:

 * DNS Name or IP Address of the host.
 * port it is listening on. : Instructions below default to 8081
 * User name and password with access to the repos : Instructions below default to jenkins/password
 * names of the release and snapshot repos : Instructions below default to jenkins-release and jenkins-snapshot



If not you will need to [Create a New Docker Instance of Artifactory](#New-Docker-Artifactory) as described
in the link to the appendix.


#### Setting up the Artifactory Plugin


From the top level go back into `Manage Jenkins` and pick `Manage Plugins`.   Got to the available  tab
and search for `Artifactory`  Choose that install it and any dependencies.


Then to configure go back to `Manage Jenkins` and pick `Configure System`.  Find the artifactory section.

The host port and user name and password are entered here.  The URL that
is needed is of the form http://<dns or ip>:<port>/artifactory

The repos are added to the projects.

In the projects you add a post build action of Deploy Artifacts to Artifactory.

Target release repository and snapshot repositorys can be entered directly.  instructions below assume
you are putting them in jenkins-release and jenkins-snapshot repositories.




<a id='add-aws'></a>
## AWS Integration

AWS tools are installed on this Docker Image.  If you want to use them you have to configure it
for your container.  These configurations are in the host volume for jenkisn home and so it will
survive loading a new container of this image.

To configure it you could:

    sudo docker exec -it svds-jenkins bash

and then run `aws configure`.

But you could go to the host mount point where the jenkins home is located and add a `.aws` directory
and then a `config` file with the following content. Please put your own key and secrets

    [default]
    aws_access_key_id=AYOURACCESSKEYA
    aws_secret_access_key=MOZsw3uYOURSECRETHuvrZGc

If you want to test whether it works..

    sudo docker exec -it svds-jenkins bash

And then you will be logged in as jenkins so:

    aws s3 ls

Will list what you have on S3.

<a id='add-github-read-repo'></a>
## Git Hub - Read Repo Ability

Git is installed on this Image.

In order to be able to read github repos you have to add the github plugin.

In a browser in the Jenkins Web site, at top level go back into `Manage Jenkins` and pick `Manage Plugins`.
Got to the available  tab and search for `github plugin`  Choose that and it will atomagically load a bunch
of plugins.  namely

 * Github API Plugin
 * Credentials Plugin (already on)
 * SSH Credentials Plugin (already on)
 * Git Client plugin
 * SCM API Plugin
 * Mailer Plugin (already on)
 * JUnit Plugin (already on)
 * Matrix Project plugin (already on)
 * Git Plugin
 * Token Macro Plugin
 * Plain Credentials Plugin
 * GitHub Plugin

Once that is available you can pull your source down from github as well as use git repositories.  When you create a
job, git will show as one of the Source Code Management Options.  Choosing git will bring up a url line where you can
enter the repo url.

<a id='add-github-keys'></a>
## Git Hub - Key Security - enable acces to Private GitHub repos

If you have private repos on github and/or you want to use the ssh url then you need to get your jenkins set up with
ssh keys that have permissions on Github.

In the Host directory which is used as the Jenkin's home by the Jenkins container, you need to configure the .ssh
directory.

Github lets you set up keys for a user as well as repo keys.

First log into your container.

    sudo docker exec -it svds-jenkins bash

Then

    mkdir ~/.ssh
    chmod 700 ~/.ssh
    ssh-keygen -t rsa -b 4096 -C "your@email.here" -f ~.ssh/id_rsa

This will create two files `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub` You'll want to copy and paste the pub info into your
github account.  Since the docker image doesn't have an editor just `cat ~/.ssh/id_rsa.pub` and then select and copy the
text.  Note the documentation suggests creating a jenkins user that has push access to your repos. This is a really good
idea since the user name is going to show in any pushed comments.

Go to your account on git hub and then:

    1. Go to settings under your profile
    2. chose ssh keys
    3. click add ssh key
    4. paste what you copied before.
    5. Give it a name...
    6. click add key.

Alternatively or additionally, you can create keys that are tied to the repo.  To do that you need to be an owner of the
repo.  Once you are an owner, at the repo page there is a tab for settings.  Under settings chose *deploy keys* and then
add in a similar way.

If you have more than one repo you have to have more than one "deploy keys". Dont forget to check the write priveledge
box on the deploy key entry if you intend to enter commit notes back into github from jenkins. Each deploy key has to be
unique on github. It will not let you add the same key to another repo.

Once you have your keys in place and have linked them to your account with priviledges on the repo.  You can go into the
configuration for a project.  Chose git for your source code management and then enter the url in the repository line.

This should error if its private and you have to add a credential.  Click add and:

 * Kind:  SSH Username with private key
 * scope leave as global
 * username: jenkins
 * private key : From a file omn Jenkins master
   * file : /var/jenkins_home/.ssh/your_rsa
 * Desription - This will be what you see in the list of possible credentials.

Note dont use `~/,ssh` in the "from a file on Jenkins Master" it won't resolve. Also note that jenkins home is in a
really weird place in the official Jenkins image, which our image is based on.  if you install jenkins on ubuntu or
centos it will be in /var/lib/jenkins.  This is will be a source of frustration for your scripts too.

if you are using the key `~/.ssh/id_rsa` then you can simply choose the "From the Jenkins Master ~/.ssh"

#### Turning off Strict Host Checking .ssh/config

if you ever end up with this error:

    Host key verification failed.

It may be a result of GitHub's strict host checking.  If you get this error, or you are just want
to avoid the possiblity of getting it.  Add this to your `~/.ssh/config` :

    Host *
        StrictHostKeyChecking no


<a id='add-github-web-hooks'></a>
## Git Hub - Web hooks - Git Hub pushes build with Repo Commit Ability


The GitHub steps are pretty straight forward.  Note that tutorials that are 6 months old though, are wrong.   These
pages change apparently pretty often cause most documents are wrong, and the plugin documentation isn't written in
complete sentances.

So as of January 28 2016..

Go to your github organization web page as an owner.

 * pick the settings tab.
 * Pick webhooks
 * click add web hook
 * Payload URL :   https://yoursite.com:8080/github-webhook/
 * content type : application/x-www-form-urlencoded
 * active should be checked.

When you add it, it will test it.  I first left the content type as application/json and this caused an error.

On the jenkins side.. you must have your public IP exposed on port 8080.  On ours we limit that exposure to just the
github servers, which are 192.30.252.0/22

Next you have to got to each project you want triggered and check `build when a change is pushed to GitHub` under
`Build Triggers`.


 * Open the “Webhooks & Services” tab -> choose “Configure Services” -> find the Jenkins (GitHub plugin option) and fill it in with a similar URL to the following:

http://<Name of Jenkins server>:8080/github-webhook/

<a id='add-github-pull-request'></a>
## Git Hub - Pull Request - Utilities to Build and Regress Pull Requests

Your jenkins user or other user with write access to the repos you want to enable automatic builds on pull requests.. needs to
log into github and go to Settings:

 * Choose Personal Access tokens on the left side.
 * Token Description: Jenkins Git Hub Pull Request
 * scope selection:
   * Repo
   * Admin:repo_hook
   * notifications

Not sure why there isn't an access private repos entry.. That would be to obvious I guess. Hopefully one of the above is
good.

When you click `generate token` you need to copy the hex code string.  you wont see it again.


On the Jenkins side go into system configuration and under the `Github Pull Request Builder`L

 * GitHub Server API URL : https://api.github.com
 * Shared secret : paste the token you copied from github
 * credentials :
   * chose kind: secret text
   * secret : Paste the token you copied from github
   * description : jenkins-svds github personal access token

Add it then you have to choose it.

You then should test it with the tests below it.

<a id='add-gpg'></a>
## GPG Integration - encrypting files for deployment with GPG

Silicon Valley Data Science has a system for pushing out encryped bundles to systems with chef.

This section will make more sense if we open source those packages and we are working on that.

Meanwhile.. you do have gpg and chefdk installed in this docker image and lets just say that we use those
to securely push code to our servers from Jenkins

<a id='add-java'></a>
## Java - Set up JDKs for your Java Programs

One nice thing about Jenkins in this docker context is that it does not depend on the JDK being installed on the
docker image.

To configure go to the top level of your jenkins site and be loged in with admin priveledges.  Chose `Manage Jenkins`
and then `Configure System`  Under JDK you can enter a name, have it installed automatically and it gives you a list
of all JDKs from Sun.

It asks for a oracle name and password.  It seems to work fine without entering them.  I could be wrong.

The name is important. That is what you are going to use in your projects and that name is the identifier that gets
saved in the project config.xml.

if you are copying projects from machine to machine, you will want to have a common naming convention between machines.

<a id='add-maven'></a>
## Maven - Set up Jenkins for Maven Builds

In older versions of maven you had to set up the mavens like you had to set up JDKs.  Current versions have a default
settings provider and default global settings provider in `Manage Jenkins/Configure System/Maven configuration`.

You can change that to your own.. but why would you want to change that.

<a id='add-slack'></a>
## Slack - Add notifications to Slack

https://github.com/jenkinsci/slack-plugin

Why not tell everone whats going on with the build..

Go into `manage Jnekins/Manage Plugins`  On the Available tab search for Slack.

Check `Slack Notification Plugin`. and then install without reboot.  If you haven't noticed.. docker don't want to do
that.

Once installed there is a Global Slack Notifier Settings

Team domain is just the svds in slack group svds.slack.com

For the integration token.. you have to go to the settings on the team in slack.  So if you are in the app you
click the drop down next to the team name and pick team settings.  If you don't have admin priveleges for the group
then you will not see settings. Find an admin or become one.

Chosing settings takes you to the web site and you have to log in.  Once you do you will see Team Settings with an
Authentication tab.



if you aren't a paid slack team.. then it offers to upgrade you, otherwise no slack jenkins for you.

Once you get your token go back to jenkins and put it in the integration token line.

Next the channel is the channel where notifications show up.  This can be overriden in each project.

The Build server URL should be http://yourhost.yourdomain/hudson/

At the project everything defaults to NOT notifying.  You have to check which kinds of notifications should be sent.

The advanced button on their allows you to override team integration token and project channel on a project basis


<a id='add-sonarqube'></a>
## SonarQube Integration - Add Quality Metrics to your Builds


If SonarQube is already running then you just have to know:

 * DNS Name or IP Address of the host.
 * port it is listening on. : Instructions below default to 9000
 * User name and password with access to the repos : System default is admin/admin



If not you will need to [Create a New Docker Instance of SonarQube](#New-Docker-SonarQube) As Describe in the link
to the appendix.


#### Setting up the SonarQube Plugin


From the top level go back into `Manage Jenkins` and pick `Manage Plugins`.   Got to the available  tab
and search for `Sonarqube`  Choose that install it and any dependencies.


Then to configure go back to `Manage Jenkins` and pick `Configure System`.  Find the artifactory section.

 * The host port and user name and password are entered here.  The URL that is needed is of the form http://<dns or ip>:<port>
 * SonarQube Account Login : admin or whatever you set up for jenkins on the sonarqube server.
 * SonarQube Account password : admin or whatever you set up for jenkins on the sonarqube server.

There is an advanced button but I don't know what to change there and it works without it so far.


#### Enabling it for a Project

When you go into a project there is nothing that shows for SonarQube.  If you go down to the bottom you will see
`Post Build Actions` Clicking the Add Post-build action button shows a list where `SonarQube` is an option.  Chooose this.

When you do you then a sonarqube step is specified.  You get the message:

> It is no longer recommended to use SonarQube maven builder. It is preferable to set up SonarQube in the build
environment and use a standard Jenkins maven target.

It still works.

When you rebuild your project you will now get a sonarqube analysis and there is a sonar qube icon in the Jenkins
project and build pages that link to the sonarqube results.

<a id='New-Docker-Artifactory'></a>
## Create a New Docker Instance of Artifactory

You need a place on the host with three directories; data, logs, and backup as well as having docker
installed.


    sudo docker run --name svds-artifactory
            -v /mnt/artifactory/data:/artifactory/data
            -v /mnt/artifactory/logs:/artifactory/logs
            -v /mnt/artifactory/backup:/artifactory/backup -p 8081:8080 -d mattgruter/artifactory


login as Admin admin/password

#### Create Repo

Logged in as admin I chose repositories. Then on the roght clicked the new button.

1. Jenkins Release
 * repository key :  jenkins-release
 * default but then unchecked the "handle snapshots" so that it only has "handle releases" checked.

2. Jenkins Snapshot
 * repository key: jenkins-snapshot
 * default but then unchecked the "handle releases" so that it only has "handle snapshots" checked.

#### create Jenkins user

Logged in as admin.  I chose security/users.  Then on the right I click new.

"New User" dialog:

 * User Name : jenkins
 * email Address : larry@svds.com
 * password : password
 * left the bottom check boxes to only check can update Profile.

#### create CI Permissions Group

Loggied in as admin. I chose security/Permissions.  Then on the right I pick new.

"New Permission Target" Dialog:

 * Name: ci-permissions
 * unchecked any local repository and added only jenkins-release and jenkins-snapshot

####  Add The Server To Jenkins

[Go back and Add Artifactory to Jenkins](#add-artifactory)


<a id='New-Docker-SonarQube'></a>
## Create a New Docker Instance of SonarQube

SonarQube puts its state into a database. It can use H2 but also supports Postgres.  Use Postgres.
The best place for a database is outside of Docker.  If you are in AWS, RDS is a good choice. You won't need HA
but back ups are nice.

When you create the Postgres instance, you need a database called sonar with a user called sonar that has a
password sonar. This is the default.. there is probably a way to change that.

In the postgres command line client `psql` enter.

    CREATE USER sonar WITH PASSWORD 'sonar';
    CREATE DATABASE sonar;
    GRANT ALL PRIVILEGES ON DATAABSE sonar TO sonar;


SonarQube's interface defaults to port 9000.  Open that port to where ever you want on the

    sudo docker run --name=svds-sonarqube -p 9000:9000
    --env SONARQUBE_JDBC_URL="jdbc:postgresql://cdhdb.cyfxxurxfj6o.us-west-2.rds.amazonaws.com:5432/sonar"
    -d sonarqube

If the tables are not there it will generate them automatically.

####  Add The Server To Jenkins

[Go back and Add SonarQubue to Jenkins](#add-sonarqube)