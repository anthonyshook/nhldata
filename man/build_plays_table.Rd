% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/build-plays-table.R
\name{build_plays_table}
\alias{build_plays_table}
\title{Build play_by_play table}
\usage{
build_plays_table(gameIDs, conn = connect_to_db(), num_cores = 1)
}
\arguments{
\item{gameIDs}{a vector of gameIDs to process and add to the database}

\item{conn}{A connection to a database - defaults to creating a new one}

\item{num_cores}{Number of cores to use when processing.}
}
\description{
The internals here are hard-coded, as this is not meant to be
something used outside of the current process, at the moment.
In the future, perhaps something config-based could be created
This is meant to create the table brand new, not update it. If the table already
exists, it will be re-written by running this function.
}
