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
                sh "tf apply"
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
