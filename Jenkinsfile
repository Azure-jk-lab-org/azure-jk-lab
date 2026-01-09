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
                    // Try Jenkins BRANCH_NAME first
                    def branch = env.BRANCH_NAME

                    // Fallback if null, empty, or 'null'
                    if (!branch || branch == 'null') {
                        branch = sh(
                            script: """
                                git symbolic-ref --short HEAD 2>/dev/null || \
                                git rev-parse --abbrev-ref HEAD 2>/dev/null
                            """,
                            returnStdout: true
                        ).trim()
                    }

                    // If still detached or HEAD, try to find branch from origin
                    if (!branch || branch == 'HEAD' || branch == 'DETACHED') {
                        branch = sh(
                            script: """
                                git for-each-ref --format="%(refname:short)" refs/remotes/origin/ | grep main || echo main
                            """,
                            returnStdout: true
                        ).trim()
                    }

                    echo "Detected branch: ${branch}"

                    env.EFFECTIVE_BRANCH = branch
                    env.IS_MAIN_BRANCH = (branch == 'main').toString()
                    echo "IS_MAIN_BRANCH = ${env.IS_MAIN_BRANCH}"
                }

                // Debug info
                sh 'git log -1 --oneline'
                sh 'git branch --show-current || echo "detached"'
            }
        }

        stage('Terraform Initialization') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Validation') {
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
                        echo "Running Terraform plan for branch: ${env.EFFECTIVE_BRANCH}"
                        sh "terraform plan -out=tfplan-${env.EFFECTIVE_BRANCH}"
                        echo "Terraform apply will be blocked for non-main branches"
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { env.IS_MAIN_BRANCH == 'true' }
            }
            steps {
                echo "Main branch confirmed — apply requires manual approval"
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
            echo 'Terraform apply was aborted by user'
        }
        failure {
            echo 'Terraform pipeline failed!'
        }
    }
}
