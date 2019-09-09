pipeline {

  agent {
    kubernetes {
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    job: ${env.JOB_NAME}
    job_id: ${env.BUILD_NUMBER}
spec:
  nodeSelector:
    role: worker
  containers:
  - name: ecs-new-task-definition
    image: quay.io/uktrade/ecs-new-task-definition
    imagePullPolicy: Always
    command:
    - cat
    tty: true
"""
    }
  }

  options {
    timestamps()
    ansiColor('xterm')
    buildDiscarder(logRotator(daysToKeepStr: '180'))
  }

  stages {
    stage('Init') {
      steps {
        script {
          timestamps {
            validateDeclarativePipeline("${env.WORKSPACE}/Jenkinsfile")
          }
        }
      }
    }
    stage('Deploy') {
      steps {
        container('ecs-new-task-definition') {
          script {
            timestamps {
              withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: env.CredentialsId]]) {
                sh "./new-task-definition.sh"
              }
            }
          }
        }
      }
    }
  }
}
