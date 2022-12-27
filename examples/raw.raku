#!/usr/bin/env raku

# See "GNU Scientific Library" manual Chapter 34 Wavelet Transforms, Paragraph 34.4

# NOTE in order to run this program you must `zef install Math::Libgsl::Sort`

use NativeCall;
use lib 'lib';
use Math::Libgsl::Raw::Wavelet;
use Math::Libgsl::Raw::Sort :sortarray;
use Math::Libgsl::Constants;

sub MAIN(Str $filename where *.IO.f)
{
  constant \moments = 4;
  constant \N       = 256;
  constant \nc      = 20;

  my gsl_wavelet $w = mgsl_wavelet_setup(DAUBECHIES, moments);
  my gsl_wavelet_workspace $work = gsl_wavelet_workspace_alloc(N);

  # Read ECG data
  my $data      = CArray[num64].allocate(N);
  my $orig-data = CArray[num64].allocate(N);
  my $k         = 0;
  for $filename.IO.lines -> $line {
    $orig-data[$k] = $line.Num;
    $data[$k]      = $orig-data[$k];
    $k++;
  }

  # Forward transform
  gsl_wavelet_transform_forward($w, $data, 1, N, $work);

  # abs value of the components
  my $abscoeff = CArray[num64].allocate(N);
  for ^N -> $i {
    $abscoeff[$i] = abs $data[$i];
  }

  # Sorts the components
  my $p = CArray[size_t].allocate(N);
  gsl_sort_index($p, $abscoeff, 1, N);

  # Use the largest 20 components; zero all the others
  for ^(N - nc) -> $i {
    $data[$p[$i]] = 0e0;
  }

  # Inverse transform
  gsl_wavelet_transform_inverse($w, $data, 1, N, $work);

  # Output filtered data
  for ^N -> $i {
    say $data[$i];
  }

  gsl_wavelet_free($w);
  gsl_wavelet_workspace_free($work);
}
