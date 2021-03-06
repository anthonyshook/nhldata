% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/apply-mask.R
\name{apply_mask}
\alias{apply_mask}
\title{Apply a feature mask}
\usage{
apply_mask(mask_names, dat)
}
\arguments{
\item{mask_names}{A Vector of mask names to apply}

\item{dat}{The data set to apply them to.}
}
\description{
Internal function. Applies a 'mask' to a table to ensure it has
the appropriate column values, in an effort to avoid explosions.
How this works is that it rbinds the mask and the dat, with fill = TRUE,
then removes the masked row, leaving only the original data, plus whatever columns were missing
but expected, behind and with NA
}
