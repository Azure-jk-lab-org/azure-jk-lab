pipeline {
    agent { label 'slave1' }

    environment {
        // Use credentials for security best practices
        ARM_CLIENT_ID       = credentials('ARM_CLIENT_ID')
        ARM_CLIENT_SECRET   = credentials('ARM_CLIENT_SECRET')
        ARM_TENANT_ID       = credentials('ARM_TENANT_ID')
        ARM_SUBSCRIPTION_ID = credentials('ARM_SUBSCRIPTION_ID')
    }

    stages {
        stage('Terraform Init') {
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
                    // Logic: Always plan, but name the plan based on the branch
                    def planName = (env.BRANCH_NAME == 'main') ? "tfplan-main" : "tfplan-${env.BRANCH_NAME}"
                    sh "terraform plan -out=${planName}"
                    
                    // Stashing the plan file so it is available in the next stage even on different agents
                    stash name: 'terraform-plan', includes: planName
                }
            }
        }

        stage('Terraform Apply') {
            // CONDITION: Run ONLY if the branch is main and NOT a Pull Request
            when {
                allOf {
                    branch 'main'
                    not { changeRequest() } 
                }
            }
            steps {
                script {
                    unstash 'terraform-plan'
                    
                    // Best Practice: Use timeout with manual approval to avoid blocking Jenkins
                    timeout(time: 2, unit: 'HOURS') {
                        input message: "Review the plan for MAIN. Proceed with Apply?", ok: "Apply"
                    }
                    
                    sh 'terraform apply -auto-approve tfplan-main'
                }
            }
        }
    }

    post {
        always {
            sh 'terraform version'
        }
        aborted {
            echo 'Deployment aborted manually or due to timeout.'
        }
        failure {
            echo 'Terraform pipeline failed. Review logs for errors.'
        }
    }
}
