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
                    
                    // Cleanup existing containers using PowerShell
                    powershell '''
                        # Stop containers using port 8080
                        docker ps -q --filter "publish=8080" | ForEach-Object { docker stop $_ } 2>$null
                        # Remove old react containers
                        docker ps -aq --filter "name=react_" | ForEach-Object { docker stop $_; docker rm $_ } 2>$null
                    '''
                    
                    // Wait to ensure port is released (FIXED: removed >nul)
                    bat 'timeout /t 3 /nobreak'
                    
                    // Check if port 8080 is in use and kill the process if needed
                    bat '''
                        netstat -aon | findstr :8080 >nul
                        if not errorlevel 1 (
                            echo Port 8080 is in use, killing process...
                            for /f "tokens=5" %%i in ('netstat -aon ^| findstr :8080') do taskkill /F /PID %%i
                            timeout /t 2 /nobreak
                        )
                    '''
                    
                    // For branches without parallel builds, build the image
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