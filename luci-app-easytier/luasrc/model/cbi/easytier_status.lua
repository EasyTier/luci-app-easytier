local http = luci.http

m = Map("easytier", translate("EasyTier Status"))
m.description = translate("A simple, secure, decentralized VPN solution for intranet penetration, implemented in Rust using the Tokio framework. "
        .. "Project URL: <a href=\"https://github.com/EasyTier/EasyTier\" target=\"_blank\">github.com/EasyTier/EasyTier</a>&nbsp;&nbsp;"
        .. "<a href=\"http://easytier.cn\" target=\"_blank\">Official Documentation</a>&nbsp;&nbsp;"
        .. "<a href=\"http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=jhP2Z4UsEZ8wvfGPLrs0VwLKn_uz0Q_p&authKey=OGKSQLfg61YPCpVQuvx%2BxE7hUKBVBEVi9PljrDKbHlle6xqOXx8sOwPPTncMambK&noverify=0&group_code=949700262\" target=\"_blank\">QQ Group</a>&nbsp;&nbsp;")
m.pageaction = false

-- 状态卡片
m:section(SimpleSection).template = "easytier/easytier_status"

-- 连接信息卡片
m:section(SimpleSection).template = "easytier/easytier_cli"

return m
