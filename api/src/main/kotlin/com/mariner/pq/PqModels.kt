package com.mariner.pq

import kotlinx.datetime.LocalDate
import kotlinx.serialization.Serializable
import java.time.OffsetDateTime
import java.util.UUID

@Serializable
data class PqRequest(
  val firstName: String,
  val lastName: String,
  val dob: String,
  val ssn: String
)

@Serializable
data class PqResponse(
  val id: String,
  val firstName: String,
  val lastName: String,
  val dob: String,
  val ssnLast4: String,
  val createdAt: String,
  val updatedAt: String
)

data class PqRecord(
  val id: UUID,
  val prospectId: String,
  val firstName: String,
  val lastName: String,
  val dob: LocalDate,
  val ssnLast4: String,
  val createdAt: OffsetDateTime,
  val updatedAt: OffsetDateTime
)

data class PqNormalizedInput(
  val firstName: String,
  val lastName: String,
  val dob: LocalDate,
  val ssnDigits: String,
  val ssnLast4: String
)

fun PqRecord.toResponse(): PqResponse =
  PqResponse(
    id = id.toString(),
    firstName = firstName,
    lastName = lastName,
    dob = dob.toString(),
    ssnLast4 = ssnLast4,
    createdAt = createdAt.toString(),
    updatedAt = updatedAt.toString()
  )
