ITG_MAKEUTILS_DIR ?= $(realpath ../../../ITG.MakeUtils)
include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/gitversion.mk
include $(ITG_MAKEUTILS_DIR)/chocolatey.mk
include $(ITG_MAKEUTILS_DIR)/tests.mk
include $(ITG_MAKEUTILS_DIR)/signing/sign.mk
include $(ITG_MAKEUTILS_DIR)/appveyor.mk

CHOCO_PACKAGE_NAME = signcode.install

$(eval $(call packChocoWebPackage,PACKAGE_,$(CHOCO_PACKAGE_NAME),\
  $(MajorMinorPatch),\
  $(PreReleaseLabel),\
  $(wildcard $(SOURCESDIR)/$(CHOCO_PACKAGE_NAME)/*.ignore)\
  $(SOURCESDIR)/$(CHOCO_PACKAGE_NAME)/signcodepwd.cmd \
))

FILES_FOR_SIGNING := $(wildcard tests/*.ttf)

all: package
package: $(PACKAGE_TARGETS)
	$(pushDeploymentArtifact)

$(eval $(call defineTest,install,package,\
  $(CHOCO) install $(CHOCO_PACKAGE_NAME) --force --confirm -pre --source "$$(<D)", \
  $(PACKAGE_TARGETS) \
))

$(eval $(foreach file,$(FILES_FOR_SIGNING),\
  $(call defineTest,sign_ttf,package,\
    /usr/bin/mkdir -p $(AUXDIR); \
    cp -f $(file) -t $(AUXDIR); \
    $$(call SIGN,$(AUXDIR)/$(notdir $(file))); \
    $$(call SIGNTEST,$(AUXDIR)/$(notdir $(file))),\
    $(file) $(CODE_SIGNING_CERTIFICATE_PVK) $(CODE_SIGNING_CERTIFICATE_SPC) \
  )\
))

$(eval $(call defineTest,uninstall,package,\
  $(CHOCO) uninstall $(CHOCO_PACKAGE_NAME) --confirm, \
  $(PACKAGE_TARGETS) \
))
