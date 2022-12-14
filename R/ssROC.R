# -----------------------------------------------------------------------------
# SS-ROC Imputation Method
# -----------------------------------------------------------------------------
#'
#' Imputation based semi-supervised method
#' @param S_all phenotyping score S for all, including labeled and unlabeled set
#' @param Y_all outcome Y for all, including labeled and unlabeled set; containing Y NA
#' @param W_labeled optional vector of weights for labeled set
#' @param W_unlabeled optional vector of weights for unlabeled set
#' @param fpr_vals desired fpr sequence for output
#' @param bandwidth bandwidth for smoothing
#' @param ecdf_transform whether conducting cdf transformation
#' @importFrom stats ecdf
#' @export
#' @return list containing
#' \itemize{
#'   \item `roc` roc
#'   \item `auc` auc
#'   \item `bandwidth` bandwidth for smoothing
#'   \item `mhat` estimate m
#' }

ssROC <- function(S_all, Y_all,
                       W_labeled = NULL,
                       W_unlabeled = NULL,
                       fpr_vals = seq(0.01, 0.99, by = 0.01),
                       bandwidth = NULL,
                       ecdf_transform = TRUE
                       ){


  if(ecdf_transform){

    ecdf_S <- ecdf(S_all)
    S <- ecdf_S(S_all)

  }

  id_labeled <- which(!is.na(Y))

  Y_labeled <- Y[id_labeled]

  S_labeled <- S[id_labeled]
  S_unlabeled <- S[-id_labeled]

  N_unlabeled <- length(S_unlabeled)
  n_labeled <- length(Y_labeled)

  if(is.null(W_labeled)){

    W_labeled <- rep(1, n_labeled)

  }

  if(is.null(W_unlabeled)){

    W_unlabeled <- rep(1, N_unlabeled)

  }

  if(is.null(bandwidth)){
    bandwidth <- sd(S_labeled) / (n_labeled^0.45)
    }

  mhat <- NP.REG(S_labeled, Y_labeled, S_unlabeled, bandwidth, Wt = W_labeled)

  result <- interpolated_ROC(S = S_unlabeled, Y = mhat, W = W_unlabeled,
                             fpr_vals = fpr_vals)


  return(list(roc = result$roc, auc = result$auc, bandwidth = bandwidth, mhat=mhat))
}


