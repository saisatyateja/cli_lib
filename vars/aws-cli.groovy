def call() {
    pipeline{
    agent{label 'shopizer'}
    stages{
        stage('vcs'){
            steps{
                git url:'https://github.com/saisatyateja/cli_lib.git',
                    branch:'main'
            }
        }
        stage('build'){
            steps{
                sh 'bash aws_cli_v0.1.sh'
            }
        }
    }
}
}