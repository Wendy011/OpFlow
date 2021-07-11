# ----------------------------------------------------------------------------
#
# Copyright (c) 2019 - 2021 by the OpFlow developers
#
# This file is part of OpFlow.
#
# OpFlow is free software and is distributed under the MPL v2.0 license.
# The full text of the license can be found in the file LICENSE at the top
# level directory of OpFlow.
#
# ----------------------------------------------------------------------------
#
# Check for the presence of AVX and figure out the flags to use for it.
#
# ----------------------------------------------------------------------------
#
# Copied from https://gist.github.com/UnaNancyOwen/263c243ae1e05a2f9d0e
#
# ----------------------------------------------------------------------------
macro(CHECK_FOR_AVX)
    set(AVX_FLAGS)

    include(CheckCXXSourceRuns)
    set(CMAKE_REQUIRED_FLAGS)

    # Check AVX
    if(MSVC AND NOT MSVC_VERSION LESS 1600)
        set(CMAKE_REQUIRED_FLAGS "/arch:AVX")
    endif()

    check_cxx_source_runs("
        #include <immintrin.h>
        int main()
        {
          __m256 a, b, c;
          const float src[8] = { 1.0f, 2.0f, 3.0f, 4.0f, 5.0f, 6.0f, 7.0f, 8.0f };
          float dst[8];
          a = _mm256_loadu_ps( src );
          b = _mm256_loadu_ps( src );
          c = _mm256_add_ps( a, b );
          _mm256_storeu_ps( dst, c );
          for( int i = 0; i < 8; i++ ){
            if( ( src[i] + src[i] ) != dst[i] ){
              return -1;
            }
          }
          return 0;
        }"
                          HAVE_AVX_EXTENSIONS)

    # Check AVX2
    if(MSVC AND NOT MSVC_VERSION LESS 1800)
        set(CMAKE_REQUIRED_FLAGS "/arch:AVX2")
    endif()

    check_cxx_source_runs("
        #include <immintrin.h>
        int main()
        {
          __m256i a, b, c;
          const int src[8] = { 1, 2, 3, 4, 5, 6, 7, 8 };
          int dst[8];
          a =  _mm256_loadu_si256( (__m256i*)src );
          b =  _mm256_loadu_si256( (__m256i*)src );
          c = _mm256_add_epi32( a, b );
          _mm256_storeu_si256( (__m256i*)dst, c );
          for( int i = 0; i < 8; i++ ){
            if( ( src[i] + src[i] ) != dst[i] ){
              return -1;
            }
          }
          return 0;
        }"
                          HAVE_AVX2_EXTENSIONS)

    # Check AVX512F
    if(MSVC AND NOT MSVC_VERSION LESS 1910)
        set(CMAKE_REQUIRED_FLAGS "/arch:AVX512")
        endif()
    check_cxx_source_runs("
        #include <immintrin.h>
        int main()
        {
          __m512d a, b, c;
          const double src[8] = { 1., 2., 3., 4., 5., 6., 7., 8. };
          double dst[8];
          a =  _mm512_loadu_pd( (__mm512d*)src );
          b =  _mm512_loadu_pd( (__mm512d*)src );
          c =  _mm512_add_pd(a, b);
          _mm512_storeu_pd( (__mm512d*)dst, c );
          for( int i = 0; i < 8; i++ ){
            if( ( src[i] + src[i] ) != dst[i] ){
              return -1;
            }
          }
          return 0;
        }"
                          HAVE_AVX512_EXTENSIONS)

    # Set Flags
    if(MSVC)
        if(HAVE_AVX512_EXTENSIONS AND NOT MSVC_VERSION LESS 1910)
            set(AVX_FLAGS "${AVX_FLAGS} /arch:AVX512")
        elseif(HAVE_AVX2_EXTENSIONS AND NOT MSVC_VERSION LESS 1800)
            set(AVX_FLAGS "${AVX_FLAGS} /arch:AVX2")
        elseif(HAVE_AVX_EXTENSIONS  AND NOT MSVC_VERSION LESS 1600)
            set(AVX_FLAGS "${AVX_FLAGS} /arch:AVX")
        endif()
    endif()
endmacro(CHECK_FOR_AVX)