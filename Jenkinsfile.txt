pipeline {
  agent any

  environment {
    IMAGE_NAME = "utkarsh7716/netflix"
    IMAGE_TAG  = "latest"
    DOCKER_CREDS = credentials('dockerhub-creds')
  }

  stages {

    stage('Checkout Source') {
      steps {
        git url: 'https://github.com/gauri17-pro/nextflix.git'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('sonarqube') {
          sh '''
            sonar-scanner \
              -Dsonar.projectKey=netflix \
              -Dsonar.projectName=Netflix \
              -Dsonar.sources=.
          '''
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
      }
    }

    stage('Push Image to Docker Hub') {
      steps {
        sh '''
          echo "$DOCKER_CREDS_PSW" | docker login -u "$DOCKER_CREDS_USR" --password-stdin
          docker push $IMAGE_NAME:$IMAGE_TAG
        '''
      }
    }
  }

  post {
    success {
      echo "CI pipeline completed successfully"
    }
    failure {
      echo "CI pipeline failed"
    }
  }
}
