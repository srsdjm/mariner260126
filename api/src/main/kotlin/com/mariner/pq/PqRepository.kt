package com.mariner.pq

import com.mariner.http.conflictProblem
import com.mariner.http.notFoundProblem
import com.mariner.security.EncryptionService
import kotlinx.datetime.LocalDate
import org.jetbrains.exposed.sql.ResultRow
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.deleteWhere
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.javatime.timestampWithTimeZone
import org.jetbrains.exposed.sql.kotlin.datetime.date
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.jetbrains.exposed.sql.update
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.util.UUID

class PqRepository(
  private val encryptionService: EncryptionService
) {
  fun get(prospectId: String): PqRecord? =
    transaction {
      ProspectPqTable.selectAll()
        .where { ProspectPqTable.prospectId eq prospectId }
        .limit(1)
        .firstOrNull()
        ?.toRecord()
    }

  fun create(prospectId: String, input: PqNormalizedInput): PqRecord =
    transaction {
      val existing = ProspectPqTable.selectAll()
        .where { ProspectPqTable.prospectId eq prospectId }
        .any()
      if (existing) {
        throw conflictProblem("PQ already exists for this prospect")
      }
      val now = OffsetDateTime.now(ZoneOffset.UTC)
      val id = UUID.randomUUID()
      val ciphertext = encryptionService.encrypt(input.ssnDigits)

      ProspectPqTable.insert { row ->
        row[ProspectPqTable.id] = id
        row[ProspectPqTable.prospectId] = prospectId
        row[ProspectPqTable.firstName] = input.firstName
        row[ProspectPqTable.lastName] = input.lastName
        row[ProspectPqTable.dob] = input.dob
        row[ProspectPqTable.ssnCiphertext] = ciphertext
        row[ProspectPqTable.ssnLast4] = input.ssnLast4
        row[ProspectPqTable.createdAt] = now
        row[ProspectPqTable.updatedAt] = now
      }

      PqRecord(
        id = id,
        prospectId = prospectId,
        firstName = input.firstName,
        lastName = input.lastName,
        dob = input.dob,
        ssnLast4 = input.ssnLast4,
        createdAt = now,
        updatedAt = now
      )
    }

  fun update(prospectId: String, input: PqNormalizedInput): PqRecord =
    transaction {
      val existing = ProspectPqTable.selectAll()
        .where { ProspectPqTable.prospectId eq prospectId }
        .limit(1)
        .firstOrNull()
        ?: throw notFoundProblem("No PQ found for this prospect")

      val ciphertext = encryptionService.encrypt(input.ssnDigits)
      val now = OffsetDateTime.now(ZoneOffset.UTC)

      ProspectPqTable.update({ ProspectPqTable.id eq existing[ProspectPqTable.id] }) { row ->
        row[ProspectPqTable.firstName] = input.firstName
        row[ProspectPqTable.lastName] = input.lastName
        row[ProspectPqTable.dob] = input.dob
        row[ProspectPqTable.ssnCiphertext] = ciphertext
        row[ProspectPqTable.ssnLast4] = input.ssnLast4
        row[ProspectPqTable.updatedAt] = now
      }

      existing.toRecord().copy(
        firstName = input.firstName,
        lastName = input.lastName,
        dob = input.dob,
        ssnLast4 = input.ssnLast4,
        updatedAt = now
      )
    }

  fun delete(prospectId: String) {
    val deleted = transaction {
      ProspectPqTable.deleteWhere { ProspectPqTable.prospectId eq prospectId }
    }
    if (deleted == 0) {
      throw notFoundProblem("No PQ found for this prospect")
    }
  }
}

private fun ResultRow.toRecord(): PqRecord =
  PqRecord(
    id = this[ProspectPqTable.id],
    prospectId = this[ProspectPqTable.prospectId],
    firstName = this[ProspectPqTable.firstName],
    lastName = this[ProspectPqTable.lastName],
    dob = this[ProspectPqTable.dob],
    ssnLast4 = this[ProspectPqTable.ssnLast4],
    createdAt = this[ProspectPqTable.createdAt],
    updatedAt = this[ProspectPqTable.updatedAt]
  )

object ProspectPqTable : org.jetbrains.exposed.sql.Table("prospect_pq") {
  val id = uuid("id")
  val prospectId = varchar("prospect_id", 128)
  val firstName = varchar("first_name", 100)
  val lastName = varchar("last_name", 100)
  val dob = date("dob")
  val ssnCiphertext = text("ssn_ciphertext")
  val ssnLast4 = varchar("ssn_last4", 4)
  val createdAt = timestampWithTimeZone("created_at")
  val updatedAt = timestampWithTimeZone("updated_at")

  override val primaryKey = PrimaryKey(id)
}
