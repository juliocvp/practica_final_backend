FROM adoptopenjdk/openjdk11:alpine

ENV SPRING_OUTPUT_ANSI_ENABLED=ALWAYS

RUN echo "PWD is: $PWD"

RUN echo $(ls -1a)
RUN echo $(ls -1a ./home/jenkins/agent/workspace/Practica_Final_Backend_develop/target)

COPY ./home/jenkins/agent/workspace/Practica_Final_Backend_develop/target/spring-boot-jpa-h2-*.jar ./home/jenkins/agent/workspace/Practica_Final_Backend_develop/app.jar

CMD java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar ./home/jenkins/agent/workspace/Practica_Final_Backend_develop/app.jar