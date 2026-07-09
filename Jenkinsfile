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
            stage("trivy-file-system-scanner")
            {
                agent{
                    label 'slave-1 sonarqube'
                }
            steps{
                sh "trivy fs --format table --output trivy-report.txt ."
            }
            }
            
           stage('Docker Login') {
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
    stage("docker build")
    {
        agent {
            label "docker"
        }
        steps{
             unstash 'source'
        sh " docker build -t prajwaldevops10/devops-flask:${BUILD_NUMBER} ."
    }}
    
    stage("docker push and run"){
        agent{
            label "docker"
        }
        steps{
            sh "docker push prajwaldevops10/devops-flask:${BUILD_NUMBER}"
           
        }
    }
    stage('Deploy to Kubernetes') {
    agent {
        label 'docker'
    }

    steps {
        sh """
            sed -i 's|image:.*|image: prajwaldevops10/devops-flask:${BUILD_NUMBER}|' k8s/deployment.yaml

            kubectl apply -f k8s/
        """
    }
}
    }
}
