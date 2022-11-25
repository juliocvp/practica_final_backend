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
        stage('Prepare environment') {
            steps {
                sh 'java -version'
                sh 'mvn --version'
            }
        }
        // stage('Code Promotion') {
        //     when {
        //         branch 'master'
        //         beforeAgent true
        //     }
        //     steps {
        //         script {
        //             echo 'Checking pom version'
        //             pom = readMavenPom file: "pom.xml"
        //             if((pom.version =~ "[-](SNAPSHOT)|[-](snapshot)").find(0)) {
        //                 echo 'Removing -SNAPSHOT suffix'
        //                 pom.version = (pom.version =~ "[-](SNAPSHOT)|[-](snapshot)").replaceAll("")
        //                 writeMavenPom file: "pom.xml", model: pom

        //                 echo 'Pushing changes to repo'
        //                 sh 'git show-ref'
        //                 sh 'git add .'
        //                 sh 'git commit -m "Removing -SNAPSHOT suffix"'
        //                 //sh ' git push origin master'
        //             } else {
        //                 echo 'Correct pom version'
        //             }
        //         }
        //     }
        // }
        // stage('Compile') {
        //     steps {
        //         sh "mvn compile -DskipTest"
        //     }
        // }
        // stage("Unit Tests") {
        //     steps {
        //         sh "mvn test"
        //         junit "target/surefire-reports/*.xml"
        //     }
        // }
        // stage("JaCoCo Tests") {
        //     steps {
        //         jacoco()
        //     }
        // }
        // stage("Quality Tests") {
        //     steps {
        //         echo 'Saltado por velocidad'
        //         //withSonarQubeEnv(credentialsId: "sonarqube-credentials", installationName: "sonarqube-server"){
        //             //sh "mvn clean verify sonar:sonar -DskipTests"
        //         //}
        //     }
        // }
        // stage('Package') {
        //     steps {
        //         sh "mvn clean package -DskipTests"
        //     }
        // }
        // stage('Build & Push') {
        //     steps {
        //         script {
        //             APP_IMAGE_NAME = "practica-final-backend"
        //             pom = readMavenPom file: "pom.xml"
        //             APP_IMAGE_TAG = pom.version

        //             container("kaniko") {
        //                 withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKER_HUB_PASS', usernameVariable: 'DOCKER_HUB_USER')]) {
        //                     AUTH = sh(script: """echo -n "${DOCKER_HUB_USER}:${DOCKER_HUB_PASS}" | base64""", returnStdout: true).trim()
        //                     command = """echo '{"auths": {"https://index.docker.io/v1/": {"auth": "${AUTH}"}}}' >> /kaniko/.docker/config.json"""
        //                     sh("""
        //                         set +x
        //                         ${command}
        //                         set -x
        //                         """)
        //                     sh "/kaniko/executor --dockerfile `pwd`/Dockerfile --context `pwd` --destination ${DOCKER_HUB_USER}/${APP_IMAGE_NAME}:${APP_IMAGE_TAG} --cleanup"
        //                 }
        //             }

        //         }
        //     }
        // }
        stage('Run test environment') {
            steps {
                sh "git clone https://github.com/juliocvp/kubernetes-helm-docker-config.git configuracion --branch test-implementation"

                script {
                    filename = 'configuracion/kubernetes-deployments/practica-final-backend/deployment.yaml'
                    data = readYaml file: filename
                    pom = readMavenPom file: "pom.xml"
                    data.image = "juliocvp/practica-final-backend:"+pom.version
                    sh "rm $filename"
                    writeYaml file: filename, data: data
                }

                sh "kubectl apply -f configuracion/kubernetes-deployments/practica-final-backend/deployment.yaml --kubeconfig=configuracion/kubernetes-config/config"
            }
        }
    }
}
