ITG_MAKEUTILS_DIR ?= $(realpath ../../../ITG.MakeUtils)
include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/gitversion.mk
include $(ITG_MAKEUTILS_DIR)/chocolatey.mk
include $(ITG_MAKEUTILS_DIR)/tests.mk
include $(ITG_MAKEUTILS_DIR)/appveyor.mk

CHOCO_PACKAGE_NAME = signcode.install

$(eval $(call packChocoWebPackage,PACKAGE_,$(CHOCO_PACKAGE_NAME),\
  $(MajorMinorPatch),\
  $(PreReleaseLabel),\
  $(wildcard $(SOURCESDIR)/$(CHOCO_PACKAGE_NAME)/*.ignore)\
))

all: package
package: $(PACKAGE_TARGETS)
	$(pushDeploymentArtifact)

$(eval $(call defineTest,install,package,\
  $(CHOCO) install $(CHOCO_PACKAGE_NAME) --force --confirm -pre --source "$$(<D)", \
  $(PACKAGE_TARGETS) \
))

$(eval $(call defineTest,uninstall,package,\
  $(CHOCO) uninstall $(CHOCO_PACKAGE_NAME) --confirm, \
  $(PACKAGE_TARGETS) \
))
