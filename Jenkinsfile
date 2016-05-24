#!groovy

import groovy.json.JsonOutput

properties([[$class: 'BuildDiscarderProperty',
                strategy: [$class: 'LogRotator', numToKeepStr: '10']]])

// Get all Causes for the current build
//def causes = currentBuild.rawBuild.getCauses()
//def specificCause = currentBuild.rawBuild.getCause(hudson.model.Cause$UserIdCause)

//echo "Cause: ${causes}"
//echo "SpecificCause: ${specificCause}"

stage 'DockerBuild'
slackSend color: 'blue', message: "ORG: ${env.JOB_NAME} #${env.BUILD_NUMBER} - Starting Docker Build"
node ('docker-cmd'){
    //env.PATH = "${tool 'Maven 3'}/bin:${env.PATH}"

    checkout scm

    sh "echo Working on BRANCH ${env.BRANCH_NAME} for ${env.BUILD_NUMBER}"

    dockerlogin()
    dockerrmi("oneforone/backend-ipython:${env.BRANCH_NAME}.${env.BUILD_NUMBER}")
    dockerbuild("oneforone/backend-ipython:${env.BRANCH_NAME}.${env.BUILD_NUMBER}")
}

stage 'DockerHub'
slackSend color: 'green', message: "ORG: ${env.JOB_NAME} #${env.BUILD_NUMBER} - Pushing to Docker"
node('docker-cmd') {
    dockerlogin()
    dockerpush("oneforone/backend-ipython:${env.BRANCH_NAME}.${env.BUILD_NUMBER}")

}

switch ( env.BRANCH_NAME ) {
    case "master":

        stage 'DockerLatest'
        slackSend color: 'blue', message: "ORG: ${env.JOB_NAME} #${env.BUILD_NUMBER} - Stopping DEV Services"
        node('docker-cmd') {
            stage 'Stop'
            slackSend color: 'blue', message: "ORG: ${env.JOB_NAME} #${env.BUILD_NUMBER} - Stopping DEV Services"

            dockerlogin()
            dockerstop('dev-service-ipython-dev1')
            dockerrm('dev-service-ipython-dev1')

            slackSend color: 'blue', message: "ORG: ${env.JOB_NAME} #${env.BUILD_NUMBER} - Removing latest tag"
            // Erase
            dockerrmi('oneforone/backend-ipython:latest')

            // Tag
            dockertag("oneforone/backend-ipython:${env.BRANCH_NAME}.${env.BUILD_NUMBER}","oneforone/backend-ipython:latest")

            // Push
            slackSend color: 'blue', message: "ORG: ${env.JOB_NAME} #${env.BUILD_NUMBER} - Pushing :latest"
            dockerpush('oneforone/backend-ipython:latest')
        }

        stage 'Sleep'
        sleep 30

        stage 'Downstream'
        slackSend color: 'blue', message: "ORG: ${env.JOB_NAME} #${env.BUILD_NUMBER} - Building Downstream"
        try {
            build '/OPS-Dev-Services/dev-service-ipython-dev1'
        } catch (err) {

        }


        break

    default:
        echo "Branch is not master.  Skipping tagging and push.  BRANCH: ${env.BRANCH_NAME}"
}


// Functions


// Docker functions
def dockerlogin() {

    retry (3) {
        timeout(60) {
                sh "docker -H tcp://10.1.10.210:5001 login -e ${env.DOCKER_EMAIL} -u ${env.DOCKER_USER} -p ${env.DOCKER_PASSWD} registry.1for.one:5000"
        }
    }
    sh "cat ~/.docker/config.json"

}

def dockerbuild(label) {
    sh "docker -H tcp://10.1.10.210:5001 build -t registry.1for.one:5000/${label} ."
}
def dockerstop(vm) {
    sh "docker -H tcp://10.1.10.210:5001 stop ${vm} || echo stop ${vm} failed"
}

def dockerrmi(vm) {
    sh "docker -H tcp://10.1.10.210:5001 rmi -f registry.1for.one:5000/${vm} || echo RMI Failed"
}

def dockerrm(vm) {
    sh "docker -H tcp://10.1.10.210:5001 rm ${vm} || echo RM Failed"
}

def dockertag(label_old, label_new) {
    sh "docker -H tcp://10.1.10.210:5001 tag -f registry.1for.one:5000/${label_old} registry.1for.one:5000/${label_new}"
}

def dockerpush(image) {
    sh "docker -H tcp://10.1.10.210:5001 push registry.1for.one:5000/${image}"
}

def dockerrm(vm) {
    sh "docker -H tcp://10.1.10.210:5001 rm -f ${vm} || echo RMI Failed"
}