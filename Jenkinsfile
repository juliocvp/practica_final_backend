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
  - name: "kaniko"
    image: "gcr.io/kaniko-project/executor:debug"
    command:
    - "cat"
    imagePullPolicy: "IfNotPresent"
    tty: true
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
        // stage('Prepare environment') {
        //     steps {
        //         container("shell") {
        //             sh 'java -version'
        //             sh 'mvn --version'
        //         }
        //     }
        // }
        stage('Code Promotion') {
            when {
                branch 'master'
                beforeAgent true
            }
            steps {
                script {
                    container("shell") {
                        echo 'Checking pom version'
                        pom = readMavenPom file: "pom.xml"
                        if((pom.version =~ "[-](SNAPSHOT)|[-](snapshot)").find(0)) {
                            echo 'Removing -SNAPSHOT suffix'
                            pom.version = (pom.version =~ "[-](SNAPSHOT)|[-](snapshot)").replaceAll("")
                            writeMavenPom file: "pom.xml", model: pom

                            echo 'Pushing changes to repo'
                            sh 'git show-ref'
                            sh 'git add .'
                            sh 'git commit -m "Removing -SNAPSHOT suffix"'
                            //sh ' git push origin master'
                        } else {
                            echo 'Correct pom version'
                        }
                    }
                }
            }
        }
        stage('Compile') {
            steps {
                container("shell") {
                    sh "mvn compile -DskipTest"
                }
            }
        }
        // stage("Unit Tests") {
        //     steps {
        //         container("shell") {
        //             sh "mvn test"
        //             junit "target/surefire-reports/*.xml"
        //         }
        //     }
        // }
        // stage("JaCoCo Tests") {
        //     steps {
        //         container("shell") {
        //             jacoco()
        //         }
        //     }
        // }
        stage("Quality Tests") {
            steps {
                container("shell") {
                    echo 'Saltado por velocidad'
                }
                //withSonarQubeEnv(credentialsId: "sonarqube-credentials", installationName: "sonarqube-server"){
                    //sh "mvn clean verify sonar:sonar -DskipTests"
                //}
            }
        }
        stage('Package') {
            steps {
                container("shell") {
                    sh "mvn clean package -DskipTests"
                }
            }
        }
        stage('Build & Push') {
            steps {
                script {
                    APP_IMAGE_NAME = "practica-final-backend"
                    pom = readMavenPom file: "pom.xml"
                    APP_IMAGE_TAG = pom.version

                    container("kaniko") {
                        sh 'pwd'
                        sh 'ls -la target'
                        withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKER_HUB_PASS', usernameVariable: 'DOCKER_HUB_USER')]) {
                            AUTH = sh(script: """echo -n "${DOCKER_HUB_USER}:${DOCKER_HUB_PASS}" | base64""", returnStdout: true).trim()
                            command = """echo '{"auths": {"https://index.docker.io/v1/": {"auth": "${AUTH}"}}}' >> /kaniko/.docker/config.json"""
                            sh("""
                                set +x
                                ${command}
                                set -x
                                """)
                            sh "/kaniko/executor --dockerfile `pwd`/Dockerfile --context `pwd` --destination ${DOCKER_HUB_USER}/${APP_IMAGE_NAME}:${APP_IMAGE_TAG} --cleanup"
                        }
                    }

                }
            }
        }
    }
}
