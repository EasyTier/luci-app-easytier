#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_VERSION:=2.0.3
PKG_RELEASE:=

LUCI_TITLE:=LuCI support for EasyTier
LUCI_DEPENDS:=
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-easytier

define Package/$(PKG_NAME)/prerm
#!/bin/sh
if [ -f /etc/config/easytier ] ; then
  echo "Резервное копирование файла конфигурации easytier/etc/config/easytier в/tmp/easytier_backup"
  echo "Установите luci-app-easytier не перезагружая устройство, конфигурация сохранится, нет необходимрсти перенастраивать"
  mv -f /etc/config/easytier /tmp/easytier_backup
fi
if [ -f /etc/easytier/config.toml ] ; then
  echo "Резервное копирование файла конфигурации easytier/etc/easytier/config.toml в/tmp/config_backup.toml"
  echo "Устоновить заново luci-app-easytier без перезагрузки не потеряв файл конфигурациии, нет необходимости перенастраивать"
  mv -f /etc/easytier/config.toml /tmp/config_backup.toml 
fi
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
chmod +x /etc/init.d/easytier
if [ -f /tmp/easytier_backup ] ; then
  echo "Найден файл конфигурации резервного копирования easytier/tmp/easytier_backup，начать востановление в/etc/config/easytier"
  mv -f /tmp/easytier_backup /etc/config/easytier
  echo "Зайдите в веб интерфейс Luci VPN - EasyTier"
fi
if [ -f /tmp/config_backup.toml ] ; then
  echo "Найден файл резервного копирования easytier/tmp/config_backup.toml，начать востановление в/etc/easytier/config.toml"
  mv -f /tmp/config_backup.toml /etc/easytier/config.toml
  echo "Зайдите в веб интерфейс Luci VPN - EasyTier"
fi
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
