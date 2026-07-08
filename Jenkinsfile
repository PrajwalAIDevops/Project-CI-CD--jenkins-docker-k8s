pipeline {
    agent none

    stages {

        stage("checkout the code") {
            agent {
                label 'slave-1 sonarqube'
            }

            steps {
                git branch: 'main',
                    url: 'https://github.com/PrajwalAIDevops/Project-CI-CD--jenkins-docker-k8s.git'

                stash includes: '**', name: 'source'
            }
        }

        stage("Activate enve") {
            agent {
                label 'slave-1 sonarqube'
            }

            steps {
                sh "python3 -m venv venv"
                sh """
                    . venv/bin/activate
                    pip install --no-cache-dir -r requirements.txt
                """
                
            }
        }

        stage("Sonar-qube") {
            agent {
                label 'slave-1 sonarqube'
            }

            steps {
                script {
                    scanner_home = tool "sonar"
                }

                withSonarQubeEnv("sonar-server") {
                    sh """
                        ${scanner_home}/bin/sonar-scanner \
                        -Dsonar.projectName=flask-app \
                        -Dsonar.projectKey=flask-app \
                        -Dsonar.sources=.
                    """
                }
            }
        }

        stage("trivy-file-system-scanner") {
            agent {
                label 'slave-1 sonarqube'
            }

            steps {
                sh "trivy fs --format table --output trivy-report.txt ."
            }
        }

        stage("Docker Login") {
            agent {
                label 'docker'
            }

            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    '''
                }
            }
        }

        stage("Docker Build") {
            agent {
                label "docker"
            }

            steps {
                unstash 'source'

                sh "docker build -t prajwaldevops10/devops-flask:${BUILD_NUMBER} ."
            }
        }

        stage("Docker Image Scan") {
            agent {
                label "docker"
            }

            steps {
                sh "trivy image --format table --output trivy-image-report.txt prajwaldevops10/devops-flask:${BUILD_NUMBER}"
            }
        }

        stage("Docker Push and Run") {
            agent {
                label "docker"
            }

            steps {
                sh "docker push prajwaldevops10/devops-flask:${BUILD_NUMBER}"
                sh "docker run --name flask -d -p 5000:5000 prajwaldevops10/devops-flask:${BUILD_NUMBER}"
            }
        }
    }
}
