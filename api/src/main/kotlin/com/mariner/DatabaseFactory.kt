package com.mariner

import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource
import org.flywaydb.core.Flyway
import org.jetbrains.exposed.sql.Database
import java.net.URI

object DatabaseFactory {
  fun connect(config: AppConfig): HikariDataSource {
    val dataSource = createDataSource(config.databaseUrl)
    runMigrations(dataSource)
    Database.connect(dataSource)
    return dataSource
  }

  private fun createDataSource(url: String): HikariDataSource {
    val uri = URI(url)
    val username = uri.userInfo?.substringBefore(":")
      ?: error("DATABASE_SERVICE_URL must include username")
    val password = uri.userInfo?.substringAfter(":")
      ?: error("DATABASE_SERVICE_URL must include password")
    val port = if (uri.port == -1) 5432 else uri.port
    val jdbcUrl = "jdbc:postgresql://${uri.host}:$port${uri.path}"

    val hikariConfig = HikariConfig().apply {
      driverClassName = "org.postgresql.Driver"
      this.jdbcUrl = jdbcUrl
      this.username = username
      this.password = password
      maximumPoolSize = 5
      minimumIdle = 1
    }
    return HikariDataSource(hikariConfig)
  }

  private fun runMigrations(dataSource: HikariDataSource) {
    Flyway.configure()
      .dataSource(dataSource)
      .locations("classpath:db/migration")
      .load()
      .migrate()
  }
}
