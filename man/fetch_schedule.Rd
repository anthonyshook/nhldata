% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fetch-schedule.R
\name{fetch_schedule}
\alias{fetch_schedule}
\title{Function to get game IDs for a given time period}
\usage{
fetch_schedule(
  season = NULL,
  start_date = NULL,
  end_date = NULL,
  season_type = 2
)
}
\arguments{
\item{season}{Season to query (e.g., '20152016'). Passing nothing will return the current day}

\item{start_date}{A beginning date to start (format - '2019-03-04')}

\item{end_date}{A last date of the range (format - '2019-03-04')}

\item{season_type}{The season type, where 1 = preseason, 2 = regular season, 3 = playoffs, 4 = all-star (Default 2)}
}
\description{
Function to get game IDs for a given time period
}
\details{
If season, start_date, and end_date are NOT provided, the default will just be the current date
}
