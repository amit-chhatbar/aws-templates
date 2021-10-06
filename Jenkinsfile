pipeline {
    agent any
      stages {
        stage ('SCM chckout')
        {
            steps {
                git 'https://github.com/amit-chhatbar/aws-templates.git'
                echo "Build Stage completed"
            }
        }
        stage ('Deploy')
        {
            steps {
                sh "cd ec2 ;tf apply"
                echo "Deploy Stare completed"
            }
        }
        stage ('Test')
        {
            steps {
                echo "Test Stage completed"
            }
        }
      }
}
