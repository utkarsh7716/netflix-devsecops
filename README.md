1\. Architecture (High Level)

GitHub (Source)

&nbsp;     ↓

Jenkins (CI)

&nbsp; ├─ SonarQube Analysis

&nbsp; ├─ Docker Build

&nbsp; └─ Docker Push

&nbsp;     ↓

Docker Hub (Image Registry)

&nbsp;     ↓

Kubernetes (kind on EC2)

&nbsp;     ↓

Netflix UI (NodePort)



2\. Infrastructure Setup

EC2-1 (CI Server)



Ubuntu 22.04



Jenkins



Docker



SonarQube (Docker)



EC2-2 (Kubernetes)



Ubuntu 22.04



Docker



kind



kubectl



3\. Install Docker (Both EC2s)

curl -fsSL https://get.docker.com | sudo sh

sudo usermod -aG docker ubuntu

sudo systemctl enable docker





Logout \& login again.



4\. Install Jenkins (EC2-1)

sudo apt update

sudo apt install -y openjdk-17-jdk



curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key |

sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null



echo "deb \[signed-by=/usr/share/keyrings/jenkins-keyring.asc] \\

https://pkg.jenkins.io/debian-stable binary/" |

sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null



sudo apt update

sudo apt install -y jenkins

sudo systemctl start jenkins





Access:



http://<EC2-1\_PUBLIC\_IP>:8080



5\. Run SonarQube (EC2-1)

docker run -d --name sonarqube \\

&nbsp; -p 9000:9000 \\

&nbsp; sonarqube:lts





Access:



http://<EC2-1\_PUBLIC\_IP>:9000





Login: admin / admin



Generate SonarQube token



6\. Jenkins Configuration

Plugins



Install:



Git



Docker Pipeline



SonarQube Scanner



Credentials Binding



Credentials



Add:



Docker Hub → Username \& password

ID: dockerhub-creds



SonarQube Token → Secret Text



SonarQube Server



Manage Jenkins → System



Name: sonarqube



URL: http://localhost:9000



Token credential



7\. Dockerfile (Production-Ready)



Create Dockerfile:



\# ---------- Build stage ----------

FROM node:16-bullseye AS builder



WORKDIR /app



RUN apt-get update \&\& apt-get install -y git \&\& rm -rf /var/lib/apt/lists/\*



RUN git clone https://github.com/gauri17-pro/nextflix.git .



ENV NEXT\_DISABLE\_ESLINT=1

ENV NEXT\_TELEMETRY\_DISABLED=1



RUN yarn install --frozen-lockfile

RUN yarn build



\# ---------- Runtime stage ----------

FROM node:16-bullseye



WORKDIR /app

ENV NODE\_ENV=production



COPY --from=builder /app/package.json ./

COPY --from=builder /app/yarn.lock ./

COPY --from=builder /app/.next ./.next

COPY --from=builder /app/public ./public

COPY --from=builder /app/node\_modules ./node\_modules



EXPOSE 3000

CMD \["yarn", "start"]



8\. Jenkins Pipeline (CI)



Create Pipeline Job: netflix-cicd



Jenkinsfile

pipeline {

&nbsp; agent any



&nbsp; environment {

&nbsp;   IMAGE\_NAME = "utkarsh7716/netflix"

&nbsp;   IMAGE\_TAG  = "latest"

&nbsp;   DOCKER\_CREDS = credentials('dockerhub-creds')

&nbsp; }



&nbsp; stages {



&nbsp;   stage('Checkout Source') {

&nbsp;     steps {

&nbsp;       git url: 'https://github.com/gauri17-pro/nextflix.git'

&nbsp;     }

&nbsp;   }



&nbsp;   stage('SonarQube Analysis') {

&nbsp;     steps {

&nbsp;       withSonarQubeEnv('sonarqube') {

&nbsp;         sh '''

&nbsp;           sonar-scanner \\

&nbsp;             -Dsonar.projectKey=netflix \\

&nbsp;             -Dsonar.projectName=Netflix \\

&nbsp;             -Dsonar.sources=.

&nbsp;         '''

&nbsp;       }

&nbsp;     }

&nbsp;   }



&nbsp;   stage('Build Docker Image') {

&nbsp;     steps {

&nbsp;       sh 'docker build -t $IMAGE\_NAME:$IMAGE\_TAG .'

&nbsp;     }

&nbsp;   }



&nbsp;   stage('Push to Docker Hub') {

&nbsp;     steps {

&nbsp;       sh '''

&nbsp;         echo "$DOCKER\_CREDS\_PSW" | docker login -u "$DOCKER\_CREDS\_USR" --password-stdin

&nbsp;         docker push $IMAGE\_NAME:$IMAGE\_TAG

&nbsp;       '''

&nbsp;     }

&nbsp;   }

&nbsp; }

}





Run Build Now → SUCCESS.



9\. Kubernetes Setup (EC2-2)

Install kind \& kubectl

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64

chmod +x kind

sudo mv kind /usr/local/bin/



sudo apt install -y kubectl



Create cluster

kind create cluster --name netflix

kubectl get nodes



10\. Deploy Application to Kubernetes

kubectl create namespace netflix



kubectl -n netflix create deployment netflix \\

&nbsp; --image=utkarsh7716/netflix:latest





Expose via NodePort:



kubectl -n netflix expose deployment netflix \\

&nbsp; --type=NodePort \\

&nbsp; --port=3000 \\

&nbsp; --target-port=3000 \\

&nbsp; --name=netflix-svc



kubectl -n netflix patch svc netflix-svc \\

&nbsp; -p '{"spec":{"ports":\[{"port":3000,"targetPort":3000,"nodePort":30007}]}}'



11\. Netflix UI Access (Final)

http://<EC2-2\_PUBLIC\_IP>:30007

