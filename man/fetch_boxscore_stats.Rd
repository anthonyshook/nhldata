% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fetch-boxscore.R
\name{fetch_boxscore_stats}
\alias{fetch_boxscore_stats}
\title{Function to fetch game boxcores}
\usage{
fetch_boxscore_stats(gameID)
}
\arguments{
\item{gameID}{A vector of gameIDs from NHL API}
}
\value{
A list containing three elements
\describe{
  \item{team_stats}{Data about team performance (goals, shots, etc).}
  \item{skater_stats}{Data about skaters.}
  \item{goalie_stats}{Data about goaltender performance.}
}
}
\description{
Function to fetch game boxcores
}
