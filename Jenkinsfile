pipeline {
  agent any

  parameters {
    booleanParam(name: 'RUN_ANSIBLE', defaultValue: true, description: "Install Docker after provisioning EC2?")
  }

  environment {
    SSH_KEY_ID = 'ec2_ssh_key'
    GITHUB_SSH_KEY_ID = 'github-ssh-key'
  }

  stages{

    stage('Checkout Source Code') {
      steps{
        git url: 'git@github.com:Pratik1805/Docker-automation-using-ansible-jenkins-and-terraform.git'
        branch: 'main'
        credentialsId: "${env.GITHUB_SSH_KEY_ID}"
      }
    }

    stage('Terraform initialize'){
      steps {
        sh 'terraform init'
      }
    }
    stage('Terraform plan'){
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
        sh '''
          terraform apply -auto-approve tfplan
        '''
      }
    }
    stage('Prepare Inventroy & Wait'){
      steps{
        script{
          // Capture IP and ID using -raw for clean strings
          def InstanceIp = sh(script: "terraform output -raw ec2_public_ip",retrunStdout: true).trim()
          def InstanceId = sh(script: "terraform output -raw ec2_id_test",retrunStdout: true).trim()

          //Create the inventory file for ansible
          writeFile file: 'aws_hosts', text: "${InstanceIp},"

          echo "Waiting for EC2 (${InstanceId}) to pass status checks..."

          sh "aws ec2 wait instance-status-ok --region ap-south-1 --instance-ids ${InstanceId}" 
        }
      }
    }
    stage('Run Ansible'){
      when {
        expression {
          return params.RUN_ANSIBLE == true
        }
        steps{
          ansiblePlaybook(
            credentialsId: "${env.SSH_KEY_ID}",
            inventory: 'aws_hosts',
            playbook: 'ansible/Install_docker.yml'
            disableHostKeyChecking: true,
            colorized: true
          )
        }
      }
    }
  }
}