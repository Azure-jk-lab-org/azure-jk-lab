pipeline {
    agent { label 'slave1' }

    environment {
        ARM_CLIENT_ID       = credentials('ARM_CLIENT_ID')
        ARM_CLIENT_SECRET   = credentials('ARM_CLIENT_SECRET')
        ARM_TENANT_ID       = credentials('ARM_TENANT_ID')
        ARM_SUBSCRIPTION_ID = credentials('ARM_SUBSCRIPTION_ID')
        IS_MAIN_BRANCH      = 'false'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Detect Branch') {
            steps {
                script {
                    def branch = sh(
                        script: 'git rev-parse --abbrev-ref HEAD',
                        returnStdout: true
                    ).trim()

                    env.IS_MAIN_BRANCH = (branch == 'main').toString()
                    echo "Detected branch: ${branch}"
                }
            }
        }

        stage('Terraform Initialization') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Format Correction') {
            steps {
                sh 'terraform fmt -recursive'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    if (env.IS_MAIN_BRANCH == 'true') {
                        echo "Running Terraform plan for main branch"
                        sh 'terraform plan -out=tfplan-main'
                    } else {
                        echo "Running Terraform plan for non-main branch"
                        sh 'terraform plan -out=tfplan-non-main'
                        echo "Apply will be skipped"
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { env.IS_MAIN_BRANCH == 'true' }
            }
            steps {
                input message: 'Do you want to apply Terraform changes?', ok: 'Apply'
                sh 'terraform apply tfplan-main'
            }
        }
    }

    post {
        always {
            sh 'terraform version'
        }
        failure {
            echo 'Terraform pipeline failed!'
        }
    }
}
