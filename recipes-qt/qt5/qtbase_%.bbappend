OVERRIDES =. "${@bb.utils.contains('MACHINE_FEATURES', 'mali', 'mali:', '', d)}"

FILESEXTRAPATHS_prepend_mali := "${THISDIR}/${PN}:"
SRC_URI_append_mali = "file://qeglfshooks_zynqmp.cpp"

PACKAGECONFIG_append = " examples accessibility tools libinput linuxfb alsa"
PACKAGECONFIG_GL_mali = "gles2 eglfs"

HAS_X11 = "${@bb.utils.contains('DISTRO_FEATURES', 'x11', 1, 0, d)}"

do_configure_prepend_mali() {
	if test ${HAS_X11} -eq 0; then
	# adapt qmake.conf to our needs
	sed -i 's!load(qt_config)!!' ${S}/mkspecs/linux-oe-g++/qmake.conf

	cat >> ${S}/mkspecs/linux-oe-g++/qmake.conf <<EOF
EGLFS_PLATFORM_HOOKS_SOURCES = \$\$PWD/qeglfshooks_zynqmp.cpp
EOF
	# copy the hook in the mkspecs directory OE is using
	cp ${WORKDIR}/qeglfshooks_zynqmp.cpp ${S}/mkspecs/linux-oe-g++/

	cat >> ${S}/mkspecs/linux-oe-g++/qmake.conf <<EOF

QT_MALI_INCLUDE          = \$\$[QT_SYSROOT]/usr/include
QT_MALI_LIB              = \$\$[QT_SYSROOT]/usr/lib
QMAKE_INCDIR_EGL 	+= \$\$QT_MALI_INCLUDE
QMAKE_LIBDIR_EGL 	+= \$\$QT_MALI_LIB
QMAKE_LIBS_EGL		+= -lEGL

QMAKE_INCDIR_OPENGL_ES2 += \$\$QT_MALI_INCLUDE
QMAKE_LIBDIR_OPENGL_ES2 += \$\$QT_MALI_LIB
QMAKE_LIBS_OPENGL_ES2	+= -lGLESv2

ZYNQMP_CFLAGS		 =
QMAKE_CFLAGS		+= \$\$ZYNQMP_CFLAGS
QMAKE_CXXFLAGS		+= \$\$ZYNQMP_CFLAGS

load(qt_config)

EOF
	fi
}
