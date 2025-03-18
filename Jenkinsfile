pipeline {
    agent any

    environment {
        // Name of your GCP project
        GCP_PROJECT_ID = 'annular-climate-454107-b0'
        
        // The name of the Docker image you want to push
        IMAGE_NAME = 'helloapi'

        // Jenkins credential ID for your GCP service account JSON
        GCP_SERVICE_ACCOUNT_KEY = 'gcp-sa-key'
        
        // Docker image tag (you can use BUILD_NUMBER, a Git commit SHA, etc.)
        IMAGE_TAG = "build-${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                // This checks out the source code from your repo
                checkout scm
            }
        }

        stage('who am i') {
            steps {
                script {
                    // Build the Docker image; adjust context (.) if needed
                    sh """
                      whoami
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image; adjust context (.) if needed
                    sh """
                      docker build -t gcr.io/\$GCP_PROJECT_ID/\$IMAGE_NAME:\$IMAGE_TAG .
                    """
                }
            }
        }

        stage('Authenticate with GCP') {
            steps {
                // Provide the Jenkins credential ID in 'credentialsId'.
                // 'variable' is the env var that'll point to the key file.
                withCredentials([file(credentialsId: 'gcp-sa-key', variable: 'GCP_SA_FILE')]) {
                    sh """
                      gcloud auth activate-service-account --key-file=\$GCP_SA_FILE
                      gcloud config set project \$GCP_PROJECT_ID
                      gcloud auth configure-docker --quiet
                    """
                }
            }
        }

        stage('Push Docker Image to GCP') {
            steps {
                script {
                    // Push the Docker image to GCR
                    sh """
                      docker push gcr.io/\$GCP_PROJECT_ID/\$IMAGE_NAME:\$IMAGE_TAG
                    """
                }
            }
        }
    }

    post {
        always {
            // Clean up sensitive files
            sh 'rm -f sa_key.json'
        }
    }
}

