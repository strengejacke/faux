% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sim_design.R
\name{sim_design}
\alias{sim_design}
\title{Simulate data from design}
\usage{
sim_design(
  within = list(),
  between = list(),
  n = 100,
  mu = 0,
  sd = 1,
  r = 0,
  empirical = FALSE,
  long = FALSE,
  dv = list(y = "value"),
  id = list(id = "id"),
  plot = faux_options("plot"),
  interactive = FALSE,
  design = NULL,
  rep = 1
)
}
\arguments{
\item{within}{a list of the within-subject factors}

\item{between}{a list of the between-subject factors}

\item{n}{the number of samples required}

\item{mu}{the means of the variables}

\item{sd}{the standard deviations of the variables}

\item{r}{the correlations among the variables (can be a single number, full correlation matrix as a matric or vector, or a vector of the upper right triangle of the correlation matrix}

\item{empirical}{logical. If true, mu, sd and r specify the empirical not population mean, sd and covariance}

\item{long}{Whether the returned tbl is in wide (default = FALSE) or long (TRUE) format}

\item{dv}{the name of the dv for long plots (defaults to y)}

\item{id}{the name of the id column (defaults to id)}

\item{plot}{whether to show a plot of the design}

\item{interactive}{whether to run the function interactively}

\item{design}{a design list including within, between, n, mu, sd, r, dv, id}

\item{rep}{the number of data frames to return (default 1); if greater than 1, the returned data frame is nested by rep}
}
\value{
a tbl
}
\description{
Generates a data table with a specified within and between design. See \href{../doc/sim_design.html}{\code{vignette("sim_design", package = "faux")}} for examples and details.
}
