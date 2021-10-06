pipeline {
    agent any
      stages {
        stage ('SCM checkout')
        {
            steps {
             	checkout scm
	 //     git 'https://github.com/amit-chhatbar/aws-templates.git'
                echo "Build Stage completed"
            }
        }
        stage ('Deploy')
        {
            steps {
                sh "/usr/local/bin/tf init"
                sh "/usr/local/bin/tf apply  -auto-approve" 
                echo "Deploy Stage completed"
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
