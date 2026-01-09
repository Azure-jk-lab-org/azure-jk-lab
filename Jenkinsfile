pipeline {
    agent { label 'slave1' }

    environment {
        ARM_CLIENT_ID       = credentials('ARM_CLIENT_ID')
        ARM_CLIENT_SECRET   = credentials('ARM_CLIENT_SECRET')
        ARM_TENANT_ID       = credentials('ARM_TENANT_ID')
        ARM_SUBSCRIPTION_ID = credentials('ARM_SUBSCRIPTION_ID')
        IS_MAIN_BRANCH      = 'false'
        EFFECTIVE_BRANCH    = ''
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

                    if (!branch || branch == 'null') {
                        branch = sh(
                            script: 'git symbolic-ref --short HEAD || echo DETACHED',
                            returnStdout: true
                        ).trim()
                    }

                    echo "Detected branch: ${branch}"

                    env.EFFECTIVE_BRANCH = branch
                    env.IS_MAIN_BRANCH = (branch == 'main').toString()
                }
            }
        }

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
                    if (env.IS_MAIN_BRANCH == 'true') {
                        echo "Running Terraform plan for main"
                        sh 'terraform plan -out=tfplan-main'
                    } else {
                        echo "Running Terraform plan for ${env.EFFECTIVE_BRANCH}"
                        sh 'terraform plan -out=tfplan-non-main'
                        echo "Apply will be blocked"
                    }
                }
               
            }
        }

        stage('Terraform Apply') {
            when {
                expression { env.IS_MAIN_BRANCH == 'true' }
            }

            steps {
                echo "Main branch confirmed — apply requires approval"
                input message: 'Do you want to apply Terraform changes?', ok: 'Apply'
                sh 'terraform apply tfplan-main'
            }
        }
    }

    post {
        always {
            sh 'terraform version'
        }
        aborted {
            echo 'Terraform apply was denied by user'
        }
        failure {
            echo 'Terraform pipeline failed!'
        }
    }
}
