include $(TOPDIR)/rules.mk

PKG_NAME:=easytier
PKG_VERSION:=2.3.2
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/EasyTier/EasyTier/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=bd1b3345346468555e473d0244b7672caf41c7b7d581469729f0e2b4bae826b8
PKG_SOURCE_SUBDIR:=EasyTier-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

PKG_MAINTAINER:=lazyoop <lazyoop@nas.lan>
PKG_LICENSE:=LGPL-3.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=node/host rust/host protobuf/host upx/host
PKG_BUILD_PARALLEL:=1

CARGO_PKG_VARS += PROTOC=$(STAGING_DIR_HOSTPKG)/bin/protoc
PNPM_STORE_PATH := $(PKG_BUILD_DIR)/.pnpm-store

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

ifeq ($(ARCH),mipsel)
  RUST_TARGET:=mipsel-unknown-linux-musl
else ifeq ($(ARCH),mips)
  RUST_TARGET:=mips-unknown-linux-musl
else ifeq ($(BOARD),kirkwood)
  RUST_TARGET:=arm-unknown-linux-musleabi
else ifeq ($(ARCH),arm)
  ifeq ($(CONFIG_TARGET_ARM_V7),y)
  	ifeq ($(CONFIG_ARCH_ARM_HARD_FLOAT),y)
  	  RUST_TARGET:=armv7-unknown-linux-musleabihf
  	else
      RUST_TARGET:=armv7-unknown-linux-musleabi
  	endif
  else
  	ifeq ($(CONFIG_ARCH_ARM_HARD_FLOAT),y)
  	  RUST_TARGET:=arm-unknown-linux-musleabihf
  	else
      RUST_TARGET:=arm-unknown-linux-musleabi
  	endif
  endif
else ifeq ($(ARCH),aarch64)
  RUST_TARGET:=aarch64-unknown-linux-musl
else ifeq ($(ARCH),x86_64)
  RUST_TARGET:=x86_64-unknown-linux-musl
else ifeq ($(ARCH),i386)
  RUST_TARGET:=i686-unknown-linux-musl
else
  RUST_TARGET:=dummy
endif

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=VPN
	TITLE:=A simple, decentralized mesh VPN with WireGuard support.
	DEPENDS:=@(x86_64||arm||aarch64||mipsel||mips||i386) +kmod-tun
	URL:=https://github.com/EasyTier/EasyTier
endef

define Package/$(PKG_NAME)/description
	A simple, decentralized mesh VPN with WireGuard support.
endef

define Package/$(PKG_NAME)/config
  config EASYTIER_COMPRESS_UPX
    bool "Compress $(PKG_NAME) with UPX"
    default y
endef

define Build/Prepare
	$(call Build/Prepare/Default)
ifeq ($(filter mips mipsel,$(ARCH)),)
	cd $(PKG_BUILD_DIR) && $(STAGING_DIR_HOSTPKG)/bin/npm install --no-save pnpm
	echo "store-dir=$(PNPM_STORE_PATH)" > $(PKG_BUILD_DIR)/.npmrc
	echo "frozen-lockfile=true" >> $(PKG_BUILD_DIR)/.npmrc
endif
endef

define Build/Compile
	$(call Build/Compile/Cargo,easytier,--locked)

ifeq ($(filter mips mipsel,$(ARCH)),)
	cd $(PKG_BUILD_DIR) && $(STAGING_DIR_HOSTPKG)/bin/npx pnpm --frozen-lockfile -r install
	cd $(PKG_BUILD_DIR) && $(STAGING_DIR_HOSTPKG)/bin/npx pnpm --frozen-lockfile -r --filter "./easytier-web/*" build
	$(call Build/Compile/Cargo,easytier-web,--locked --features embed)
endif
ifeq ($(CONFIG_EASYTIER_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_INSTALL_DIR)/bin/easytier-*
endif
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/easytier-core $(1)/usr/bin/easytier-core
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/easytier-cli $(1)/usr/bin/easytier-cli
	@if [ "$(ARCH)" != "mips" ] && [ "$(ARCH)" != "mipsel" ]; then \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/easytier-web $(1)/usr/bin/easytier-web; \
	fi
endef

$(eval $(call RustBinPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
