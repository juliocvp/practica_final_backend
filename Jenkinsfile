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
        //             APP_IMAGE_TAG = "latest"

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

                // script {
                //     filename = 'configuracion/kubernetes-deployments/practica-final-backend/deployment.yaml'
                //     data = readYaml file: filename
                //     pom = readMavenPom file: "pom.xml"
                //     data.image = "juliocvp/practica-final-backend:"+pom.version
                //     sh "rm $filename"
                //     writeYaml file: filename, data: data
                // }

                // sh 'ls -la ./configuracion/kubernetes-deployments/practica-final-backend/'

                sh "kubectl apply -f configuracion/kubernetes-deployments/practica-final-backend/deployment.yaml --kubeconfig=configuracion/kubernetes-config/config"
            }
        }
        stage ("Performance Test") {
            steps{
                sleep 30
                script {
                    sh 'git clone https://github.com/juliocvp/jmeter-docker.git'
                    dir('jmeter-docker') {
                        // Setup
                        sh 'wget https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.5.tgz'
                        sh 'tar xvf apache-jmeter-5.5.tgz'
                        sh 'cp plugins/*.jar apache-jmeter-5.5/lib/ext'
                        sh 'mkdir test'
                        sh 'mkdir apache-jmeter-5.5/test'
                        sh 'cp ../src/main/resources/*.jmx apache-jmeter-5.5/test/'
                        sh 'chmod +775 ./build.sh && chmod +775 ./run.sh && chmod +775 ./entrypoint.sh'
                        sh 'rm -r apache-jmeter-5.5.tgz'
                        sh 'tar -czvf apache-jmeter-5.5.tgz apache-jmeter-5.5'
                        sh './build.sh'
                        sh 'rm -r apache-jmeter-5.5 && rm -r apache-jmeter-5.5.tgz'
                        sh 'cp ../src/main/resources/perform_test.jmx test'
                        // Run
                        sh './run.sh -n -t test/perform_test.jmx -l test/perform_test.jtl'
                        sh 'docker cp jmeter:/home/jmeter/apache-jmeter-5.5/test/perform_test.jtl $(pwd)/test'
                        perfReport './test/perform_test.jtl'
                        BlazeMeterTest: {
                            sh 'bzt ./test/perform_test.jtl -report'
                        }
                    }
                }
            }
        }
        // stage("Nexus") {
        //     steps {
        //         script {
        //             // Read POM xml file using 'readMavenPom' step , this step 'readMavenPom' is included in: https://plugins.jenkins.io/pipeline-utility-steps
        //             pom = readMavenPom file: "pom.xml"
        //             // Find built artifact under target folder
        //             filesByGlob = findFiles(glob: "target/*.${pom.packaging}")
        //             // Print some info from the artifact found
        //             echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
        //             // Extract the path from the File found
        //             artifactPath = filesByGlob[0].path
        //             // Assign to a boolean response verifying If the artifact name exists
        //             artifactExists = fileExists artifactPath                    
        //             if(artifactExists) {
        //                 echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}"                   
        //                 nexusArtifactUploader(
        //                     nexusVersion: NEXUS_VERSION,
        //                     protocol: NEXUS_PROTOCOL,
        //                     nexusUrl: NEXUS_URL,
        //                     groupId: pom.groupId,
        //                     version: pom.version,
        //                     repository: NEXUS_REPOSITORY,
        //                     credentialsId: NEXUS_CREDENTIAL_ID,
        //                     artifacts: [
        //                         // Artifact generated such as .jar, .ear and .war files.
        //                         [artifactId: pom.artifactId,
        //                         classifier: "",
        //                         file: artifactPath,
        //                         type: pom.packaging],
        //                         // Lets upload the pom.xml file for additional information for Transitive dependencies
        //                         [artifactId: pom.artifactId,
        //                         classifier: "",
        //                         file: "pom.xml",
        //                         type: "pom"]
        //                     ]
        //                 )                    
        //             } else {
        //                 error "*** File: ${artifactPath}, could not be found"
        //             }
        //         }
        //     }
        // }
        // stage('Deploy') {
        //     steps {
        //         echo 'Pendiente Opcional'
        //     }
        // }
    }
    post {
        always {
          echo 'Post always'
        }
    }
}
