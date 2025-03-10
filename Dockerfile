# Stage 1: Build the application
FROM maven:3.8.8-eclipse-temurin-8 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src/ src/
RUN mvn package -DskipTests

# Stage 2: Create a lightweight image
FROM openjdk:8-jdk-alpine
WORKDIR /app
COPY --from=builder /app/target/devops-integration.jar devops-integration.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/devops-integration.jar"]
