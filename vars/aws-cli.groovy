def call() {
    pipeline{
    agent{label 'shopizer'}
    stages{
        stage('vcs'){
        steps{
            step{
            git url:'https://github.com/saisatyateja/cli_lib.git',
            branch:'main'
            
           }
        }
        stage('build'){
            steps{
                step{
                  sh 'bash aws_cli_v0.1.sh'
                }
           }
        }
    }
}
}