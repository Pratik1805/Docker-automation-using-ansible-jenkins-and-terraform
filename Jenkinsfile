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
            when {
                expression { return fileExists('tfplan') }
            }
            input {
                message "Do you want to apply this Plan?"
                ok "Apply Plan"
            }
            steps {
                echo 'Plan file found and accepted by user.'
            }
        }

        stage('Apply TF') {
            steps {
                sh 'terraform apply tfplan'
            }
        }

        stage('Prepare Inventory & Wait') {
            steps {
                script {
                    // Since 'Apply' was successful, these outputs will now definitely exist in S3
                    def InstanceIp = sh(script: "terraform output -no-color -raw ec2_public_ip", returnStdout: true).replaceAll(/[^a-zA-Z0-9-]/, '').trim()
                    def InstanceId = sh(script: "terraform output -no-color -raw ec2_id_test", returnStdout: true).replaceAll(/[^a-zA-Z0-9-]/, '').trim()

                    writeFile file: 'aws_hosts', text: "${InstanceIp}"

                    echo "Waiting for EC2 (${InstanceId}) to pass status checks..."
                    sh "aws ec2 wait instance-status-ok --region ap-south-1 --instance-ids ${InstanceId}" 
                }
            }
        }

        stage('Run Ansible') {
            when {
                allOf {
                    expression { return params.RUN_ANSIBLE == true }
                    expression { return fileExists('aws_hosts') }
                }
            }
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
            sh 'rm -f tfplan aws_hosts'
            cleanWs()
        }
    }
}