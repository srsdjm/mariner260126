package com.mariner.pq

import com.mariner.http.validationProblem
import kotlinx.datetime.Clock
import kotlinx.datetime.LocalDate
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime

fun validatePqRequest(request: PqRequest): PqNormalizedInput {
  val fieldErrors = mutableMapOf<String, MutableList<String>>()

  val firstName = request.firstName.trim()
  if (firstName.isBlank()) fieldErrors.addError("firstName", "First name is required")
  if (firstName.length > 100) fieldErrors.addError("firstName", "First name must be at most 100 characters")

  val lastName = request.lastName.trim()
  if (lastName.isBlank()) fieldErrors.addError("lastName", "Last name is required")
  if (lastName.length > 100) fieldErrors.addError("lastName", "Last name must be at most 100 characters")

  val dob = runCatching { LocalDate.parse(request.dob) }.getOrNull()
  val today = Clock.System.now().toLocalDateTime(TimeZone.UTC).date
  if (dob == null) {
    fieldErrors.addError("dob", "Date of birth must be ISO-8601 (YYYY-MM-DD)")
  } else {
    if (dob > today) {
      fieldErrors.addError("dob", "Date of birth cannot be in the future")
    }
    if (dob.year < 1900) {
      fieldErrors.addError("dob", "Date of birth year must be 1900 or later")
    }
  }

  val ssnDigits = request.ssn.filter(Char::isDigit)
  if (ssnDigits.length != 9) {
    fieldErrors.addError("ssn", "SSN must contain exactly 9 digits")
  }

  if (fieldErrors.isNotEmpty()) {
    throw validationProblem(fieldErrors)
  }

  return PqNormalizedInput(
    firstName = firstName,
    lastName = lastName,
    dob = dob!!,
    ssnDigits = ssnDigits,
    ssnLast4 = ssnDigits.takeLast(4)
  )
}

private fun MutableMap<String, MutableList<String>>.addError(field: String, message: String) {
  getOrPut(field) { mutableListOf() }.add(message)
}
