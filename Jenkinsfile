pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                bat 'npm install'
            }
        }
        
        stage('Test') {
            when {
                anyOf {
                    branch 'main'
                    branch 'dev'
                    branch 'feature/*'
                }
            }
            steps {
                bat 'npm test'
            }
        }
        
        stage('Deploy Staging') {
            when {
                branch 'dev'
            }
            steps {
                echo "Deploying to staging..."
            }
        }
        
        stage('Deploy Production') {
            when {
                branch 'main'
            }
            steps {
                echo "Deploying to production..."
            }
        }
    }
}