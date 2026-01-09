pipeline {
    agent { label 'slave1' }

    environment {
        ARM_CLIENT_ID       = credentials('ARM_CLIENT_ID')
        ARM_CLIENT_SECRET   = credentials('ARM_CLIENT_SECRET')
        ARM_TENANT_ID       = credentials('ARM_TENANT_ID')
        ARM_SUBSCRIPTION_ID = credentials('ARM_SUBSCRIPTION_ID')
    }

    stages {

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
                    if (env.BRANCH_NAME == 'main') {
                        echo "Running Terraform plan for main branch"
                        sh 'terraform plan -out=tfplan-main'
                    } else {
                        echo "Running Terraform plan for branch: ${env.BRANCH_NAME}"
                        sh "terraform plan -out=tfplan-${env.BRANCH_NAME}"

                        //Hard stop for non-main branches
                        currentBuild.result = 'SUCCESS'
                        echo "Non-main branch detected. Skipping apply stage."
                        return
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when {
                branch 'main'                
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
