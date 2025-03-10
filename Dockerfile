# First stage: Build the application
FROM maven:3.8.8-openjdk-8 AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Second stage: Run the application
FROM openjdk:8-jdk-alpine
WORKDIR /app
COPY --from=builder /app/target/devops-integration.jar devops-integration.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/devops-integration.jar"]
