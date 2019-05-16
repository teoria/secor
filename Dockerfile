FROM ubuntu:18.04 as builder

RUN apt-get update
RUN apt-get install -y \
    openjdk-8-jdk \
    maven \
    git

RUN rm -Rf /etc/ssl/certs/java/cacerts ; update-ca-certificates -f

#COPY src pom.xml Makefile /opt/secor/
COPY . /opt/secor
WORKDIR /opt/secor
# Set java home to 8
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
# Compile secor
RUN mvn install
RUN mvn package -DskipTests -Pkafka-2.0.0

FROM openjdk:8-jre-alpine
RUN rm /etc/ssl/certs/java/cacerts ; update-ca-certificates -f
RUN mkdir -p /opt/secor

# Copy previous built tar.gz to final docker image
COPY --from=builder /opt/secor/target/secor-*-bin.tar.gz /opt/secor/

WORKDIR /opt/secor
RUN tar -xvf secor-*-bin.tar.gz

COPY src/main/scripts/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["sh", "/docker-entrypoint.sh"]
