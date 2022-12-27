unit class Math::Libgsl::Wavelet;

use NativeCall;
use Math::Libgsl::Matrix;
use Math::Libgsl::Constants;
use Math::Libgsl::Exception;
use Math::Libgsl::Raw::Wavelet;

sub is-powerof2(UInt:D $val where * > 0){ $val +& ($val - 1) == 0 }

has gsl_wavelet           $.w;

multi method new(UInt:D  $type!,  UInt:D  $variant!) { self.bless(:$type, :$variant) }
multi method new(UInt:D :$type!,  UInt:D :$variant!) { self.bless(:$type, :$variant) }

submethod BUILD(UInt:D :$type,  UInt:D :$variant) { $!w = mgsl_wavelet_setup($type, $variant) }

submethod DESTROY { gsl_wavelet_free($!w) }

method forward1d(@data,
                 UInt:D $stride where { $_ < @data.elems / 2 } = 1,
                 UInt:D $size where { is-powerof2($_) } = @data.elems --> List)
{
  my $work = gsl_wavelet_workspace_alloc($size);
  my CArray[num64] $data .= new: @data».Num;
  my $ret = gsl_wavelet_transform_forward($!w, $data, $stride, $size, $work);
  gsl_wavelet_workspace_free($work);
  if $ret != GSL_SUCCESS {
    fail X::Libgsl.new: errno => $ret, error => "Can't compute forward 1D transform";
  }
  return $data.list;
}

method inverse1d(@data,
                 UInt:D $stride where { $_ < @data.elems / 2 } = 1,
                 UInt:D $size where { is-powerof2($_) } = @data.elems --> List)
{
  my $work = gsl_wavelet_workspace_alloc($size);
  my CArray[num64] $data .= new: @data».Num;
  my $ret = gsl_wavelet_transform_inverse($!w, $data, $stride, $size, $work);
  gsl_wavelet_workspace_free($work);
  if $ret != GSL_SUCCESS {
    fail X::Libgsl.new: errno => $ret, error => "Can't compute inverse 1D transform";
  }
  return $data.list;
}

multi method forward2d(@data!,
                       UInt:D $dim? where { is-powerof2($dim) } = sqrt(@data.elems).UInt,
                       UInt:D $tda? where { $_ ≥ $dim } = $dim,
                       :$nonstandard --> List)
{
  my $work = gsl_wavelet_workspace_alloc($dim);
  my CArray[num64] $data .= new: @data».Num;
  my $ret;
  if $nonstandard {
    $ret = gsl_wavelet2d_nstransform_forward($!w, $data, $tda, $dim, $dim, $work);
  } else {
    $ret = gsl_wavelet2d_transform_forward($!w, $data, $tda, $dim, $dim, $work);
  }
  gsl_wavelet_workspace_free($work);
  if $ret != GSL_SUCCESS {
    fail X::Libgsl.new: errno => $ret, error => "Can't compute forward 2D transform on array";
  }
  return $data.list;
}

multi method inverse2d(@data!,
                       UInt:D $dim? where { is-powerof2($dim) } = sqrt(@data.elems).UInt,
                       UInt:D $tda? where { $_ ≥ $dim } = $dim,
                       :$nonstandard --> List)
{
  my $work = gsl_wavelet_workspace_alloc($dim);
  my CArray[num64] $data .= new: @data».Num;
  my $ret;
  if $nonstandard {
    $ret = gsl_wavelet2d_nstransform_inverse($!w, $data, $tda, $dim, $dim, $work);
  } else {
    $ret = gsl_wavelet2d_transform_inverse($!w, $data, $tda, $dim, $dim, $work);
  }
  gsl_wavelet_workspace_free($work);
  if $ret != GSL_SUCCESS {
    fail X::Libgsl.new: errno => $ret, error => "Can't compute inverse 2D transform on array";
  }
  return $data.list;
}

multi method forward2d(Math::Libgsl::Matrix $data!
                          where { $data.matrix.size1 == $data.matrix.size2 && is-powerof2($data.matrix.size1) },
                       :$nonstandard --> Math::Libgsl::Matrix)
{
  my $work = gsl_wavelet_workspace_alloc($data.matrix.size1);
  my Math::Libgsl::Matrix $idata .= new: $data.matrix.size1, $data.matrix.size1;
  $idata.copy($data);
  my $ret;
  if $nonstandard {
    $ret = gsl_wavelet2d_nstransform_matrix_forward($!w, $idata.matrix, $work);
  } else {
    $ret = gsl_wavelet2d_transform_matrix_forward($!w, $idata.matrix, $work);
  }
  gsl_wavelet_workspace_free($work);
  if $ret != GSL_SUCCESS {
    fail X::Libgsl.new: errno => $ret, error => "Can't compute forward standard form 2D transform on matrix";
  }
  return $idata;
}

multi method inverse2d(Math::Libgsl::Matrix $data!
                          where { $data.matrix.size1 == $data.matrix.size2 && is-powerof2($data.matrix.size1) },
                       :$nonstandard --> Math::Libgsl::Matrix)
{
  my $work = gsl_wavelet_workspace_alloc($data.matrix.size1);
  my Math::Libgsl::Matrix $idata .= new: $data.matrix.size1, $data.matrix.size1;
  $idata.copy($data);
  my $ret;
  if $nonstandard {
    $ret = gsl_wavelet2d_nstransform_matrix_inverse($!w, $idata.matrix, $work);
  } else {
    $ret = gsl_wavelet2d_transform_matrix_inverse($!w, $idata.matrix, $work);
  }
  gsl_wavelet_workspace_free($work);
  if $ret != GSL_SUCCESS {
    fail X::Libgsl.new: errno => $ret, error => "Can't compute inverse standard form 2D transform on matrix";
  }
  return $idata;
}

=begin pod

![Original data](examples/ecg.png) ![Filtered data](examples/ecg.processed.png)

=head1 NAME

Math::Libgsl::Wavelet - An interface to libgsl, the Gnu Scientific Library - Wavelet Transform

=head1 SYNOPSIS

=begin code :lang<raku>

use Math::Libgsl::Wavelet;
use Math::Libgsl::Constants;

constant \N    = 256;
constant \kind =   4;

my @data;
for ^N X ^N -> ($i, $j) {
  @data[$i * N + $j] = ($i * N + $j).Num / (N * N);
}

my Math::Libgsl::Wavelet $w .= new: DAUBECHIES, kind;
my @fdata = $w.forward2d(@data);

=end code

=head1 DESCRIPTION

Math::Libgsl::Wavelet is an interface to the Wavelet Transform functions of libgsl, the Gnu Scientific Library.

=head3 new(UInt:D  $type!,  UInt:D  $variant!)
=head3 new(UInt:D :$type!,  UInt:D :$variant!)

The constructor accepts two simple or named arguments: the type of wavelet function and the specific member of the wavelet
family.

The available wavelet functions are:

=item B<DAUBECHIES>
=item B<DAUBECHIES_CENTERED>
=item B<HAAR>
=item B<HAAR_CENTERED>
=item B<BSPLINE>
=item B<BSPLINE_CENTERED>

There are two methods for dealing with 1D transforms (direct and inverse):

=head3 forward1d(@data, UInt:D $stride where { $_ < @data.elems / 2 } = 1, UInt:D $size where { is-powerof2($_) } = @data.elems --> List)

Forward 1D transform.

The B<@data> array is the only mandatory argument. The array may be larger than the set of values that one wants to
transform; in that case the B<$stride> and B<$size> arguments define the set of values that will be transformed.

=head3 inverse1d(@data, UInt:D $stride where { $_ < @data.elems / 2 } = 1, UInt:D $size where { is-powerof2($_) } = @data.elems --> List)

Inverse 1D transform.

The B<@data> array is the only mandatory argument. The array may be larger than the set of values that one wants to
transform; in that case the B<$stride> and B<$size> arguments define the set of values that will be transformed.

=head3 forward2d(@data!, UInt:D $dim? where { is-powerof2($dim) } = sqrt(@data.elems).UInt, UInt:D $tda? where { $_ ≥ $dim } = $dim, :$nonstandard --> List)
=head3 forward2d(Math::Libgsl::Matrix $data!  where { $data.matrix.size1 == $data.matrix.size2 && is-powerof2($data.matrix.size1) }, :$nonstandard --> Math::Libgsl::Matrix)

Forward 2D transform.

There are two forms of this method: one accepts an array as its first argument, the other works on a
Math::Libgsl::Matrix object.

The first form takes an array B<@data> which represents a square matrix that must have a number of elements
which is a power of 2. The @data array may contain more values than those one wants to transform; in this case
the B<$size> argument is the dimension of the (square) matrix to be processed and B<$tda> is the physical row
length.

The second form accepts a square Math::Libgsl::Matrix object whose sizes are powers of 2.

Both forms allow for a named argument B<:$nonstandard>, which selects the non-standard form of the computation as
detailed in the C library documentation.

=head3 inverse2d(@data!, UInt:D $dim? where { is-powerof2($dim) } = sqrt(@data.elems).UInt, UInt:D $tda? where { $_ ≥ $dim } = $dim, :$nonstandard --> List)
=head3 inverse2d(Math::Libgsl::Matrix $data!  where { $data.matrix.size1 == $data.matrix.size2 && is-powerof2($data.matrix.size1) }, :$nonstandard --> Math::Libgsl::Matrix)

Inverse 2D transform.

There are two forms of this method: one accepts an array as its first argument, the other works on a
Math::Libgsl::Matrix object.

The first form takes an array B<@data> which represents a square matrix that must have a number of elements
which is a power of 2. The @data array may contain more values than those one wants to transform; in this case
the B<$size> argument is the dimension of the (square) matrix to be processed and B<$tda> is the physical row
length.

The second form accepts a square Math::Libgsl::Matrix object whose sizes are powers of 2.

Both forms allow for a named argument B<:$nonstandard>, which selects the non-standard form of the computation as
detailed in the C library documentation.

=head1 C Library Documentation

For more details on libgsl see L<https://www.gnu.org/software/gsl/>.
The excellent C Library manual is available here L<https://www.gnu.org/software/gsl/doc/html/index.html>, or here L<https://www.gnu.org/software/gsl/doc/latex/gsl-ref.pdf> in PDF format.

=head1 Prerequisites

This module requires the libgsl library to be installed. Please follow the instructions below based on your platform:

=head2 Debian Linux and Ubuntu 20.04+

=begin code
sudo apt install libgsl23 libgsl-dev libgslcblas0
=end code

That command will install libgslcblas0 as well, since it's used by the GSL.

=head2 Ubuntu 18.04

libgsl23 and libgslcblas0 have a missing symbol on Ubuntu 18.04.
I solved the issue installing the Debian Buster version of those three libraries:

=item L<http://http.us.debian.org/debian/pool/main/g/gsl/libgslcblas0_2.5+dfsg-6_amd64.deb>
=item L<http://http.us.debian.org/debian/pool/main/g/gsl/libgsl23_2.5+dfsg-6_amd64.deb>
=item L<http://http.us.debian.org/debian/pool/main/g/gsl/libgsl-dev_2.5+dfsg-6_amd64.deb>

=head1 Installation

To install it using zef (a module management tool):

=begin code
$ zef install Math::Libgsl::Wavelet
=end code

=head1 AUTHOR

Fernando Santagata <nando.santagata@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2022 Fernando Santagata

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
