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
                script {
                    // Write the service account key to a file and authenticate
                    // This uses the secret text or file stored in Jenkins
                    // Make sure you created a credential named 'gcp-sa-key'
                    writeFile file: 'sa_key.json', text: "${GCP_SERVICE_ACCOUNT_KEY}"
                    
                    // Activate the service account
                    sh """
                      gcloud auth activate-service-account --key-file=sa_key.json
                      gcloud config set project \$GCP_PROJECT_ID
                      
                      // Configure Docker to use gcloud's credentials
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

