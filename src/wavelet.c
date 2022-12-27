#include <gsl/gsl_wavelet.h>

/* Setup */
gsl_wavelet *mgsl_wavelet_setup(int type, size_t k)
{
  const gsl_wavelet_type *types[] = {
    gsl_wavelet_daubechies, gsl_wavelet_daubechies_centered, gsl_wavelet_haar, gsl_wavelet_haar_centered,
    gsl_wavelet_bspline, gsl_wavelet_bspline_centered
  };
  const gsl_wavelet_type *T;
  gsl_wavelet *w;
  T = types[type];
  w = gsl_wavelet_alloc(T, k);
  return w;
}
