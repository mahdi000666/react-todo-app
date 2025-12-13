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
                        // Parallel build for dev and tags
                        parallel (
                            'Node 18': {
                                bat 'docker build --build-arg NODE_VERSION=18 -t react-node18:%BUILD_NUMBER% .'
                            },
                            'Node 20': {
                                bat 'docker build --build-arg NODE_VERSION=20 -t react-node20:%BUILD_NUMBER% .'
                            }
                        )
                    } else {
                        // Simple build for PRs
                        bat 'npm run build'
                    }
                }
            }
        }
        
        stage('Run Docker') {
            steps {
                script {
                    def imageName = env.TAG_NAME ? "react:${TAG_NAME}" : "react-node20:${BUILD_NUMBER}"
                    if (!env.TAG_NAME && env.BRANCH_NAME != 'dev') {
                        bat "docker build -t ${imageName} ."
                    }
                    bat "docker run -d -p 8080:80 --name react_${BUILD_NUMBER} ${imageName}"
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
                script {
                    if (env.TAG_NAME) {
                        archiveArtifacts artifacts: 'dist/**,*.log', allowEmptyArchive: false
                    } else {
                        archiveArtifacts artifacts: 'dist/**', allowEmptyArchive: true
                    }
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                bat "docker stop react_${BUILD_NUMBER} || exit 0"
                bat "docker rm react_${BUILD_NUMBER} || exit 0"
            }
        }
    }
    
    post {
        always {
            bat 'docker stop react_%BUILD_NUMBER% || exit 0'
            bat 'docker rm react_%BUILD_NUMBER% || exit 0'
        }
        success {
            echo "✓ Pipeline completed successfully"
        }
        failure {
            echo "✗ Pipeline failed"
        }
    }
}