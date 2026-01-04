\# Netflix DevSecOps Project



End-to-end DevSecOps implementation using \*\*Jenkins, SonarQube, Docker, and Kubernetes\*\*.



\## Architecture



GitHub → Jenkins → SonarQube → Docker Hub → Kubernetes → Netflix UI



\## Tech Stack

\- Jenkins (CI)

\- SonarQube (Static Code Analysis)

\- Docker \& Docker Hub

\- Kubernetes (kind)

\- Next.js (Netflix Clone)



\## CI Pipeline

1\. Checkout source code

2\. SonarQube static analysis

3\. Docker image build

4\. Push image to Docker Hub



\## Docker Image

utkarsh7716/netflix:latest





\## Kubernetes Deployment

\- Cluster: kind

\- Service: NodePort (30007)



