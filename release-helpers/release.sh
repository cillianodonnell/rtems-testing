#! /bin/sh
#
# This script is used to do the mechanics of making an RTEMS release
# from git and associated artifacts:
#  + bootstrapped RTEMS tarball
#  + tarball of user documentation
#  + tarball of generated Doxygen documentation
#  + (TODO) ChangeLog
#
# It is assumed that the user:
#  (a) does all work on a git branch
#  (b) created that branch by hand
#  (c) will push the branch by hand if all went OK
#  (d) publish the artifacts to the ftp site
#
# The script tries to do as much error checking as possible before
# any commits or tags are added to the repository.
#
# TODO:
#   + Can this be used on all repositories? If so, then it needs to guess or
#     be told the repository.
#   + Any other error checking?
#   + Test host environment for more missing programs
#     - Can't build tests without pax installed
#   + Review against cut_release (old, cvs, etc.) and remove cut_release
#     when it is deemed useless for even ideas.

# git log --no-merges -t --stat 7fb7cb439f72b7edaca36f70e8604c52bed49078^C | unexpand -a | sed -e 's/\s\s*$$//' > ChangeLog

check_error()
{
  error=$1
  if [ $error -eq 0 ] ; then
    return
  fi
  shift
  usage
  echo
  echo "ERROR: $* " >&2
  exit $error
}

fatal()
{
  check_error 1 $*
}

usage()
{
cat <<EOF
     -D          - make dot release   (default=no)
     -B          - bump major release (default=no)
     -M MAJOR    - RTEMS Major number (default=not specified)
     -V VERSION  - RTEMS Version      (default=not specified)
     -v          - verbose            (default=no)

Major:   Example 4.11, 4.12
Version: 4.11.0, 4.11.1, 4.11.99.0

An action of making a dot release or bumping the major must be specified.
EOF
}

toggle()
{
  if [ $1 = "no" ] ; then
    echo "yes"
    return
  fi
  echo "no"
}

vecho()
{
  if [ ${verbose} = "yes" ] ; then
    echo $*
  fi
}

#  Set up variables which control the scripts behavior
verbose=yes
VERSION=NOT_SET
MAJOR=NOT_SET
bump_dot_release=no
bump_major_version=no

while getopts BDgM:V:v OPT
do
  case "$OPT" in
    D) bump_dot_release=`toggle ${bump_dot_release}` ;;
    B) bump_major_version=`toggle ${bump_major_version}` ;;
    M) MAJOR="${OPTARG}" ;;
    V) VERSION="${OPTARG}" ;;
    v) verbose=`toggle ${verbose}` ;;
    *) usage ; exit 1 ;;
  esac
done

test -r aclocal/version.m4
check_error $? "Not at the top of an RTEMS tree"

type sb-bootstrap >/dev/null 2>&1
check_error $? "sb-bootstrap is not in your PATH"

type doxygen > /dev/null 2>&1
check_error $? "doxygen is not in your PATH"

type mscgen > /dev/null 2>&1
check_error $? "mscgen is not in your PATH"

if [ ${bump_dot_release} = "no" -a ${bump_major_version} = "no" ] ; then
  fatal "Must select an action: bump major or dot release"
fi

if [  ${VERSION} = "NOT_SET" -a ${MAJOR} = "NOT_SET" ] ; then
  fatal "RTEMS Version and Major value not provided" 
fi

if [ ${VERSION} != "NOT_SET" -a ${MAJOR} = "NOT_SET" ] ; then
  fatal "RTEMS Version provided without providing Major value" 
fi

if [ ${VERSION} = "NOT_SET" -a ${MAJOR} != "NOT_SET" ] ; then
  fatal "Major version provided without providing RTEMS Version value" 
fi

# Crude checks on the VERSION number
if [ ${VERSION} != "NOT_SET" ] ; then
  case ${VERSION} in
    4.1[0-9].[0-9]) ;;  # TBD: This could be a better match
    5.[0-9].[0-9])  ;;  # TBD: This could be a better match
    *) fatal "${VERSION} does not match 4.x.y or 5.x.y"
  esac
fi

# Crude checks on the MAJOR number
if [ ${MAJOR} != "NOT_SET" ] ; then
  case ${MAJOR} in
    4.1[0-9]) ;;  # TBD: This could be a better match
    5.[0-9])  ;;  # TBD: This could be a better match
    *) fatal "${MAJOR} does not match 4.x or 5.x"
  esac
fi

# Must be in a git repository
test -d .git
check_error $? "You are not in a git checkout"

# Do NOT do this on the master
branch=`git branch | grep "*" | awk '{ print $2 }'`
if [ ${branch} = "master" ] ; then
  fatal "You should be on a git branch before running this script"
fi

# If making a dot release, then there are extra requirements.
if [ ${bump_dot_release} = "yes" ] ; then
  # We want to be on the release branch
  test ${branch} = ${MAJOR}
  check_error $? \
    "When making a dot release, you should be a branch named properly. " \
    "For example, when making ${MAJOR}.n, you should be on the ${MAJOR} branch."

  # VERSION should start with MAJOR
  case ${VERSION} in
    ${MAJOR}.[0-9]) ;;  # TBD: This could be a better match
    *) fatal "${VERSION} does not start with ${MAJOR}" ;;
  esac

  # We need to have access to various texi tools to build documentation
  # For CentOS, the RPMs are texinfo-tex and texi2html
  type texi2dvi >/dev/null 2>&1
  check_error $? "texi2dvi is not in your PATH"
  type texi2pdf >/dev/null 2>&1
  check_error $? "texi2pdf is not in your PATH"
  # main tool varies based on texinfo version
  type texi2any >/dev/null 2>&1
  ta=$?
  type texi2html >/dev/null 2>&1
  if [ $? -ne 0 -a ${ta} -ne 0 ] ; then
    fatal "Neither texi2any nor tex2html is available"
  fi

  # We need to have access to SPARC tools to build Doxygen.
  type sparc-rtems${MAJOR}-gcc >/dev/null 2>&1
  check_error $? "sparc-rtems${MAJOR}-gcc is not in your PATH"
fi

##### END OF ERROR CHECKING

ACLOCAL_VERSION_M4=" \
testsuites/aclocal/version.m4 \
aclocal/version.m4 \
cpukit/aclocal/version.m4 \
c/src/aclocal/version.m4"

update_aclocal_version_for_version()
{
  RV=${VERSION}
  for f in ${ACLOCAL_VERSION_M4}
  do
    sed -i -e "s|\[_RTEMS_VERSION\],\[.*\]|\[_RTEMS_VERSION\],\[${RV}\]|" ${f}
  done
  sed -i -e "s,\(^RTEMS Version\).*,\1 ${RV}," VERSION
  git add ${ACLOCAL_VERSION_M4} VERSION
  git commit -m "all version.m4, VERSION: Update to ${RV}"
}

update_doc_versions()
{
  date1=`date "+%d %B %Y"`
  date2=`date "+%B %Y"`
  find -name version.texi | while read f
  do
    (echo "@set UPDATED ${date1}" ; 
     echo "@set UPDATED-MONTH ${date2}" ; 
     echo "@set EDITION ${MAJOR}" ; 
     echo "@set VERSION ${VERSION}" ) \
    >${f}
  done
  git add `find doc -name version.texi`
  git commit -m "doc/*/version.texi: Update to ${RV} and current date"
}

build_doxygen()
{
  set -x
  cpu=sparc
  bsp=leon3
  outdir=${1}
  
  rm -rf b-doxy
  mkdir b-doxy
  cd b-doxy
  ../rtems-${VERSION}/configure \
    --target=${cpu}-rtems4.11 --enable-rtemsbsp=${bsp} \
    --enable-smp --enable-multiprocessing \
    --disable-networking --disable-tests >c.log 2>&1
  make -j3 preinstall >b.log 2>&1
  cd ${cpu}-rtems4.11/c/${bsp}/cpukit

  #mv Doxyfile Doxyfile.tmp
  sed -e "s,^OUTPUT_DIRECTORY.*=.*$,OUTPUT_DIRECTORY = ${outdir}-tmp," \
      -e "s,^STRIP_FROM_PATH.*=.*$,STRIP_FROM_PATH = ," \
      -e "s,^INPUT.*=.*lib.*$,INPUT = ," \
    <Doxyfile >../../../${bsp}/lib/include/Doxyfile
  
  cd ../../../${bsp}/lib/include

  doxygen >doxy.log 2>&1
  check_error $? "Doxygen Build Failed"

  rm -rf ${outdir}
  mv ${outdir}-tmp ${outdir}
}

# Step 1: Update the various version files
vecho "Updating aclocal version.m4 and VERSION files"
update_aclocal_version_for_version

# Step 2: Update the documentation
vecho "Updating version and dates in documentation"
update_doc_versions

# No further actions needed if bumping major version
if [ ${bump_major_version} = "yes" ] ; then
  echo "*** Major version bumped on this branch"
  echo "*** Merge this branch into the master."
  exit 0
fi

### Set a BASE directory variable
BASE=`pwd`

### Tag the source
git tag ${VERSION}
check_error $? "Unable to git tag"

### Now generate the RTEMS tarball generation
vecho "Generating the RTEMS tarball"
rm -rf rtems-${VERSION} \
       rtems-${VERSION}-not_bootstrapped.tar \
       rtems-${VERSION}.tar.bz2
git archive --format=tar --prefix=rtems-${VERSION}/ ${VERSION} \
   >rtems-${VERSION}-not_bootstrapped.tar
check_error $? "Unable to perform git archive"

tar xf rtems-${VERSION}-not_bootstrapped.tar
cd rtems-${VERSION}/
check_error $? "Unable to cd to untarred RTEMS source"

# bootstrap and then remove unnecessary files
sb-bootstrap >/dev/null 2>&1
check_error $? "Unable to bootstrap the RTEMS source code"

find .  -name "stamp.*" \
     -o -name "autom4te.cache" \
     -o -name "rsb-log-*.txt" \
     | xargs -e rm -rf
cd ..
tar cjf rtems-${VERSION}.tar.bz2 rtems-${VERSION}
check_error $? "Unable to create bootstrapped tar.bz2 for release"

rm -f rtems-${VERSION}-not_bootstrapped.tar

### Now generate the documentation
vecho "Generating the RTEMS documentation tarball"
rm -rf b-doc rtemsdocs-${VERSION} rtemsdocs-${VERSION}.tar.bz2
mkdir b-doc
cd b-doc
../rtems-${VERSION}/doc/configure --enable-maintainer-mode \
  --prefix=/opt/rtems-${VERSION} >c.log 2>&1
check_error $? "Unable to configure RTEMS documentation"

make >b.log 2>&1
check_error $? "Unable to build RTEMS documentation"

make prefix=${BASE}/rtemsdocs-${VERSION} install >i.log 2>&1
check_error $? "Unable to install RTEMS documentation"

cd ..
test -d rtemsdocs-${VERSION}
check_error $? "Documentation was not installed into temporary location"

tar cjf rtemsdocs-${VERSION}.tar.bz2 rtemsdocs-${VERSION}
check_error $? "Unable to create RTEMS Documentation tar.bz2 for release"

rm -rf b-docs

### Now generate Doxygen
doxyDir=rtems-doxygen-${VERSION}
doxyOut=${BASE}/${doxyDir}
rm -rf ${doxyOut}
build_doxygen ${doxyOut}

cd ${BASE}
tar cjf ${doxyDir}.tar.bz2 ${doxyDir}
check_error $? "Unable to create RTEMS Doxygen tar.bz2 for release"



exit 0
