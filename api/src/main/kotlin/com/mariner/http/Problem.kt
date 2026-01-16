package com.mariner.http

import io.ktor.http.HttpStatusCode
import kotlinx.serialization.Serializable

@Serializable
data class ProblemDetail(
  val type: String = "about:blank",
  val title: String,
  val status: Int,
  val detail: String? = null,
  val fieldErrors: Map<String, List<String>>? = null
)

class ApiException(
  val httpStatus: HttpStatusCode,
  val problem: ProblemDetail
) : RuntimeException(problem.detail)

fun validationProblem(fieldErrors: Map<String, List<String>>): ApiException {
  val problem = ProblemDetail(
    type = "https://mariner/problems/validation-error",
    title = "Request validation failed",
    status = HttpStatusCode.UnprocessableEntity.value,
    detail = "One or more fields are invalid",
    fieldErrors = fieldErrors
  )
  return ApiException(HttpStatusCode.UnprocessableEntity, problem)
}

fun notFoundProblem(detail: String): ApiException {
  val problem = ProblemDetail(
    type = "https://mariner/problems/not-found",
    title = "Resource not found",
    status = HttpStatusCode.NotFound.value,
    detail = detail
  )
  return ApiException(HttpStatusCode.NotFound, problem)
}

fun conflictProblem(detail: String): ApiException {
  val problem = ProblemDetail(
    type = "https://mariner/problems/conflict",
    title = "Resource conflict",
    status = HttpStatusCode.Conflict.value,
    detail = detail
  )
  return ApiException(HttpStatusCode.Conflict, problem)
}
