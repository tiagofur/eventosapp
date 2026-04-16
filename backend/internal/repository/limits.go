package repository

// GetAllSafetyLimit caps every unpaginated GetAll query at this many rows.
// Callers that need more must use GetAllPaginated. Without this cap, a user
// with tens of thousands of rows could exhaust memory or timeout the request
// when the handler falls back to GetAll because the `page` query param is
// missing. 1000 is generous for realistic Solennix workloads while still
// being a meaningful ceiling.
const GetAllSafetyLimit = 1000
