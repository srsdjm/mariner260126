package com.mariner.security

import java.util.Base64
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

class EncryptionServiceTest {
  @Test
  fun `encrypt and decrypt round trip`() {
    val keyBytes = ByteArray(32) { 1 }
    val key = Base64.getEncoder().encodeToString(keyBytes)
    val service = EncryptionService.fromBase64Key(key)

    val cipher = service.encrypt("123456789")
    val plain = service.decrypt(cipher)

    assertEquals("123456789", plain)
  }

  @Test
  fun `invalid key length throws`() {
    assertFailsWith<IllegalArgumentException> {
      EncryptionService.fromBase64Key("short")
    }
  }
}
