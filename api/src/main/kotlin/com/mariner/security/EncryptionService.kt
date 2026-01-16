package com.mariner.security

import java.security.SecureRandom
import java.util.Base64
import javax.crypto.Cipher
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec

class EncryptionService private constructor(
  private val secretKey: SecretKey
) {
  fun encrypt(plainText: String): String {
    val cipher = Cipher.getInstance(AES_GCM_TRANSFORMATION)
    val iv = ByteArray(GCM_IV_LENGTH_BYTES)
    secureRandom.nextBytes(iv)
    cipher.init(Cipher.ENCRYPT_MODE, secretKey, GCMParameterSpec(GCM_TAG_LENGTH_BITS, iv))
    val encrypted = cipher.doFinal(plainText.toByteArray(Charsets.UTF_8))
    val payload = iv + encrypted
    return Base64.getEncoder().encodeToString(payload)
  }

  fun decrypt(cipherText: String): String {
    val decoded = Base64.getDecoder().decode(cipherText)
    require(decoded.size > GCM_IV_LENGTH_BYTES) { "Ciphertext payload is too short" }
    val iv = decoded.copyOfRange(0, GCM_IV_LENGTH_BYTES)
    val encrypted = decoded.copyOfRange(GCM_IV_LENGTH_BYTES, decoded.size)
    val cipher = Cipher.getInstance(AES_GCM_TRANSFORMATION)
    cipher.init(Cipher.DECRYPT_MODE, secretKey, GCMParameterSpec(GCM_TAG_LENGTH_BITS, iv))
    val plain = cipher.doFinal(encrypted)
    return plain.toString(Charsets.UTF_8)
  }

  companion object {
    private const val AES_GCM_TRANSFORMATION = "AES/GCM/NoPadding"
    private const val GCM_IV_LENGTH_BYTES = 12
    private const val GCM_TAG_LENGTH_BITS = 128
    private val secureRandom = SecureRandom()

    fun fromBase64Key(base64Key: String): EncryptionService {
      val keyBytes = Base64.getDecoder().decode(base64Key)
      require(keyBytes.size == 32) { "PII_ENCRYPTION_KEY must decode to 32 bytes (256-bit)" }
      val secretKey = SecretKeySpec(keyBytes, "AES")
      return EncryptionService(secretKey)
    }
  }
}
