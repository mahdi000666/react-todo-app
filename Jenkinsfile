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
                script {
                    if (env.TAG_NAME || env.BRANCH_NAME == 'dev') {
                        parallel (
                            'Node 18': {
                                bat "docker build --no-cache --build-arg NODE_VERSION=18 -t react-node18:${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)} ."
                            },
                            'Node 20': {
                                bat "docker build --no-cache --build-arg NODE_VERSION=20 -t react-node20:${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)} ."
                            }
                        )
                    } else {
                        bat 'npm run build'
                    }
                }
            }
        }
        
        stage('Run Docker') {
            steps {
                script {
                    // Define variables FIRST
                    def imageTag = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"
                    def imageName = "react-node20:${imageTag}"
                    def containerName = "react_${imageTag}"
                    
                    // Execute commands ONE BY ONE
                    bat "docker stop ${containerName} 2>nul || echo No container to stop"
                    bat 'ping 127.0.0.1 -n 4 > nul'
                    bat "docker build --no-cache -t ${imageName} ."
                    bat "docker run -d -p 8080:80 --name ${containerName} ${imageName}"
                    bat 'ping 127.0.0.1 -n 6 > nul'
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
                archiveArtifacts artifacts: 'dist/**', allowEmptyArchive: true
            }
        }
        
        stage('Cleanup') {
            steps {
                script {
                    def imageTag = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"
                    def containerName = "react_${imageTag}"
                    
                    bat "docker stop ${containerName} 2>nul || exit 0"
                    bat "docker rm ${containerName} 2>nul || exit 0"
                    bat "docker rmi react-node20:${imageTag} 2>nul || exit 0"
                }
            }
        }
    }
    
    post {
        always {
            script {
                def imageTag = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"
                bat "docker stop react_${imageTag} 2>nul || exit 0"
                bat "docker rm react_${imageTag} 2>nul || exit 0"
            }
        }
        success {
            echo "✓ Pipeline completed successfully"
        }
        failure {
            echo "✗ Pipeline failed"
        }
    }
}