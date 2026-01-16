package com.mariner.pq

import io.ktor.http.HttpStatusCode
import io.ktor.server.application.call
import io.ktor.server.request.receive
import io.ktor.server.response.respond
import io.ktor.server.routing.Route
import io.ktor.server.routing.delete
import io.ktor.server.routing.get
import io.ktor.server.routing.post
import io.ktor.server.routing.put
import io.ktor.server.routing.route

private const val STUB_PROSPECT_ID = "prospect-stub"

fun Route.pqRoutes(repository: PqRepository) {
  route("/api/pq") {
    get {
      val record = repository.get(STUB_PROSPECT_ID)
        ?: throw com.mariner.http.notFoundProblem("No PQ found for this prospect")
      call.respond(record.toResponse())
    }

    post {
      val request = call.receive<PqRequest>()
      val normalized = validatePqRequest(request)
      val created = repository.create(STUB_PROSPECT_ID, normalized)
      call.respond(HttpStatusCode.Created, created.toResponse())
    }

    put {
      val request = call.receive<PqRequest>()
      val normalized = validatePqRequest(request)
      val updated = repository.update(STUB_PROSPECT_ID, normalized)
      call.respond(updated.toResponse())
    }

    delete {
      repository.delete(STUB_PROSPECT_ID)
      call.respond(HttpStatusCode.NoContent)
    }
  }
}
