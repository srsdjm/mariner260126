package com.mariner

import com.mariner.http.ApiException
import com.mariner.http.ProblemDetail
import com.mariner.pq.PqRepository
import com.mariner.pq.pqRoutes
import com.mariner.security.EncryptionService
import io.ktor.http.HttpStatusCode
import io.ktor.serialization.kotlinx.json.json
import io.ktor.server.application.Application
import io.ktor.server.application.ApplicationStopping
import io.ktor.server.application.call
import io.ktor.server.application.install
import io.ktor.server.engine.embeddedServer
import io.ktor.server.netty.Netty
import io.ktor.server.plugins.callloging.CallLogging
import io.ktor.server.plugins.contentnegotiation.ContentNegotiation
import io.ktor.server.plugins.cors.routing.CORS
import io.ktor.server.plugins.statuspages.StatusPages
import io.ktor.server.response.respond
import io.ktor.server.response.respondText
import io.ktor.server.routing.get
import io.ktor.server.routing.routing
import kotlinx.serialization.json.Json
import org.slf4j.LoggerFactory

private val logger = LoggerFactory.getLogger("com.mariner.Application")

fun main() {
  embeddedServer(Netty, port = 8080) {
    module()
  }.start(wait = true)
}

fun Application.module() {
  val appConfig = AppConfig.fromEnv()
  val dataSource = DatabaseFactory.connect(appConfig)
  val encryptionService = EncryptionService.fromBase64Key(appConfig.piiEncryptionKey)
  val pqRepository = PqRepository(encryptionService)

  install(ContentNegotiation) {
    json(
      Json {
        prettyPrint = false
        ignoreUnknownKeys = true
        explicitNulls = false
      }
    )
  }
  if (appConfig.corsAllowedOrigins.isNotEmpty()) {
    install(CORS) {
      allowMethod(io.ktor.http.HttpMethod.Get)
      allowMethod(io.ktor.http.HttpMethod.Post)
      allowMethod(io.ktor.http.HttpMethod.Put)
      allowMethod(io.ktor.http.HttpMethod.Delete)
      allowMethod(io.ktor.http.HttpMethod.Options)
      allowHeader(io.ktor.http.HttpHeaders.ContentType)
      allowHeader(io.ktor.http.HttpHeaders.Authorization)

      appConfig.corsAllowedOrigins.forEach { origin ->
        val uri = java.net.URI(origin)
        val hostWithPort = if (uri.port == -1) uri.host else "${uri.host}:${uri.port}"
        allowHost(
          host = hostWithPort,
          schemes = listOf(uri.scheme),
          subDomains = emptyList()
        )
      }
    }
  }
  install(CallLogging)
  install(StatusPages) {
    exception<ApiException> { call, cause ->
      call.respond(cause.httpStatus, cause.problem)
    }
    exception<Throwable> { call, cause ->
      logger.error("Unhandled error", cause)
      call.respond(
        HttpStatusCode.InternalServerError,
        ProblemDetail(
          type = "about:blank",
          title = "Internal server error",
          status = HttpStatusCode.InternalServerError.value,
          detail = "Something went wrong. Please try again."
        )
      )
    }
  }

  routing {
    get("/health") {
      call.respondText("ok")
    }
    pqRoutes(pqRepository)
  }

  environment.monitor.subscribe(ApplicationStopping) {
    dataSource.close()
  }
}
