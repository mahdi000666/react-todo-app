pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup') {
            steps {
                bat 'npm ci --prefer-offline'
            }
        }
        
        stage('Build') {
            steps {
                bat 'npm run build 2>&1 | tee build.log'
            }
        }
        
        stage('Run Docker') {
            steps {
                script {
                    def tag = env.TAG_NAME ?: env.GIT_COMMIT.take(7)
                    bat "docker build -t react:${tag} ."
                    bat "docker run -d -p 8080:80 --name react_tag_${tag} react:${tag}"
                    bat 'timeout /t 5 /nobreak'
                }
            }
        }
        
        stage('Smoke Test') {
            steps {
                bat 'call smoke-test.bat'
                archiveArtifacts artifacts: 'smoke.log', allowEmptyArchive: true
            }
        }
        
        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: 'dist/**,build.log,smoke.log', allowEmptyArchive: false
            }
        }
        
        stage('Cleanup') {
            steps {
                script {
                    def tag = env.TAG_NAME ?: env.GIT_COMMIT.take(7)
                    bat "docker stop react_tag_${tag} || exit 0"
                    bat "docker rm react_tag_${tag} || exit 0"
                }
            }
        }
    }
    
    post {
        success {
            echo "Build for tag ${env.TAG_NAME} succeeded"
        }
        failure {
            echo "Build for tag ${env.TAG_NAME} failed"
        }
    }
}