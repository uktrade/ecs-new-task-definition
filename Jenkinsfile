pipeline {
  agent {
    node {
      label env.CI_SLAVE
    }
  }

  options {
    timestamps()
    ansiColor('xterm')
  }

  stages {
    stage('Init') {
      steps {
        script {
          validateDeclarativePipeline("${env.WORKSPACE}/Jenkinsfile")
          deployer = docker.image("quay.io/uktrade/ecs-new-task-definition:${env.GIT_BRANCH.split("/")[1]}")
          deployer.pull()
          docker_args = "--network host"
        }
      }
    }
    stage('Deploy') {
      steps {
        script {
          deployer.inside(docker_args) {
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: env.CredentialsId]]) {
              sh "ecs-deploy --region eu-west-2 --timeout 600 --cluster ${env.Cluster} --service-name ${env.Service} --image ${env.Image}"
            }
          }
        }
      }
    }
  }
}