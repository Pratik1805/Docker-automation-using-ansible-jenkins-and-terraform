pipeline {
    agent any
    tools {
        terraform 'terraform' 
    }
    parameters {
        booleanParam(name: 'RUN_ANSIBLE', defaultValue: true, description: "Install Docker after provisioning EC2?")
    }

    environment {
        SSH_KEY_ID = 'ec2_ssh_key'
        GITHUB_SSH_KEY_ID = 'github-ssh-key'
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                // FIXED: 'git' is one function; parameters must be on the same line or separated by commas
                git url: 'git@github.com:Pratik1805/Docker-automation-using-ansible-jenkins-and-terraform.git',
                    branch: 'main',
                    credentialsId: "${env.GITHUB_SSH_KEY_ID}"
            }
        }

        stage('Terraform initialize') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Validate TF') {
            input {
                message "Do you want to apply this Plan?"
                ok "Apply Plan"
            }
            steps {
                echo 'Plan Accepted'
            }
        }

        stage('Apply TF') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }

        stage('Prepare Inventory & Wait') {
            steps {
                script {
                    // FIXED: Corrected 'returnStdout' typo
                    def InstanceIp = sh(script: "terraform output -raw ec2_public_ip", returnStdout: true).trim()
                    def InstanceId = sh(script: "terraform output -raw ec2_id_test", returnStdout: true).trim()

                    writeFile file: 'aws_hosts', text: "${InstanceIp}"

                    echo "Waiting for EC2 (${InstanceId}) to pass status checks..."
                    sh "aws ec2 wait instance-status-ok --region ap-south-1 --instance-ids ${InstanceId}" 
                }
            }
        }

        stage('Run Ansible') {
            when {
                expression { return params.RUN_ANSIBLE == true }
            }
            // FIXED: 'steps' must be outside/after 'when'
            steps {
                ansiblePlaybook(
                    credentialsId: "${env.SSH_KEY_ID}",
                    inventory: 'aws_hosts',
                    playbook: 'ansible/Install_docker.yml',
                    disableHostKeyChecking: true,
                    colorized: true
                )
            }
        }
    }

    post {
        always {
            // Good practice for Cloud Engineers: Clean up sensitive files
            sh 'rm -f tfplan aws_hosts'
            cleanWs()
        }
    }
}