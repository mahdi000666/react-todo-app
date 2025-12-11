pipeline {
    agent any
    stages {
        stage('Checkout') { steps { checkout scm } }
        stage('Setup') { steps { bat 'npm ci' } }
        stage('Build') { steps { bat 'npm run build | tee build.log' } }
        stage('Run Docker') {
            steps {
                script {
                    def tag = env.GIT_TAG ?: env.GIT_COMMIT
                    bat "docker build -t react:%tag% ."
                    bat "docker run -d -p 8080:80 --name react_tag_%tag% react:%tag%"
                }
            }
        }
        stage('Smoke Test') {
            steps { bat 'call smoke-test.bat > smoke.log || (type smoke.log & exit /b 1)' }
        }
        stage('Archive Artifacts') {
            steps { archiveArtifacts artifacts: 'dist/**,build.log,smoke.log', allowEmptyArchive: false }
        }
        stage('Cleanup') {
            steps {
                bat """
                for /F "tokens=*" %%i in ('docker ps -a --filter "name=react_tag_*" --format "{{.ID}}"') do docker rm -f %%i
                """
            }
        }
    }
    post {
        success { echo "Build for tag ${env.GIT_TAG} succeeded" }
    }
}
