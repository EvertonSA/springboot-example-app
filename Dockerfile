# Mvn Specific
# ---- Builder ----
FROM maven:3.6-jdk-8-alpine AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn -e -B dependency:resolve 
COPY src ./src
RUN mvn -e -B package

# Java Specific
# ---- Runner ----
FROM openjdk:8-jre-alpine
COPY --from=builder /app/target/spring-boot-rest-example-0.5.0.war /app.war
CMD ["java", "-jar", "-Dspring.profiles.active=test", "/app.war"]