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
                  // 1. Capture the ID while throwing away all warnings/errors (2>/dev/null)
                  def rawId = sh(script: "terraform output -no-color -raw ec2_id_test 2>/dev/null", returnStdout: true).trim()
                  def rawIp = sh(script: "terraform output -no-color -raw ec2_public_ip 2>/dev/null", returnStdout: true).trim()

                  // 2. Pro-level safeguard: Keep only the ID format (starts with 'i-' followed by alphanumeric)
                  def InstanceId = (rawId =~ /i-[a-z0-9]+/)[0]
                  def InstanceIp = rawIp.split()[0] // Takes the first word only, ignoring any trailing warnings

                  writeFile file: 'aws_hosts', text: "${InstanceIp}"

                  echo "DEBUG: Final Cleaned ID is: ${InstanceId}"
    
                  // 3. Run the waiter
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