use v6;

unit module Math::Libgsl::Raw::Wavelet:ver<0.0.2>:auth<zef:FRITH>;

use NativeCall;
use Math::Libgsl::Raw::Matrix;

constant GSLHELPER  = %?RESOURCES<libraries/gslhelper>.absolute;

sub LIB {
  run('/sbin/ldconfig', '-p', :chomp, :out)
    .out
    .slurp(:close)
    .split("\n")
    .grep(/^ \s+ libgsl\.so\. \d+ /)
    .sort
    .head
    .comb(/\S+/)
    .head;
}

class gsl_wavelet_type is repr('CStruct') is export {
  has Str       $.name;
  has Pointer   $.init;
}

class gsl_wavelet is repr('CStruct') is export {
  has gsl_wavelet_type  $.type;
  has CArray[num64]     $.h1;
  has CArray[num64]     $.g1;
  has CArray[num64]     $.h2;
  has CArray[num64]     $.g2;
  has size_t            $nc;
  has size_t            $offset;
}

class gsl_wavelet_workspace is repr('CStruct') is export {
  has CArray[num64]   $.scratch;
  has size_t          $.n;
}

# Setup
sub mgsl_wavelet_setup(int32 $type, size_t $k --> gsl_wavelet) is native(GSLHELPER) is export { * }
sub gsl_wavelet_free(gsl_wavelet $w) is native(LIB) is export { * }
sub gsl_wavelet_name(gsl_wavelet $w --> Str) is native(LIB) is export { * }
sub gsl_wavelet_workspace_alloc(size_t $n --> gsl_wavelet_workspace) is native(LIB) is export { * }
sub gsl_wavelet_workspace_free(gsl_wavelet_workspace $work) is native(LIB) is export { * }

# 1D transform
sub gsl_wavelet_transform(gsl_wavelet $w, CArray[num64] $data, size_t $stride, size_t $n, int32 $direction,
                          gsl_wavelet_workspace $work --> int32) is native(LIB) is export { * }
sub gsl_wavelet_transform_forward(gsl_wavelet $w, CArray[num64] $data, size_t $stride, size_t $n,
                          gsl_wavelet_workspace $work --> int32) is native(LIB) is export { * }
sub gsl_wavelet_transform_inverse(gsl_wavelet $w, CArray[num64] $data, size_t $stride, size_t $n,
                          gsl_wavelet_workspace $work --> int32) is native(LIB) is export { * }

# 2D transform
sub gsl_wavelet2d_transform(gsl_wavelet $w, CArray[num64] $data, size_t $tda, size_t $size1, size_t $size2,
                          int32 $direction, gsl_wavelet_workspace $work --> int32) is native(LIB) is export { * }
sub gsl_wavelet2d_transform_forward(gsl_wavelet $w, CArray[num64] $data, size_t $tda, size_t $size1, size_t $size2,
                          gsl_wavelet_workspace $work --> int32) is native(LIB) is export { * }
sub gsl_wavelet2d_transform_inverse(gsl_wavelet $w, CArray[num64] $data, size_t $tda, size_t $size1, size_t $size2,
                          gsl_wavelet_workspace $work --> int32) is native(LIB) is export { * }

# 2D in-place transform on a matrix
sub gsl_wavelet2d_transform_matrix(gsl_wavelet $w, gsl_matrix $m, int32 $direction, gsl_wavelet_workspace $work
                                   --> int32) is native(LIB) is export { * }
sub gsl_wavelet2d_transform_matrix_forward(gsl_wavelet $w, gsl_matrix $m, gsl_wavelet_workspace $work --> int32)
                                   is native(LIB) is export { * }
sub gsl_wavelet2d_transform_matrix_inverse(gsl_wavelet $w, gsl_matrix $m, gsl_wavelet_workspace $work --> int32)
                                   is native(LIB) is export { * }

# Non standard 2D transform
sub gsl_wavelet2d_nstransform(gsl_wavelet $w, CArray[num64] $data, size_t $tda, size_t $size1, size_t $size2,
                          int32 $direction, gsl_wavelet_workspace $work --> int32) is native(LIB) is export { * }
sub gsl_wavelet2d_nstransform_forward(gsl_wavelet $w, CArray[num64] $data, size_t $tda, size_t $size1, size_t $size2,
                          gsl_wavelet_workspace $work --> int32) is native(LIB) is export { * }
sub gsl_wavelet2d_nstransform_inverse(gsl_wavelet $w, CArray[num64] $data, size_t $tda, size_t $size1, size_t $size2,
                          gsl_wavelet_workspace $work --> int32) is native(LIB) is export { * }

# Non standard 2D in-place transform on a matrix
sub gsl_wavelet2d_nstransform_matrix(gsl_wavelet $w, gsl_matrix $m, int32 $direction, gsl_wavelet_workspace $work
                                   --> int32) is native(LIB) is export { * }
sub gsl_wavelet2d_nstransform_matrix_forward(gsl_wavelet $w, gsl_matrix $m, gsl_wavelet_workspace $work --> int32)
                                   is native(LIB) is export { * }
sub gsl_wavelet2d_nstransform_matrix_inverse(gsl_wavelet $w, gsl_matrix $m, gsl_wavelet_workspace $work --> int32)
                                   is native(LIB) is export { * }
