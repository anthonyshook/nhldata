# API utilities

get_api_call_DEP <- function(uri) {

  return(
    httr::content(httr::GET(uri))
  )
}

# Using HTTR2
get_api_call <- function(uri) {
  headers <- list('Accept' = '*/*',
                  'Content-Type'='application/json',
                  'User-Agent'='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36')
  # Run the code to return the json
  req <- httr2::request(uri)
  res <- req |>
    httr2::req_headers(!!!headers) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  return(res)
}
