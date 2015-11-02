# -*- coding: utf-8; mode: tcl; c-basic-offset: 4; indent-tabs-mode: nil; tab-width: 4; truncate-lines: t -*- vim:fenc=utf-8:et:sw=4:ts=4:sts=4
# $Id: kf5-1.0.tcl 134210 2015-03-20 06:40:18Z mk@macports.org $

# Copyright (c) 2015 The MacPorts Project
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of Apple Computer, Inc. nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#
# Usage:
# PortGroup     kf5 1.0

PortGroup               cmake 1.0
# set qt5.prefer_kde      1
PortGroup               qt5-kde 1.0

########################################################################
# Projects including the 'kf5' port group can optionally set
#
#  - their project name as 'kf5.project'
#
# in that case, they should specify whether they are
#
#  - a framework by defining 'kf5.framework'
#
#  - a porting aid by defining 'kf5.portingAid'
#
#  - or a regular KF5 project which requires setting
#    + a virtual path in 'kf5.virtualPath' (e.g. "applications")
#    + as well as a release in 'kf5.release' (e.g. "15.04.2")
#
# otherwise the port will fail to build.
########################################################################

if { ![ info exists kf5.project ] } {
    ui_debug "kf5.project is not defined; falling back to \"manual\" configuration"
} else {
    name                kf5-${kf5.project}
}

platforms               darwin
supported_archs         noarch
categories              kde kf5 devel
license                 GPL-2+

# Make sure to not use any already installed headers and libraries;
# these are set in CPATH and LIBRARY_PATH anyway.
configure.ldflags-delete  -L${prefix}/lib
configure.cppflags-delete -I${prefix}/include

# setup all KF5 ports to build in a separate directory from the source:
cmake.out_of_source     yes

# NOTE: Many kf5 ports violate MacPorts' ports file systems,
#       but it is a must due to Qt5's QStandardPaths logic,
#       so we'll quieten the warning.
# destroot.violate_mtree  yes

# TODO:
#
# Phonon added as library dependency here as most, if not all KDE
# programs current need it.  The phonon port, which includes this
# PortGroup overrides depends_lib, removing "port:phonon" to prevent a
# cyclic dependency
#depends_lib-append      port:phonon

# This is used by all KF5 frameworks
depends_lib-append      path:share/ECM/cmake/ECMConfig.cmake:kde-extra-cmake-modules

# Use directory set by qt5-kde or qt5-mac
configure.args-append   -DECM_MKSPECS_INSTALL_DIR=${qt_mkspecs_dir}

# # This is why we need destroo.violate_mtree set to "yes"
# configure.args-append   -DCONFIG_INSTALL_DIR="/Library/Preferences" \
#                         -DDATA_INSTALL_DIR="/Library/Application Support"
#
# Actually this should be used instead of DATA_INSTALL_DIR, but it doesn't work:
#                       -DKDE_INSTALL_DATADIR_KF5="/Library/Application Support"

# Q: What about the often used XDG dir?
#    (Currently it gets installed into /etc/xdg just like on Linux.)

# standard configure args
configure.args-append   -DBUILD_doc=OFF \
                        -DBUILD_docs=OFF \
                        -DBUILD_SHARED_LIBS=ON \
                        -DBUNDLE_INSTALL_DIR=${applications_dir}/KF5 \
                        -DCMAKE_DISABLE_FIND_PACKAGE_X11=ON \
                        -DAPPLE_SUPPRESS_X11_WARNING=ON
#                         -DLIB_SUFFIX=64
variant docs description {build and install the documentation} {
    configure.args-delete \
                        -DBUILD_doc=OFF \
                        -DBUILD_docs=OFF
}

# explicitly define certain headers and libraries, to avoid
# conflicts with those installed into system paths by the user.
configure.args-append   -DDOCBOOKXSL_DIR=${prefix}/share/xsl/docbook-xsl \
                        -DGETTEXT_INCLUDE_DIR=${prefix}/include \
                        -DGETTEXT_LIBRARY=${prefix}/lib/libgettextlib.dylib \
                        -DGIF_INCLUDE_DIR=${prefix}/include \
                        -DGIF_LIBRARY=${prefix}/lib/libgif.dylib \
                        -DJASPER_INCLUDE_DIR=${prefix}/include \
                        -DJASPER_LIBRARY=${prefix}/lib/libjasper.dylib \
                        -DJPEG_INCLUDE_DIR=${prefix}/include \
                        -DJPEG_LIBRARY=${prefix}/lib/libjpeg.dylib \
                        -DLBER_LIBRARIES=${prefix}/lib/liblber.dylib \
                        -DLDAP_INCLUDE_DIR=${prefix}/include \
                        -DLDAP_LIBRARIES=${prefix}/lib/libldap.dylib \
                        -DLIBEXSLT_INCLUDE_DIR=${prefix}/include \
                        -DLIBEXSLT_LIBRARIES=${prefix}/lib/libexslt.dylib \
                        -DLIBICALSS_LIBRARY=${prefix}/lib/libicalss.dylib \
                        -DLIBICAL_INCLUDE_DIRS=${prefix}/include \
                        -DLIBICAL_LIBRARY=${prefix}/lib/libical.dylib \
                        -DLIBINTL_INCLUDE_DIR=${prefix}/include \
                        -DLIBINTL_LIBRARY=${prefix}/lib/libintl.dylib \
                        -DLIBXML2_INCLUDE_DIR=${prefix}/include/libxml2 \
                        -DLIBXML2_LIBRARIES=${prefix}/lib/libxml2.dylib \
                        -DLIBXML2_XMLLINT_EXECUTABLE=${prefix}/bin/xmllint \
                        -DLIBXSLT_INCLUDE_DIR=${prefix}/include \
                        -DLIBXSLT_LIBRARIES=${prefix}/lib/libxslt.dylib \
                        -DMYSQLD_EXECUTABLE=${prefix}/libexec/mysqld \
                        -DMYSQL_INCLUDE_DIR=${prefix}/include/mysql5/mysql \
                        -DMYSQL_LIB_DIR=${prefix}/lib/mysql5/mysql \
                        -DMYSQLCONFIG_EXECUTABLE=${prefix}/bin/mysql_config5 \
                        -DOPENAL_INCLUDE_DIR=/System/Library/Frameworks/OpenAL.framework/Headers \
                        -DOPENAL_LIBRARY=/System/Library/Frameworks/OpenAL.framework \
                        -DPNG_INCLUDE_DIR=${prefix}/include \
                        -DPNG_PNG_INCLUDE_DIR=${prefix}/include \
                        -DPNG_LIBRARY=${prefix}/lib/libpng.dylib \
                        -DTIFF_INCLUDE_DIR=${prefix}/include \
                        -DTIFF_LIBRARY=${prefix}/lib/libtiff.dylib

# KF5 frameworks are released with one version ATM:
set kf5_version          5.15.0
set kf5_branch           [join [lrange [split ${kf5_version} .] 0 1] .]

if { [ info exists kf5.portingAid ] } {
    set kf5.virtualPath     "frameworks"
    set kf5.folder          "frameworks/${kf5_branch}/portingAids"
}

if { [ info exists kf5.framework ] } {
    set kf5.virtualPath     "frameworks"
    set kf5.folder          "frameworks/${kf5_branch}"
}

if {[info exists kf5.project]} {
    if { ![ info exists kf5.framework ] && ![ info exists kf5.portingAid ] } {
        if { ![ info exists kf5.virtualPath ] } {
            ui_error "You haven't defined kf5.virtualPath, which is mandatory for any KF5 project using kf5.project. \
            (Or is this project perhaps a framework or porting aid?)"
            return -code error "incomplete port definition"
        } else {
            if { ![ info exists kf5.release ] } {
                ui_error "You haven't defined kf5.virtualPath, which is mandatory for any KF5 project using kf5.project."
                return -code error "incomplete port definition"
            } else {
                set kf5.folder \
                            "${kf5.virtualPath}/${kf5.release}/src"
                distname    ${kf5.project}-${kf5.release}
                version     ${kf5.release}
            }
        }
    } else {
        distname            ${kf5.project}-${kf5_version}
    }
    homepage                http://projects.kde.org/projects/${kf5.virtualPath}/${kf5.project}
    master_sites            http://download.kde.org/stable/${kf5.folder}
    use_xz                  yes
}

#ui_warn " -> kf5.virtualPath: '${kf5.virtualPath}'"
#ui_warn " -> kf5.folder: '${kf5.folder}'"
#ui_warn " -> kf5.virtualPath: '${kf5.virtualPath}'"
#ui_warn " -> distname: '${distname}'"

# maintainers             gmail.com:rjvbertin mk openmaintainer

# TODO: This is currently broken due to strange numbering scheme omitting the minor for the folder-regex.
#if { [ info exists kf5.framework ] } {
#    livecheck.type          regex
#    livecheck.url           http://download.kde.org/stable/frameworks/
#    livecheck.regex         "(5\\.\\d+)/"
#} else {
    livecheck.type          none
#}

# variables to facilitate setting up dependencies to KF5 frameworks that may (or not)
# also exist as port:kf5-foo-devel .
set kf5_attica_dep          path:lib/libKF5Attica.5.dylib:kf5-attica
set kf5_karchive_dep        path:lib/libKF5Archive.5.dylib:kf5-karchive

#########
# to install kf5-frameworkintegration:
#  kf5-attica
#  kf5-karchive
#  kf5-kauth
#  kf5-kbookmarks
#  kf5-kcodecs
#  kf5-kcompletion
#  kf5-kconfig
#  kf5-kconfigwidgets
#  kf5-kcoreaddons
#  kf5-kcrash
#  kf5-kdbusaddons
#  kf5-kdoctools
#  kf5-kglobalaccel
#  kf5-kguiaddons
#  kf5-ki18n
#  kf5-kiconthemes
#  kf5-kio
#  kf5-kitemviews
#  kf5-kjobwidgets
#  kf5-knotifications
#  kf5-kservice
#  kf5-ktextwidgets
#  kf5-kwallet
#  kf5-kwidgetsaddons
#  kf5-kwindowsystem
#  kf5-kxmlgui
#  kf5-solid
#  kf5-sonnet

