include $(TOPDIR)/rules.mk
-include $(dir $(lastword $(MAKEFILE_LIST)))../version.mk

PKG_NAME:=easytier-noweb
PKG_VERSION:=$(or $(EASYTIER_VERSION),2.6.4)

ifeq ($(ARCH),mipsel)
	APP_ARCH:=mipsel
	APP_HASH:=7c93bcc9e9276f102b5299b0773941db7fd1d99ad04bac42b479a0d979ef5220
endif
ifeq ($(ARCH),mips)
	APP_ARCH:=mips
	APP_HASH:=3b4d084aa922a4b23f5d0167b9bb4966c1593f5184061f7ff075132a2207a260
endif
ifeq ($(ARCH),arm)
	APP_ARCH:=arm
	APP_HASH:=6d2bd44507d7183a4fa9857ced8f89cb4eddc99cdfc8f8ddef5cc78f52caf2fd
endif
ifeq ($(BOARD),kirkwood)
	APP_ARCH:=arm
	APP_HASH:=6d2bd44507d7183a4fa9857ced8f89cb4eddc99cdfc8f8ddef5cc78f52caf2fd
endif
ifeq ($(ARCH),armv7)
	APP_ARCH:=armv7
	APP_HASH:=93b1d2831e45db1fd3ca1d8d68c191b300bd69d331ca1858394a0cf884363cc3
endif
ifeq ($(ARCH),aarch64)
	APP_ARCH:=aarch64
	APP_HASH:=f533ec25a7ea714e09f645615012200278058525795cc3bb690ff011aec1a70f
endif
ifeq ($(ARCH),arm64)
	APP_ARCH:=aarch64
	APP_HASH:=f533ec25a7ea714e09f645615012200278058525795cc3bb690ff011aec1a70f
endif
ifeq ($(ARCH),armv8)
	APP_ARCH:=aarch64
	APP_HASH:=f533ec25a7ea714e09f645615012200278058525795cc3bb690ff011aec1a70f
endif
ifeq ($(ARCH),x86_64)
	APP_ARCH:=x86_64
	APP_HASH:=61b659eaedba658fa66fe47d17e1426cdd77e5d02fa15fed447bb4357c09dfd6
endif

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

EASYTIER_ARCHIVE:=easytier-linux-$(APP_ARCH)-v$(PKG_VERSION).zip

define Download/easytier
  FILE:=$(EASYTIER_ARCHIVE)
  URL:=https://github.com/EasyTier/EasyTier/releases/download/v$(PKG_VERSION)
  HASH:=$(APP_HASH)
endef

$(eval $(call Download,easytier))

RSTRIP:=:

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=A simple, decentralized mesh VPN with WireGuard support.
	DEPENDS:=@(x86_64||arm||aarch64||mipsel||mips) +kmod-tun
	URL:=https://github.com/EasyTier/EasyTier
	MENU:=1
endef

define Package/$(PKG_NAME)/description
  A simple, decentralized mesh VPN with WireGuard support.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	unzip -o -j $(DL_DIR)/$(EASYTIER_ARCHIVE) -d $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/easytier-core $(1)/usr/bin/
	chmod 0755 $(1)/usr/bin/easytier-core
	$(CP) $(PKG_BUILD_DIR)/easytier-cli $(1)/usr/bin/
	chmod 0755 $(1)/usr/bin/easytier-cli
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
