#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk
PKG_NAME:=luci-app-b-wool
LUCI_PKGARCH:=all
PKG_VERSION:=1.4
PKG_RELEASE:=20210129

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-b-wool
 	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=Luci for JD Script 
	PKGARCH:=all
endef

define Build/Prepare
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/b-wool
endef

define Package/luci-app-b-wool/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/b-wool $(1)/etc/config/b-wool

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/etc/init.d/* $(1)/etc/init.d/

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./root/etc/uci-defaults/* $(1)/etc/uci-defaults/

	$(INSTALL_DIR) $(1)/usr/share/b-wool
	$(INSTALL_BIN) ./root/usr/share/b-wool/*.sh $(1)/usr/share/b-wool/

	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./root/usr/share/rpcd/acl.d/* $(1)/usr/share/rpcd/acl.d

	$(INSTALL_DIR) $(1)/www/b-wool
	$(INSTALL_DATA) ./root//www/b-wool/* $(1)/www/b-wool

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/* $(1)/usr/lib/lua/luci/controller/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/b-wool
	$(INSTALL_DATA) ./luasrc/model/cbi/b-wool/* $(1)/usr/lib/lua/luci/model/cbi/b-wool/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/b-wool
	$(INSTALL_DATA) ./luasrc/view/b-wool/* $(1)/usr/lib/lua/luci/view/b-wool/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./po/zh-cn/b-wool.po $(1)/usr/lib/lua/luci/i18n/b-wool.zh-cn.lmo
endef

$(eval $(call BuildPackage,luci-app-b-wool))

# call BuildPackage - OpenWrt buildroot signature
