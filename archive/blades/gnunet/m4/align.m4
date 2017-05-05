# align.m4
dnl Copyright (C) 2008 Christian Grothoff
dnl This file is free software, distributed under the terms of the GNU
dnl General Public License.  As a special exception to the GNU General
dnl Public License, this file may be distributed as part of a program
dnl that contains a configuration script generated by Autoconf, under
dnl the same distribution terms as the rest of that program.

# Define HAVE_UNALIGNED_64_ACCESS if reading a 64-bit value at a 32-bit aligned offset works
# Note that the program intentionally causes a SIGBUS (so you may
# see some message along those lines on the console).
AC_DEFUN([AC_UNALIGNED_64_ACCESS],
[AC_CACHE_CHECK([whether unaligned 64-bit access works],
 ac_cv_unaligned_64_access,
 [
 AC_RUN_IFELSE([AC_LANG_PROGRAM([[struct S { int a,b,c;};]],
                               [[struct S s = {0,0,0}; long long * p = (long long *) &s.b;
			         void *bp = malloc (50);
 				 long long x = *p;
				 long long *be = (long long*) &bp[1];
				 long long y = *be;
				 return (int) x*y;]])],
 ac_cv_unaligned_64_access=yes,
 ac_cv_unaligned_64_access=no,
 ac_cv_unaligned_64_access=no)
 ])
 case "$ac_cv_unaligned_64_access" in
  *yes) value=1;;
  *) value=0;;
 esac
 AC_DEFINE_UNQUOTED([HAVE_UNALIGNED_64_ACCESS], $value, [We can access-64 bit values that are only 32-bit aligned])
])
