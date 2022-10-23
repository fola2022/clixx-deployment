#!/usr/bin/env groovy
pipeline {
    agent none
    stages {
        stage("test") {
            steps {
                script  {
                    echo "Testing the application..."
                    echo "Executing pipeline for branch $BRANCH_NAME"

                }
            }
        }
        stage("build") {
            when    {
                expression  {
                    BRANCH_NAME == "master"
                }
            }
            steps {
                script  {
                    echo "Building the application..."

                }
            }
        }
        stage("deploy") {
            when    {
                expression  {
                    BRANCH_NAME == "master"
                }
            }
            steps {
                script  {
                    echo "Deploying the application..."
                }
            }
        }
    }
}
        
    

/*pipeline {
    agent any
    parameters {
        credentials credentialType: 'com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl', defaultValue: 'stack-terraform', name: 'AWS', required: false
    }

    environment {
        PATH = "${PATH}:${getTerraformPath()}"
    }

    stages{
        stage('terraform init'){
            steps {
                slackSend (color: '#FFFF00', message: "STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
                sh "terraform init"
            }
        }

        stage('terraform plan'){
            steps {
                 sh "terraform plan -out=tfplan -input=false"
            }
        }

        stage('Final Deployment Approval') {
            steps {
                script {
                def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
                }
            }
        }

        stage('Terraform Apply'){
            steps {
                 sh "terraform apply -input=false tfplan"
            }
        }

        stage('Terraform Destroy'){
            steps {
                 sh "terraform destroy -auto-approve"
            }
        }

    }
}

def getTerraformPath(){
        def tfHome= tool name: 'terraform-14', type: 'terraform'
        return tfHome
    }
*/



//def getTerraformPath(){
        //def tfHome= tool name: 'terraform-14', type: 'terraform'
        //return tfHome
    //}
