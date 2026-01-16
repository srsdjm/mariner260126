FROM gradle:8.9-jdk21 AS build

WORKDIR /home/gradle/src

# Cache dependency resolution so source-only changes don't re-download artifacts.
COPY gradle gradle
COPY gradlew gradlew
COPY gradlew.bat gradlew.bat
COPY build.gradle.kts settings.gradle.kts ./
RUN gradle --no-daemon dependencies

COPY src src
RUN gradle installDist --no-daemon

FROM eclipse-temurin:21-jre

WORKDIR /app
RUN apt-get update \
  && apt-get install -y --no-install-recommends curl \
  && rm -rf /var/lib/apt/lists/*
COPY --from=build /home/gradle/src/build/install/api /app

EXPOSE 8080
CMD ["/app/bin/api"]
