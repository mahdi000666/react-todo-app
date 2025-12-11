pipeline {
    agent any

    options {
        skipDefaultCheckout()
    }

    stages {
        stage('Select Pipeline') {
            steps {
                script {
                    if (env.BRANCH_NAME == "dev") {
                        echo "Running dev pipeline"
                        load "Jenkinsfile.dev"
                    } else if (env.CHANGE_ID) {
                        echo "Running PR pipeline"
                        load "Jenkinsfile.pr"
                    } else if (env.TAG_NAME) {
                        echo "Running tag pipeline"
                        load "Jenkinsfile.tag"
                    } else {
                        error "No matching pipeline found."
                    }
                }
            }
        }
    }
}
