#!/bin/sh
# This configuration file was taken originally from the mpi4py project
# <http://mpi4py.scipy.org/>, and then modified for Julia

set -e
set -x

os=`uname`
TRAVIS_ROOT="$1"
MPI_IMPL="$2"

# this is where updated Autotools will be for Linux
export PATH=$TRAVIS_ROOT/bin:$PATH

case "$os" in
    Darwin)
        echo "Mac"
        brew update
        case "$MPI_IMPL" in
            mpich)
                brew install mpich
                ;;
            openmpi)
                brew install openmpi
                ;;
            *)
                echo "Unknown MPI implementation: $MPI_IMPL"
                exit 10
                ;;
        esac
    ;;

    Linux)
        echo "Linux"
        case "$MPI_IMPL" in
            mpich)
                if [ ! -d "$TRAVIS_ROOT/mpich" ]; then
                    wget -q --no-check-certificate http://www.mpich.org/static/downloads/3.2/mpich-3.2.tar.gz
                    tar -xzf mpich-3.2.tar.gz
                    cd mpich-3.2
                    mkdir build && cd build
                    ../configure CC=$PRK_CC CXX=$PRK_CXX --prefix=$TRAVIS_ROOT/mpich --disable-fortran --disable-static
                    make -j4
                    make install
                else
                    echo "MPICH already installed"
                fi
                ;;
            openmpi)
                if [ ! -d "$TRAVIS_ROOT/mpich" ]; then
                    wget -q --no-check-certificate http://www.open-mpi.org/software/ompi/v1.10/downloads/openmpi-1.10.2rc3.tar.bz2
                    tar -xjf openmpi-1.10.2rc3.tar.bz2
                    cd openmpi-1.10.2rc3
                    mkdir build && cd build
                    ../configure CC=$PRK_CC CXX=$PRK_CXX --prefix=$TRAVIS_ROOT/open-mpi \
                                --without-verbs --without-fca --without-mxm --without-ucx \
                                --without-portals4 --without-psm --without-psm2 --without-libfabric \
                                --without-udreg --without-ugni --without-alps --without-munge \
                                --without-sge --without-loadleveler --without-tm \
                                --without-lsf --without-slurm \
                                --without-pvfs2 --without-plfs \
                                --without-cuda --disable-oshmem \
                                --disable-mpi-fortran --disable-oshmem-fortran \
                                --disable-static
                    make -j4
                    make install
                else
                    echo "Open-MPI already installed"
                fi
                ;;
            *)
                echo "Unknown MPI implementation: $MPI_IMPL"
                exit 20
                ;;
        esac
        ;;
esac
