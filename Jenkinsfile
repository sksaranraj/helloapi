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

        stage('whoami and printenv') {
            steps {
                script {
                    // Build the Docker image; adjust context (.) if needed
                    sh """
                      whoami
                      printenv
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

    stage('Deploy') {
        steps {
            script {
                // ... your deployment logic here ...
                
                // On success, send a deployment event to New Relic
                sh"""
                echo "Deployment"
                """
            }
        }
    }

    }

    post {
        always {
            // Clean up sensitive files
            sh 'rm -f sa_key.json'
            script {
                // Create a new environment variable named BUILD_STATUS
                env.BUILD_STATUS = currentBuild.currentResult
            }
            withCredentials([
                    string(credentialsId: 'NR_ACCOUNT_ID', variable: 'NEWRELIC_ACCOUNT_ID'),
                    string(credentialsId: 'NR_INSERT_KEY', variable: 'NEWRELIC_INSERT_KEY')
                ]) {
                    sh """
                      echo "New Relic Account ID: \$NEWRELIC_ACCOUNT_ID"
                      # Example usage:
                      curl -X POST "https://insights-collector.newrelic.com/v1/accounts/\$NEWRELIC_ACCOUNT_ID/events" \
                        -H "X-Insert-Key: \$NEWRELIC_INSERT_KEY" \
                        -H "Content-Type: application/json" \
                         -d '{
                           "eventType": "DeploymentEvent",
                           "pipelineId": "${env.BUILD_ID}",
                           "commitSha": "${env.GIT_COMMIT}",
                           "deploymentTimestamp": "'\$(date +%s)'",
                           "status": "${env.BUILD_STATUS}",
                           "project": "${env.JOB_NAME}"
                         }'
                    """
            }
        }
    }
}

