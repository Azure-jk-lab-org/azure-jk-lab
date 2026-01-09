pipeline {
    agent { label 'slave1' }

    environment {
        ARM_CLIENT_ID       = credentials('ARM_CLIENT_ID')
        ARM_CLIENT_SECRET   = credentials('ARM_CLIENT_SECRET')
        ARM_TENANT_ID       = credentials('ARM_TENANT_ID')
        ARM_SUBSCRIPTION_ID = credentials('ARM_SUBSCRIPTION_ID')
        // Normalizes branch name across different job types
        CURRENT_BRANCH = "${env.BRANCH_NAME ?: env.GIT_BRANCH ?: 'unknown'}"
    }

    stages {
        stage('Terraform Init & Validate') {
            steps {
                sh 'terraform init'
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    // Clean branch name (removes 'origin/' prefix if present)
                    def branch = env.CURRENT_BRANCH.replace('origin/', '')
                    echo "Planning for branch: ${branch}"
                    
                    sh "terraform plan -out=tfplan-${branch}"
                    stash name: 'tfplan', includes: "tfplan-${branch}"
                }
            }
        }

        stage('Terraform Apply') {
            when {
                // Ensure this only runs on the main branch
                expression { 
                    def branch = env.CURRENT_BRANCH.replace('origin/', '')
                    return branch == 'main' || branch == 'master'
                }
            }
            steps {
                script {
                    unstash 'tfplan'
                    timeout(time: 1, unit: 'HOURS') {
                        input message: "Deploy to Production?", ok: "Apply"
                    }
                    sh 'terraform apply -auto-approve tfplan-main'
                }
            }
        }
    }
}
