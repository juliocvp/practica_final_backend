pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: shell
    image: juliocvp/jenkins-nodo-java-bootcamp:4.0
    volumeMounts:
    - mountPath: /var/run/docker.sock
      name: docker-socket-volume
    securityContext:
      privileged: true
  volumes:
  - name: docker-socket-volume
    hostPath:
      path: /var/run/docker.sock
      type: Socket
    command:
    - sleep
    args:
    - infinity
'''
            defaultContainer 'shell'
        }
    }

    stages {
        stage('Prepare environment') {
            steps {
                sh 'java -version'
                sh 'mvn --version'
            }
        }
        stage('Code Promotion') {
            when {
                branch 'master'
                beforeAgent true
            }
            steps {
                script {
                    echo 'Checking pom version'
                    pom = readMavenPom file: "pom.xml"
                    if((pom.version =~ "[-](SNAPSHOT)|[-](snapshot)").find(0)) {
                        echo 'Removing -SNAPSHOT suffix'
                        pom.version = (pom.version =~ "[-](SNAPSHOT)|[-](snapshot)").replaceAll("")
                        writeMavenPom file: "pom.xml", model: pom

                        echo 'Pushing changes to repo'
                        sh 'git pull'
                        sh 'git show-ref'
                        sh 'git add .'
                        sh 'git commit -m "Removing -SNAPSHOT suffix"'
                        sh ' git push origin master'
                    } else {
                        echo 'Correct pom version'
                    }
                }
            }
        }
    }
}
