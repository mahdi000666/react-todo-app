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
                    def imageTag = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"
                    def imageName = "react-node20:${imageTag}"
                    def containerName = "react_${imageTag}"
                    
                    // SIMPLE CLEANUP - Just stop and remove any existing react containers
                    bat "docker stop ${containerName} 2>nul || echo No container to stop"
                    bat "docker rm ${containerName} 2>nul || echo No container to remove"
                    
                    // Also stop any container using port 8080
                    bat '''
                        for /f "tokens=*" %%i in ('docker ps --format "{{.Names}}" ^| findstr ".*"') do (
                          docker ps --format "{{.Names}}: {{.Ports}}" | findstr "%%i" | findstr ":8080" >nul
                          if not errorlevel 1 (
                            docker stop %%i 2>nul
                            docker rm %%i 2>nul
                          )
                        )
                    '''
                    
                    // Wait
                    bat 'ping 127.0.0.1 -n 4 > nul'
                    
                    // For main branch, build the Docker image
                    if (!env.TAG_NAME && env.BRANCH_NAME != 'dev') {
                        bat "docker build --no-cache -t ${imageName} ."
                    }
                    
                    // Run the container
                    bat "docker run -d -p 8080:80 --name ${containerName} ${imageName}"
                    
                    // Wait for container to start
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
                script {
                    if (env.TAG_NAME) {
                        bat 'echo Build completed > build.log'
                        archiveArtifacts artifacts: 'dist/**,*.log', allowEmptyArchive: false
                    } else {
                        archiveArtifacts artifacts: 'dist/**', allowEmptyArchive: true
                    }
                }
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