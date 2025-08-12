pipeline {
  agent any

  environment {
    SONAR_TOKEN        = credentials('sonar-token')   // Jenkins credential ID (Secret text)
    SONAR_SCANNER_HOME = tool 'sonarqube'             // Tools > SonarQube Scanner name
  }

  stages {
    // If your job is already "Pipeline script from SCM", checkout happens automatically.
    // If you really want a checkout stage, uncomment and point to YOUR repo:
    // stage('Git Checkout') {
    //   steps { git branch: 'main', url: 'https://github.com/SheralRichard/custompolicy.git' }
    // }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('sonarserver') {              // System > SonarQube servers name
          sh """
            ${SONAR_SCANNER_HOME}/bin/sonar-scanner \
            -Dsonar.projectKey=jenkins1234 \
            -Dsonar.sources=. \
            -Dsonar.host.url=$SONAR_HOST_URL \
            -Dsonar.token=${SONAR_TOKEN}
          """
        }
      }
    }

    stage('Publish SonarQube Results') {
  steps {
    script {
      timeout(time: 15, unit: 'MINUTES') {
        // fail build if gate is Red? set abortPipeline: true
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
          sh 'az login --service-principal -u $AZURE_APP_ID -p $AZURE_PASSWORD --tenant $AZURE_TENANT'
          sh 'az account set --subscription 3581aac0-8515-47ec-85ea-b6de3c2854b0'  // <- replace if your sub ID differs
        }
      }
    }

    stage('Terraform Initialize') { steps { sh 'terraform init' } }
    stage('Terraform validate')   { steps { sh 'terraform validate' } }
    stage('Terraform Plan')       { steps { sh 'terraform plan -out=tfplan' } }
    stage('Terraform Apply')      { steps { sh 'terraform apply -auto-approve tfplan' } }
  }
}

