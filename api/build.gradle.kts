plugins {
  kotlin("jvm") version "2.0.10"
  kotlin("plugin.serialization") version "2.0.10"
  application
}

repositories {
  mavenCentral()
}

dependencies {
  implementation("io.ktor:ktor-server-core:2.3.12")
  implementation("io.ktor:ktor-server-netty:2.3.12")
  implementation("io.ktor:ktor-server-content-negotiation:2.3.12")
  implementation("io.ktor:ktor-serialization-kotlinx-json:2.3.12")
  implementation("io.ktor:ktor-server-status-pages:2.3.12")
  implementation("io.ktor:ktor-server-call-logging:2.3.12")
  implementation("io.ktor:ktor-server-cors:2.3.12")

  implementation("org.jetbrains.kotlinx:kotlinx-datetime:0.6.1")
  implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.7.2")

  implementation("org.jetbrains.exposed:exposed-core:0.56.0")
  implementation("org.jetbrains.exposed:exposed-dao:0.56.0")
  implementation("org.jetbrains.exposed:exposed-jdbc:0.56.0")
  implementation("org.jetbrains.exposed:exposed-kotlin-datetime:0.56.0")
  implementation("org.jetbrains.exposed:exposed-java-time:0.56.0")

  implementation("org.flywaydb:flyway-core:10.16.0")
  implementation("org.flywaydb:flyway-database-postgresql:10.16.0")

  implementation("com.zaxxer:HikariCP:5.1.0")
  implementation("org.postgresql:postgresql:42.7.3")

  implementation("ch.qos.logback:logback-classic:1.5.6")

  testImplementation(kotlin("test"))
  testImplementation("io.ktor:ktor-server-tests:2.3.12")
  testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.9.0")
}

application {
  mainClass.set("com.mariner.ApplicationKt")
}

kotlin {
  jvmToolchain(21)
}

tasks.test {
  useJUnitPlatform()
}
