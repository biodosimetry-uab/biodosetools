.onLoad <- function(libname, pkgname) {
  # Supress YAML warning. See https://github.com/rstudio/rstudio/issues/7545
  options("yaml.eval.expr" = TRUE)
}

#' Parse raw and TeX formulae from model formula
#'
#' @param model_formula Model formula
#'
#' @return List of raw and TeX formulae
#' @noRd
parse_model_formula <- function(model_formula = c("lin-quad", "lin", "lin-quad-no-int", "lin-no-int")) {
  # Validate parameters
  model_formula <- match.arg(model_formula)

  # Parse formula
  if (model_formula == "lin-quad") {
    fit_formula_raw <- "aberr ~ -1 + coeff_C + coeff_alpha + coeff_beta"
    fit_formula_tex <- "Y = C + \\alpha D + \\beta D^{2}"
  } else if (model_formula == "lin") {
    fit_formula_raw <- "aberr ~ -1 + coeff_C + coeff_alpha"
    fit_formula_tex <- "Y = C + \\alpha D"
  } else if (model_formula == "lin-quad-no-int") {
    fit_formula_raw <- "aberr ~ -1 + coeff_alpha + coeff_beta"
    fit_formula_tex <- "Y = \\alpha D + \\beta D^{2}"
  } else if (model_formula == "lin-no-int") {
    fit_formula_raw <- "aberr ~ -1 + coeff_alpha"
    fit_formula_tex <- "Y = \\alpha D"
  }

  formula_list <- list(
    fit_formula_raw = fit_formula_raw,
    fit_formula_tex = fit_formula_tex
  )

  return(formula_list)
}


#' Parse coefficient names from model formula
#'
#' Fix coefficient names (`coeff_C`, `coeff_alpha`, `coeff_beta`) on manual coeffiecient matrix.
#'
#' @param model_formula Model formula
#'
#' @return Vector of coefficient names
#' @noRd
names_from_model_formula <- function(model_formula = c("lin-quad", "lin", "lin-quad-no-int", "lin-no-int")) {
  # Validate parameters
  model_formula <- match.arg(model_formula)

  # Parse formula
  if (model_formula == "lin-quad") {
    names <- c("coeff_C", "coeff_alpha", "coeff_beta")
  } else if (model_formula == "lin") {
    names <- c("coeff_C", "coeff_alpha")
  } else if (model_formula == "lin-quad-no-int") {
    names <- c("coeff_alpha", "coeff_beta")
  } else if (model_formula == "lin-no-int") {
    names <- c("coeff_alpha")
  }

  return(names)
}

#' Fix coefficient matrix names
#'
#' Fix coefficient names (`coeff_C`, `coeff_alpha`, `coeff_beta`) to display properly on reports.
#'
#' @param data Data frame or matrix.
#' @param type Type of name replacement. Either "rows" or "cols".
#' @param output Type of output in which the data is rendered. Either "kable" or "rhot".
#'
#' @return Data with fixed rownames and colnames.
#' @noRd
fix_coeff_names <- function(data, type = c("rows", "cols"), output = c("kable", "rhot")) {
  # Validate parameters
  type <- match.arg(type)
  output <- match.arg(output)

  # Select name functions
  if (type == "rows") {
    names_assign <- base::`rownames<-`
    names_read <- base::rownames
  } else if (type == "cols") {
    names_assign <- base::`colnames<-`
    names_read <- base::colnames
  }

  # Select coefficient replacements
  coeffs_old <- c("coeff_C", "coeff_alpha", "coeff_beta")

  if (output == "rhot") {
    coeffs_new <- c("C", "\u03B1", "\u03B2")
  } else if (output == "kable") {
    coeffs_new <- c("$C$", "$\\\\alpha$", "$\\\\beta$")
  }

  # Replace coefficients
  data <- data %>%
    names_assign(
      names_read(.) %>%
        gsub(coeffs_old[[1]], coeffs_new[[1]], .) %>%
        gsub(coeffs_old[[2]], coeffs_new[[2]], .) %>%
        gsub(coeffs_old[[3]], coeffs_new[[3]], .)
    )
  return(data)
}

#' Fix data frame variable names
#'
#' Fix data colnames to display properly on reports.
#'
#' @param data Data frame or matrix.
#' @param type Type of input data. Either "count" and "case".
#' @param output Type of output in which the data is rendered. Only "kable" supported at the moment.
#'
#' @return Data with fixed colnames.
#' @noRd
fix_count_data_names <- function(data, type = c("count", "case"), output = "kable") {
  # Validate parameters
  type <- match.arg(type)
  output <- match.arg(output)

  # Parse headers
  col_names <- colnames(data)

  counts_headers <- grep("C[0-9]+", x = col_names, value = TRUE)
  counts_headers <- paste0("$C_{", regmatches(counts_headers, regexpr("[0-9]+", counts_headers)), "}$")

  if (type == "count") {
    other_headers <- grep("C[0-9]+", x = col_names, value = TRUE, invert = TRUE) %>%
      gsub("^D$", "$D$ (Gy)", .) %>%
      gsub("^N$", "$N$", .) %>%
      gsub("^X$", "$X$", .) %>%
      gsub("^mean$", "$\\\\bar{y}$", .) %>%
      gsub("^var$", "$\\\\sigma^{2}$", .) %>%
      gsub("^DI$", "$\\\\sigma^{2} / \\\\bar{y}$", .) %>%
      gsub("^u$", "$u$", .)

    if (ncol(data) > 3) {
      colnames(data) <- c(other_headers[1:3], counts_headers, other_headers[4:length(other_headers)])
    } else {
      colnames(data) <- c(other_headers[1:3])
    }
  } else if (type == "case") {
    other_headers <- grep("C[0-9]+", x = col_names, value = TRUE, invert = TRUE) %>%
      gsub("^N$", "$N$", .) %>%
      gsub("^X$", "$X$", .) %>%
      gsub("^y$", "$y$", .) %>%
      gsub("^y_err$", "$\\\\sigma_{y} / \\\\sqrt{N}$", .) %>%
      gsub("^Fp$", "$F_{P}$", .) %>%
      gsub("^Fp_err$", "$\\\\sigma_{P} / \\\\sqrt{N}$", .) %>%
      gsub("^Fg$", "$F_{G}$", .) %>%
      gsub("^Xc$", "$X_{C}$", .) %>%
      gsub("^Fg_err$", "$\\\\sigma_{G} / \\\\sqrt{N}$", .) %>%
      gsub("^DI$", "$\\\\sigma^{2} / \\\\bar{y}$", .) %>%
      gsub("^u$", "$u$", .)

    colnames(data) <- c(other_headers[1:2], counts_headers, other_headers[3:length(other_headers)])
  }

  return(data)
}

#' Convert case of a string to title case
#'
#' @param string String to modify.
#'
#' @return String as title case.
#' @noRd
to_title <- function(string) {
  split_string <- strsplit(string, " ")[[1]]
  string <- paste(
    toupper(substring(split_string, 1, 1)),
    substring(split_string, 2),
    sep = "",
    collapse = " "
  )

  return(string)
}

#' Global fitting formulas
#'
#' @noRd
list_fitting_formulas <- function() {
  fitting_formulas <- list(
    "Linear quadratic" = c(
      "Y = C + \u03B1D + \u03B2D\u00B2" = "lin-quad"
      # "Y = \u03B1D + \u03B2D\u00B2" = "lin-quad-no-int"
    ),
    "Linear" = c(
      "Y = C + \u03B1D" = "lin"
      # "Y = \u03B1D" = "lin-no-int"
    )
  )

  return(fitting_formulas)
}

#' Generalised fit coefficients
#' @noRd
generalise_fit_coeffs <- function(fit_coeffs_vec) {
  general_fit_coeffs <- numeric(length = 3L) %>%
    `names<-`(c("coeff_C", "coeff_alpha", "coeff_beta"))

  for (var in names(fit_coeffs_vec)) {
    general_fit_coeffs[[var]] <- as.numeric(fit_coeffs_vec[[var]])
  }

  return(general_fit_coeffs)
}

#' Generalised variance-covariance matrix
#' @noRd
generalise_fit_var_cov_mat <- function(fit_var_cov_mat) {
  general_fit_var_cov_mat <- matrix(0, nrow = 3, ncol = 3) %>%
    `row.names<-`(c("coeff_C", "coeff_alpha", "coeff_beta")) %>%
    `colnames<-`(c("coeff_C", "coeff_alpha", "coeff_beta"))

  for (x_var in rownames(fit_var_cov_mat)) {
    for (y_var in colnames(fit_var_cov_mat)) {
      general_fit_var_cov_mat[x_var, y_var] <- as.numeric(fit_var_cov_mat[x_var, y_var])
    }
  }

  return(general_fit_var_cov_mat)
}
