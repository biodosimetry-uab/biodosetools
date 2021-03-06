#' Gardner's Confidence Intervals Table
#'
#' Confidence intervals for the expectation of a Poisson variable.
#'
#' @format A data frame with 1201 rows and 3 variables:
#' \describe{
#'   \item{s_est}{Nominal value for the Poisson variable.}
#'   \item{s_low}{Lower confidence interval for the Poisson variable.}
#'   \item{s_upp}{Upper confidence interval for the Poisson variable.}
#' }
#' @source \url{https://doi.org/10.1093/biomet/46.3-4.441}
"gardner_confidence_table"

#' DNA Content Fractions of Human Chromosomes (Morton 1991)
#'
#' Normalised DNA Content of Human Chromosomes from
#' Morton, N. E. (1991). Parameters of the human genome. Proceedings of the National Academy of Sciences, 88(17), 7474–7476.
#'
#' @format A data frame with 24 rows and 3 variables:
#' \describe{
#'   \item{chromosome}{Chromosome.}
#'   \item{fraction_male}{Normalised content of megabases on male human DNA.}
#'   \item{fraction_female}{Normalised content of megabases on female human DNA.}
#' }
#' @source \url{https://doi.org/10.1073/pnas.88.17.7474}
"dna_content_fractions_morton"

#' DNA Content Fractions of Human Chromosomes (IHGSC)
#'
#' Normalised DNA Content of Human Chromosomes from
#' the International Human Genome Sequencing Consortium.
#'
#' Last accessed in July 2020.
#'
#' @format A data frame with 24 rows and 3 variables:
#' \describe{
#'   \item{chromosome}{Chromosome.}
#'   \item{fraction_male}{Normalised content of megabases on male human DNA.}
#'   \item{fraction_female}{Normalised content of megabases on female human DNA.}
#' }
#' @source \url{https://www.ncbi.nlm.nih.gov/grc/human/data}
"dna_content_fractions_ihgsc"
