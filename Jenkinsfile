// ISEC6000 Assessment 2 - Automating Security in CI/CD: Node.js CI/CD with Jenkins
// Build agent = Node 16 (required). Stages: install -> test -> security -> build/push.

pipeline {
    agent none   // each stage picks its own containerised agent

    environment {
        IMAGE_NAME = "ayubshrestha/express-js-sample-assignment2-22802767"
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
    }

    options {
        timestamps()                                   // timestamp every log line (Task 4 logging)
        buildDiscarder(logRotator(numToKeepStr: '15')) // log/artifact retention policy (Task 4)
    }

    stages {

        stage('Install & Test') {
            agent {
                docker {
                    image 'node:16'      // REQUIRED build agent
                    args  '-u node'      // run as non-root 'node' user (least privilege)
                }
            }
            steps {
                sh 'node --version'
                sh 'npm ci'              // clean install from package-lock.json
                sh 'npm test'            // runs our smoke test
            }
        }

        stage('Security Scan') {
            agent {
                docker {
                    image 'node:16'
                    args  '-u root'      // root so the global tool install works
                }
            }
            steps {
                // SECURITY GATE: fail the build on High/Critical vulnerabilities
                sh 'npm ci'
                sh 'npm audit --audit-level=high'
            }
        }

        stage('Build & Push Image') {
            agent any   // Jenkins controller has the docker CLI -> DinD daemon
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-creds') {
                        def image = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                        image.push()
                        image.push('latest')
                    }
                }
            }
        }
    }

    post {
        success { echo "Success — pushed ${IMAGE_NAME}:${IMAGE_TAG}" }
        failure { echo "Failed — see the failing stage log above." }
        always  { echo "Result: ${currentBuild.currentResult}" }
    }
}
