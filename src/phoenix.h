// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>
#include <Rcpp.h>

#ifndef PHOENIX_H
#define PHOENIX_H

arma::vec phoenixRespiratory(arma::vec pfRatio, arma::vec sfRatio, arma::vec imv, arma::vec respSupport);


#endif
/*****************************************************************************/
/*                                End of File                                */
/*****************************************************************************/
