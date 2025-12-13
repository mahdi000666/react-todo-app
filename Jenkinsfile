pipeline {
    agent any
    
    environment {
        // Use a unique name for the container based on the branch
        // e.g., react-todo-main-container or react-todo-dev-container
        CONTAINER_NAME = "react-todo-${env.BRANCH_NAME}-container" 
        IMAGE_NAME     = "react-todo"
        IMAGE_TAG      = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"
        PORT           = "8080"
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
                    // Use the new dynamic CONTAINER_NAME variable
                    bat "docker stop ${CONTAINER_NAME} 2>nul || exit 0"
                    bat "docker rm ${CONTAINER_NAME} 2>nul || exit 0"
                    
                    // Use the dynamic CONTAINER_NAME in docker run
                    bat "docker run -d -p ${PORT}:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}:${IMAGE_TAG}"
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
                // Ensure the post-action cleanup uses the dynamic name too
                bat "docker stop ${CONTAINER_NAME} 2>nul || exit 0"
                bat "docker rm ${CONTAINER_NAME} 2>nul || exit 0"
            }
        }
        failure {
            echo "✗ Pipeline failed on branch ${env.BRANCH_NAME}"
        }
    }
}