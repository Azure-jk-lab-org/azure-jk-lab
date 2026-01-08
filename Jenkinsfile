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

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    if (env.BRANCH_NAME != 'main') {
                        echo "Running Terraform plan for other branches"
                        sh 'terraform plan -out=tfplan'                        

                    } else {
                        echo "Running terrafrom plan for feature branch: ${env.BRANCH_NAME}"
                        sh "terraform plan -out=tfplan-${env.BRANCH_NAME}"                    
                        
                    }
                }
               }
            }
        

        stage('Terraform Apply') {
            when {
                beforeInput true
                branch 'main'
            }

            steps {
                script {
                    //Pause for approval before applying changes
                    input message: 'Do you want to Apply Terraform changes?', ok: 'Apply'
                    
                    //Run the apply command after the appproval
                    sh 'terraform apply tfplan-main'
                }
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
