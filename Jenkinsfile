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

        stage('Debug Branch') {
            steps {
                script {
                    echo "Jenkins BRANCH_NAME = ${env.BRANCH_NAME}"
                    env.EFFECTIVE_BRANCH = env.BRANCH_NAME ?: sh(
                        script: 'git rev-parse --abbrev-ref HEAD || echo DETACHED',
                        returnStdout: true
                    ).trim()
                    env.IS_MAIN_BRANCH = (env.EFFECTIVE_BRANCH == 'main').toString()
                    echo "Effective branch = ${env.EFFECTIVE_BRANCH}"
                    echo "Is main branch? = ${env.IS_MAIN_BRANCH}"
                }
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
