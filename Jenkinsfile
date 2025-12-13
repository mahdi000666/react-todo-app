pipeline {
    agent any
    
    environment {
        // Use const-like variables for consistency
        IMAGE_NAME = "react-todo"
        IMAGE_TAG  = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"
        PORT       = "8080"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Image') {
            steps {
                // Build once; Dockerfile handles npm ci and npm build 
                bat "docker build --no-cache -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Deploy (Local)') {
            steps {
                script {
                    // Clean up specifically the previous container name to avoid conflicts
                    // '|| exit 0' ensures the pipeline continues if container doesn't exist
                    bat "docker stop ${IMAGE_NAME}-container 2>nul || exit 0"
                    bat "docker rm ${IMAGE_NAME}-container 2>nul || exit 0"
                    
                    bat "docker run -d -p ${PORT}:80 --name ${IMAGE_NAME}-container ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Smoke Test') {
            steps {
                bat 'call smoke-test.bat'
                archiveArtifacts artifacts: 'smoke.log', allowEmptyArchive: true
            }
        }
    }

    post {
        always {
            script {
                // Clean up local container after testing to free resources
                bat "docker stop ${IMAGE_NAME}-container 2>nul || exit 0"
                bat "docker rm ${IMAGE_NAME}-container 2>nul || exit 0"
            }
        }
        failure {
            echo "✗ Pipeline failed on branch ${env.BRANCH_NAME}"
        }
    }
}