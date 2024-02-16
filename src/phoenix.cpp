// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>
#include <Rcpp.h>
#include "phoenix.h"

// [[Rcpp::export]]
arma::vec phoenixRespiratory(arma::vec pfRatio, arma::vec sfRatio, arma::vec imv, arma::vec respSupport) {

  // assuming all the vectors are of the same lenght
  arma::vec rtn(pfRatio.n_elem);

  return (
      max(
        imv % ((pfRatio < 100) + (pfRatio < 200)) + (imv || respSupport) % (pfRatio < 400)
        ,
        imv % ((sfRatio < 148) + (sfRatio < 220)) + (imv || respSupport) % (sfRatio < 292)
      )
  );
}
