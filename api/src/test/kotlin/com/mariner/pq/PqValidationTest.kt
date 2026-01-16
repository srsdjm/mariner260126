package com.mariner.pq

import com.mariner.http.ApiException
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertTrue

class PqValidationTest {
  @Test
  fun `valid request normalizes and parses`() {
    val request = PqRequest(
      firstName = " Ada ",
      lastName = " Lovelace ",
      dob = "1990-01-02",
      ssn = "123-45-6789"
    )

    val normalized = validatePqRequest(request)

    assertEquals("Ada", normalized.firstName)
    assertEquals("Lovelace", normalized.lastName)
    assertEquals("1990-01-02", normalized.dob.toString())
    assertEquals("123456789", normalized.ssnDigits)
    assertEquals("6789", normalized.ssnLast4)
  }

  @Test
  fun `invalid request surfaces field errors`() {
    val request = PqRequest(
      firstName = " ",
      lastName = "",
      dob = "not-a-date",
      ssn = "1234"
    )

    val exception = assertFailsWith<ApiException> {
      validatePqRequest(request)
    }

    val fieldErrors = exception.problem.fieldErrors
    assertTrue(fieldErrors?.containsKey("firstName") == true)
    assertTrue(fieldErrors?.containsKey("lastName") == true)
    assertTrue(fieldErrors?.containsKey("dob") == true)
    assertTrue(fieldErrors?.containsKey("ssn") == true)
  }
}
