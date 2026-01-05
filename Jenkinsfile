pipeline {
  agent any

  environment {
    IMAGE_NAME = "utkarsh7716/netflix"
    IMAGE_TAG  = "latest"
    DOCKER_CREDS = credentials('dockerhub-creds')
    SONAR_SCANNER_HOME = tool 'sonar-scanner'
  }

  stages {

    stage('Checkout CI/CD Repo') {
      steps {
        git branch: 'main',
            url: 'https://github.com/utkarsh7716/netflix-devsecops.git'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('sonarqube') {
          sh '''
            $SONAR_SCANNER_HOME/bin/sonar-scanner \
              -Dsonar.projectKey=netflix \
              -Dsonar.projectName=Netflix \
              -Dsonar.sources=.
          '''
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          docker build -t $IMAGE_NAME:$IMAGE_TAG .
        '''
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

    stage('Deploy to Kubernetes') {
      steps {
        sh '''
          kubectl apply -f k8s/deployment.yaml
          kubectl apply -f k8s/service.yaml
        '''
      }
    }
  }

  post {
    success {
      echo "CI + CD pipeline executed successfully"
    }
  }
}

