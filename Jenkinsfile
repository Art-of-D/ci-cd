pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: jenkins-kaniko
spec:
  serviceAccountName: jenkins-sa
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.16.0-debug
      imagePullPolicy: Always
      command:
        - sleep
      args:
        - 99d
    - name: git
      image: alpine/git
      command:
        - sleep
      args:
        - 99d
"""
    }
  }

  environment {
    ECR_REGISTRY = "321699387235.dkr.ecr.us-west-2.amazonaws.com"
    IMAGE_NAME   = "lesson-8-9-ecr"
    IMAGE_TAG    = ""

    COMMIT_EMAIL = "jenkins@localhost"
    COMMIT_NAME  = "jenkins"
  }

  stages {
    stage('Set Image Tag') {
      steps {
        container('git') {
          script {
            sh 'git config --global --add safe.directory $(pwd)'
            def commitSha = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
            env.IMAGE_TAG = commitSha
          }
        }
      }
    }
    stage('Build & Push Docker Image') {
      steps {
        container('kaniko') {
          sh '''
              /kaniko/executor \
                --context $(pwd) \
                --dockerfile $(pwd)/django/Dockerfile \
                --destination=$ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG \
                --cache=true \
                --insecure \
                --skip-tls-verify
          '''
        }
      }
    }

    stage('Update Chart Tag in Git') {
      steps {
        container('git') {
          withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PAT')]) {
            sh '''
              git clone https://$GIT_USERNAME:$GIT_PAT@github.com/Art-of-D/ci-cd.git
              cd ci-cd
              cd lesson-8-9/charts/django-app

              sed -i "s/tag: .*/tag: $IMAGE_TAG/" values.yaml

              git config user.email "$COMMIT_EMAIL"
              git config user.name "$COMMIT_NAME"

              git add values.yaml
              git commit -m "Update image tag to $IMAGE_TAG"
              git push origin main
            '''
          }
        }
      }
    }
  }
}
