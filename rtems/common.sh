#
#  Some shell functions and shared setup shared across the build scripts
#
#  Including this file assumes these are defined:
#
#  CPU        - user argument
#  my_exit()  - shell script specific exit routine
#  usage()    - shell script usage routine
#
#  Including this file sets:
#
#  target   - to the GNU tools target name
#  CPU      - to the canonical RTEMS CPU
#

#
#  Checks the status returned by executables and exits if it is non-zero.
#
check_fatal()
{
  if [ $1 -ne 0 ] ; then
    shift
    echo "ERROR: $*" >&2
    my_exit 1
  fi
  #echo
  #echo "End of $*"
  #echo -n "Press return to continue> "
  #echo
  #read line
}

print_rtems_cpus()
{
  echo
  echo "CPU is one of the following: "
  echo "  arm   avr	bfin	h8300	i386	lm32	m32c"
  echo "  m32r 	m68k	mips	moxie	nios2	or1k	powerpc"
  echo "  sh	sparc	sparc64	v850"
  echo 
  echo "Formats without a -XXX suffix are the preferred target."
  echo 
  echo "CPU-rtems4.11 is used as the GNU target."
}

# CPU must be set before we run any of this stuff
test "x${CPU}" != "x" || check_fatal $? "(common.sh) CPU not set"

# The argument to the "--target" argument of configure.
target=${CPU}-rtems

case ${CPU} in
  a29k)        ;;
  arm)         ;;
  avr)         ;;
  bfin)         ;;
  c3x)         CPU=c4x ; target=c4x-rtems ;;
  c4x)         ;;
  h8300)       ;;
  hppa1.1)     ;;
  i386)        ;;
  lm32)        ;;
  m32c)        ;;
  m32r)        ;;
  m68k)        ;;
  mips)        ;;
  moxie)       ;;
  nios2)       ;;
  or1k)        ;;
  or32)        ;;
  powerpc)     ;;
  sh)          ;;
  tic4x)       ;;
  sparc)       ;;
  sparc64)     ;;
  v850)        ;;
  native)      CPU=unix;;
  unix)        ;;
  *)  
     echo ${CPU} is not a supported CPU
     echo
     usage
     exit 1
     ;;
esac
 
# insert the os version
target=`echo $target | sed -e 's/-rtems$/-rtems4.11/' -e 's/-rtemself$/-rtemself4.11/'`

#
#  Figure out if GNU make is available
#
gmake_found=no
for name in gmake make
do
  if [ ${gmake_found} = "no" ] ; then
    ${name} --version >/dev/null 2>&1
    if [ $? -eq 0 ] ; then
      MAKE=${name}
      gmake_found=yes 
    fi
  fi

done

if [ ${gmake_found} = "no" ] ; then
   echo "Unable to locate a version of GNU make in your PATH"
   echo "GNU Make is required to build these tools."
   exit 1
fi
