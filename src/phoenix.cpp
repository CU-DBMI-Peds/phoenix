// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>
#include <Rcpp.h>
#include "phoenix.h"

// [[Rcpp::export]]
Rcpp::IntegerVector phoenixRespiratory(arma::vec pfRatio, arma::vec sfRatio, arma::vec imv, arma::vec respSupport) {

  arma::vec score = (
      max(
        imv % ((pfRatio < 100) + (pfRatio < 200)) + (imv || respSupport) % (pfRatio < 400)
        ,
        imv % ((sfRatio < 148) + (sfRatio < 220)) + (imv || respSupport) % (sfRatio < 292)
      )
  );

  //return Rcpp::wrap(arma::conv_to<arma::ivec>::from(rtn));

  Rcpp::IntegerVector rtn = Rcpp::IntegerVector(Rcpp::wrap(score));
  
  return (rtn);

}
