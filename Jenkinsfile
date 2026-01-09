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

        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Detect Branch') {
            steps {
                script {
                    def branch = env.BRANCH_NAME

                    if (!branch) {
                        branch = sh(
                            script: 'git symbolic-ref --short HEAD || echo DETACHED',
                            returnStdout: true
                        ).trim()
                    }

                    echo "Detected branch: ${branch}"
                    env.IS_MAIN_BRANCH = (branch == 'main').toString()
                }
            }
        }

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
                    if (env.IS_MAIN_BRANCH == 'true') {
                        sh 'terraform plan -out=tfplan-main'
                    } else {
                        sh 'terraform plan -out=tfplan-non-main'
                        echo 'Apply is BLOCKED for non-main branches'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { env.IS_MAIN_BRANCH == 'true' }
            }
            steps {
                script {
                    // 🔐 HARD SAFETY CHECK (cannot be bypassed)
                    if (env.IS_MAIN_BRANCH != 'true') {
                        error('SECURITY BLOCK: Terraform Apply attempted on non-main branch')
                    }

                    input message: 'Do you want to Apply Terraform changes?', ok: 'Apply'

                    // ✅ Apply EXACT saved plan
                    sh 'terraform apply tfplan-main'
                }
            }
        }
    }

    post {
        aborted {
            echo 'Terraform apply was aborted by user'
        }
        failure {
            echo 'Terraform pipeline failed!'
        }
        always {
            sh 'terraform version'
        }
    }
}
