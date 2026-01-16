package com.mariner

data class AppConfig(
  val databaseUrl: String,
  val piiEncryptionKey: String,
  val corsAllowedOrigins: List<String>
) {
  companion object {
    fun fromEnv(): AppConfig {
      val dbUrl = System.getenv("DATABASE_SERVICE_URL")?.takeIf { it.isNotBlank() }
        ?: error("DATABASE_SERVICE_URL is required")
      val piiKey = System.getenv("PII_ENCRYPTION_KEY")?.takeIf { it.isNotBlank() }
        ?: error("PII_ENCRYPTION_KEY is required (Base64-encoded 256-bit key)")
      val corsAllowedOrigins = System.getenv("CORS_ALLOWED_ORIGINS")
        ?.split(",")
        ?.map { it.trim() }
        ?.filter { it.isNotBlank() }
        ?: emptyList()
      return AppConfig(dbUrl, piiKey, corsAllowedOrigins)
    }
  }
}
