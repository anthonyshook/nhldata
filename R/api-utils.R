# API utilities

get_api_call <- function(apicall) {

  return(
    httr::content(httr::GET(apicall))
  )
}
