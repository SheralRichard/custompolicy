pipeline {
  agent any

  environment {
    // Jenkins credentials you already created
    SONAR_TOKEN        = credentials('sonar-token')   // Secret text: token generated in SonarQube 9.9
    SONAR_SCANNER_HOME = tool 'sonarqube'             // Tools > SonarQube Scanner name
  }

  stages {

    // SCM checkout is handled by "Pipeline script from SCM" job config

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('sonarserver') {             // Manage Jenkins > System > SonarQube servers (Name)
          // Use single quotes so Groovy doesn't interpolate; shell expands $VARS
          sh '''
            ${SONAR_SCANNER_HOME}/bin/sonar-scanner \
            -Dsonar.projectKey=jenkins1234 \
            -Dsonar.sources=. \
            -Dsonar.host.url=$SONAR_HOST_URL \
            -Dsonar.login=$SONAR_TOKEN
          '''
        }
      }
    }

    stage('Publish SonarQube Results') {
      steps {
        script {
          // Requires SonarQube -> Jenkins webhook at http://<VM_PUBLIC_IP>:8080/sonarqube-webhook/
          timeout(time: 15, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: false
          }
        }
      }
    }

    stage('Login to Azure') {
      steps {
        withCredentials([
          usernamePassword(credentialsId: 'azure-sp', usernameVariable: 'AZURE_APP_ID', passwordVariable: 'AZURE_PASSWORD'),
          string(credentialsId: 'azure-tenant', variable: 'AZURE_TENANT')
        ]) {
          sh '''
            az login --service-principal -u "$AZURE_APP_ID" -p "$AZURE_PASSWORD" --tenant "$AZURE_TENANT"
            az account set --subscription 3581aac0-8515-47ec-85ea-b6de3c2854b0
          '''
        }
      }
    }

    stage('Terraform Initialize') { steps { sh 'terraform init' } }
    stage('Terraform Validate')   { steps { sh 'terraform validate' } }
    stage('Terraform Plan')       { steps { sh 'terraform plan -out=tfplan' } }
    stage('Terraform Apply')      { steps { sh 'terraform apply -auto-approve tfplan' } }
  }
}
