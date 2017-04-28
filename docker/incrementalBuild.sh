#!/bin/bash

# incrementalBuild.sh - Script to build opendlv.miniature.
# Copyright (C) 2016 Christian Berger
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

BUILD_AS=$1
UID_AS=$2

# Adding user for building.
groupadd $BUILD_AS
useradd $BUILD_AS -g $BUILD_AS

cat <<EOF > /opt/opendlv.miniature.build/build.sh
#!/bin/bash
cd /opt/opendlv.miniature.build

echo "[opendlv.miniature Docker builder] Incremental build."

mkdir -p build.proxy && cd build.proxy
CCACHE_DIR=/opt/ccache PATH=/usr/lib/ccache:/opt/od4/bin:$PATH cmake -D CXXTEST_INCLUDE_DIR=/opt/opendlv.miniature.sources/thirdparty/cxxtest -D OPENDAVINCI_DIR=/opt/od4 -D ODVDVEHICLE_DIR=/opt/opendlv.core -D ODVDOPENDLVDATA_DIR=/opt/opendlv -D CMAKE_INSTALL_PREFIX=/opt/opendlv.miniature /opt/opendlv.miniature.sources/code/proxy-miniature

CCACHE_DIR=/opt/ccache PATH=/usr/lib/ccache:/opt/od4/bin:$PATH make -j4 && make test && make install

cd ..

mkdir -p build.sim && cd build.sim
CCACHE_DIR=/opt/ccache PATH=/usr/lib/ccache:/opt/od4/bin:$PATH cmake -D CXXTEST_INCLUDE_DIR=/opt/opendlv.miniature.sources/thirdparty/cxxtest -D OPENDAVINCI_DIR=/opt/od4 -D ODVDVEHICLE_DIR=/opt/opendlv.core -D ODVDOPENDLVDATA_DIR=/opt/opendlv -D CMAKE_INSTALL_PREFIX=/opt/opendlv.miniature /opt/opendlv.miniature.sources/code/sim-miniature

CCACHE_DIR=/opt/ccache PATH=/usr/lib/ccache:/opt/od4/bin:$PATH make -j4 && make test && make install

cd ..

mkdir -p build.logic && cd build.logic
CCACHE_DIR=/opt/ccache PATH=/usr/lib/ccache:/opt/od4/bin:$PATH cmake -D CXXTEST_INCLUDE_DIR=/opt/opendlv.miniature.sources/thirdparty/cxxtest -D OPENDAVINCI_DIR=/opt/od4 -D ODVDVEHICLE_DIR=/opt/opendlv.core -D ODVDOPENDLVDATA_DIR=/opt/opendlv -D CMAKE_INSTALL_PREFIX=/opt/opendlv.miniature /opt/opendlv.miniature.sources/code/logic-miniature

CCACHE_DIR=/opt/ccache PATH=/usr/lib/ccache:/opt/od4/bin:$PATH make -j4 && make test && make install

EOF

chmod 755 /opt/opendlv.miniature.build/build.sh
chown $UID_AS:$UID_AS /opt/opendlv.miniature.build/build.sh
chown -R $UID_AS:$UID_AS /opt

su -m `getent passwd $UID_AS|cut -f1 -d":"` -c /opt/opendlv.miniature.build/build.sh
