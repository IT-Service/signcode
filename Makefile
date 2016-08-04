ITG_MAKEUTILS_DIR ?= ITG.MakeUtils
include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/gitversion.mk

$(eval $(call useSubProject,signcode.install,chocolatey/signcode.install,package))
