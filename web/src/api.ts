export type ProblemDetail = {
  type?: string;
  title: string;
  status: number;
  detail?: string;
  fieldErrors?: Record<string, string[]>;
};

export type PqRequest = {
  firstName: string;
  lastName: string;
  dob: string;
  ssn: string;
};

export type PqResponse = {
  id: string;
  firstName: string;
  lastName: string;
  dob: string;
  ssnLast4: string;
  createdAt: string;
  updatedAt: string;
};

const buildUrl = (path: string) => path;

const parseProblem = async (response: Response): Promise<ProblemDetail> => {
  try {
    return await response.json();
  } catch {
    return {
      title: response.statusText,
      status: response.status
    };
  }
};

const handleResponse = async <T>(response: Response): Promise<T> => {
  if (response.ok) {
    if (response.status === 204) {
      return undefined as T;
    }
    return (await response.json()) as T;
  }

  if (response.status === 404) {
    throw new Error("not-found");
  }

  throw await parseProblem(response);
};

export const fetchPq = async (): Promise<PqResponse | null> => {
  const response = await fetch(buildUrl("/api/pq"));

  if (response.status === 404) {
    return null;
  }

  return handleResponse<PqResponse>(response);
};

export const createPq = async (payload: PqRequest): Promise<PqResponse> => {
  const response = await fetch(buildUrl("/api/pq"), {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  });
  return handleResponse<PqResponse>(response);
};

export const updatePq = async (payload: PqRequest): Promise<PqResponse> => {
  const response = await fetch(buildUrl("/api/pq"), {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  });
  return handleResponse<PqResponse>(response);
};

export const deletePq = async (): Promise<void> => {
  const response = await fetch(buildUrl("/api/pq"), {
    method: "DELETE"
  });
  await handleResponse<void>(response);
};

export const isProblemDetail = (error: unknown): error is ProblemDetail => {
  return typeof error === "object" && error !== null && "status" in (error as Record<string, unknown>);
};
