local fs = require "luci.fs"
local http = luci.http
local nixio = require "nixio"

m = Map("easytier")
m.description = translate('Простое, безопасное, децентрализованное решение VPN основанное на Rust：<a href="https://github.com/EasyTier/EasyTier">github.com/EasyTier/EasyTier</a>&nbsp;&nbsp;<a href="http://easytier.rs"> оф.сайт </a>&nbsp;&nbsp;<a href="http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=jhP2Z4UsEZ8wvfGPLrs0VwLKn_uz0Q_p&authKey=OGKSQLfg61YPCpVQuvx%2BxE7hUKBVBEVi9PljrDKbHlle6xqOXx8sOwPPTncMambK&noverify=0&group_code=949700262">QQ сообщество</a>&nbsp;&nbsp;<a href="https://doc.oee.icu">Учебник для новичков</a>')

-- easytier
m:section(SimpleSection).template  = "easytier/easytier_status"

s=m:section(TypedSection, "easytier", translate("Конфигурация EasyTier"))
s.addremove=false
s.anonymous=true
s:tab("general", translate("Общие"))
s:tab("privacy", translate("Расширенные"))
s:tab("infos", translate("Информация о соединении"))
s:tab("upload", translate("Загрузить .bin файл"))

switch = s:taboption("general",Flag, "enabled", translate("Enable"))
switch.rmempty = false

btncq = s:taboption("general", Button, "btncq", translate("Перезагрузка"))
btncq.inputtitle = translate("Перезагрузка")
btncq.description = translate("Быстрая перезагрузка без изменения параметров")
btncq.inputstyle = "apply"
btncq:depends("enabled", "1")
btncq.write = function()
  os.execute("/etc/init.d/easytier restart &")
end

etcmd = s:taboption("privacy",ListValue, "etcmd", translate("Режим запуска"),
	translate("Запуск из командной строки по умолчанию, также можно использовать запуск из файла конфигурации<br>При переключении метода запуска запуск будет происходить указанным способом, пожалуйста, выбирайте внимательно!"))
etcmd.default = "etcmd"
etcmd:value("etcmd",translate("командная строка"))
etcmd:value("config",translate("файл конфигурации"))

et_config = s:taboption("privacy",TextValue, "et_config", translate("файл конфигурации"),
	translate("Файл конфигурации находится в /etc/easytier/config.toml <br>Параметры запуска в командной строке не синхронизированы с параметрами в этом файле конфигурации, поэтому измените их самостоятельно<br>Ознакомление с файлом конфигурации:<a href='https://easytier.rs/guide/network/config-file.html '> Нажмите здесь для просмотра</a>"))
et_config.rows = 18
et_config.wrap = "off"
et_config:depends("etcmd", "config")

et_config.cfgvalue = function(self, section)
    return nixio.fs.readfile("/etc/easytier/config.toml") or ""
end
et_config.write = function(self, section, value)
    local dir = "/etc/easytier/"
    local file = dir .. "config.toml"
    -- Проверьте сушествует ли каталог /etc/easytier/config.toml, если нет, создайте.
    if not nixio.fs.access(dir) then
        nixio.fs.mkdir(dir)
    end
    fs.writefile(file, value:gsub("\r\n", "\n"))
end

network_name = s:taboption("general", Value, "network_name", translate("имя сети"),
	translate("Имя сети VPN （--network-name параметр）"))
network_name.password = true
network_name.placeholder = "test"

network_secret = s:taboption("general", Value, "network_secret", translate("сетевой ключ"),
	translate("Испльзуется для проверки надёжности этого узла VPN сетевой ключ（--network-secret параметр）"))
network_secret.password = true
network_secret.placeholder = "test"

ip_dhcp = s:taboption("general",Flag, "ip_dhcp", translate("dhcp"),
	translate("IP-адрес автоматически определяется и устанавливается Easytier, начиная с 10.0.0.1 по умолчанию. ВНИМАНИЕ: При использовании DHCP, если в сети возникнет конфликт IP-адресов, IP-адрес будет изменен автоматически. (параметр -d)"))

ipaddr = s:taboption("general",Value, "ipaddr", translate("IP интерфейса"),
	translate("IPv4-адрес этого VPN-узла, если пустой, то этот узел будет только пересылать пакеты и не будет создавать TUN-устройства (параметр -i)"))
ipaddr.datatype = "ip4addr"
ipaddr.placeholder = "10.0.0.1"

peeradd = s:taboption("general",DynamicList, "peeradd", translate("Одноранговый узел"),
	translate("Начальное соединение с пиром, то же самое, что и ниже (параметр -p) <br>Запрос статуса доступности публичного сервера：<a href='https://easytier.gd.nkbpal.cn/status/easytier' target='_blank'>узнать</a>"))
peeradd.placeholder = "tcp://public.easytier.top:11010"
peeradd:value("tcp://public.easytier.top:11010", translate("Официальный публичный сервер – Гуандун Хэюань-tcp://public.easytier.top:11010"))
peeradd:value("tcp://43.136.45.249:11010", translate("ГуанчжоуV4-tcp://43.136.45.249:11010"))
peeradd:value("tcp://et.ie12vps.xyz:11010", translate("НанкинV4/V6-tcp://et.ie12vps.xyz:11010"))
peeradd:value("tcp://minebg.top:11010", translate("ГуанчжоуV4-tcp://minebg.top:11010"))
peeradd:value("tcp://ah.nkbpal.cn:11010", translate("Аньхой ТелекомV4-tcp://ah.nkbpal.cn:11010"))
peeradd:value("udp://ah.nkbpal.cn:11010", translate("Аньхой ТелекомV4-udp://ah.nkbpal.cn:11010"))
peeradd:value("wss://ah.nkbpal.cn:11012", translate("Аньхой ТелекомV4-wss://ah.nkbpal.cn:11012"))
peeradd:value("tcp://222.186.59.80:11113", translate("Чжэньцзян, ЦзянсуV4-tcp://222.186.59.80:11113"))
peeradd:value("wss://222.186.59.80:11115", translate("Чжэньцзян, ЦзянсуV4-wss://222.186.59.80:11115"))
peeradd:value("tcp://hw.gz.9z1.me:58443", translate("ГуанчжоуV4-tcp://hw.gz.9z1.me:58443"))
peeradd:value("tcp://c.oee.icu:60006", translate("ГонконгV4/V6-tcp://c.oee.icu:60006"))
peeradd:value("udp://c.oee.icu:60006", translate("ГонконгV4/V6-udp://c.oee.icu:60006"))
peeradd:value("wss://c.oee.icu:60007", translate("ГонконгV4/V6-wss://c.oee.icu:60007"))
peeradd:value("tcp://etvm.oee.icu:31572", translate("ЯпонияV4-tcp://etvm.oee.icu:31572"))
peeradd:value("wss://etvm.oee.icu:30845", translate("ЯпонияV4-wss://etvm.oee.icu:30845"))
peeradd:value("tcp://et.pub.moe.gift:11010", translate("Колорадо, СШАV4-tcp://et.pub.moe.gift:11010"))
peeradd:value("wss://et.pub.moe.gift:11012", translate("Колорадо, СШАV4-tcp://et.pub.moe.gift:11012"))
peeradd:value("tcp://et.323888.xyz:11010", translate("Хубэй ШиянV4-tcp://et.323888.xyz:11010"))
peeradd:value("udp://et.323888.xyz:11010", translate("Хубэй ШиянV4-udp://et.323888.xyz:11010"))
peeradd:value("wss://et.323888.xyz:11012", translate("Хубэй ШиянV4-wss://et.323888.xyz:11012"))
peeradd:value("tcp://s1.ct8.pl:1101", translate("Саксония ГерманияV4-tcp://s1.ct8.pl:1101"))
peeradd:value("ws://s1.ct8.pl:11012", translate("Саксония ГерманияV4-ws://s1.ct8.pl:11012"))

external_node = s:taboption("general", Value, "external_node", translate("Общий адрес узла"),
	translate("Используйте публичный общий узел для обнаружения узла-аналога, как описано выше. （парамерт -e）"))
external_node.default = ""
external_node.placeholder = "tcp://public.easytier.top:11010"
external_node:value("tcp://public.easytier.top:11010", translate("Официальный публичный сервер – Гуандун Хэюань-tcp://public.easytier.top:11010"))

proxy_network = s:taboption("general",DynamicList, "proxy_network", translate("прокси подсети"),
	translate("Экспорт локальной сети другим участникам VPN для доступа к другим устройствам в текущей локальной сети. （параметр -n）"))

rpc_portal = s:taboption("privacy", Value, "rpc_portal", translate("RPC"),
	translate("Адрес портала RPC для управления. 0 означает случайный порт, 12345 - прослушивать порт 12345 на локальном хосте, 0.0.0.0:12345 - прослушивать порт 12345 на всех интерфейсах. Значение по умолчанию - 0. Предпочтительно использовать значение 15888. （-r параметр）"))
rpc_portal.placeholder = "0"
rpc_portal.datatype = "range(1,65535)"

listenermode = s:taboption("general",ListValue, "listenermode", translate("порт прослушивания"),
	translate("OFF: не прослушивает никакие порты, подключается только к узлам-аналогам (параметр --no-listener) <br>Используется исключительно как клиент (не как сервер), можно не прослушивать порты."))
listenermode:value("ON",translate("Влючено"))
listenermode:value("OFF",translate("Выключено"))
listenermode.default = "OFF"

listener6 = s:taboption("general",Flag, "listener6", translate("мониторить IPV6"),
	translate("По умолчанию он слушает только IPV4, а одноранговый узел может использовать для подключения только IPV4. Если этот параметр включен, он также будет слушать, например, IPV6. -l tcp://[::]:11010"))
listener6:depends("listenermode", "ON")

tcp_port = s:taboption("general",Value, "tcp_port", translate("tcp/udp порт"),
	translate("tcp/udp протокол， порт：11010. Означает что tcp/udp монитор включен на 11010 порту"))
tcp_port.datatype = "range(1,65535)"
tcp_port.default = "11010"
tcp_port:depends("listenermode", "ON")

ws_port = s:taboption("general",Value, "ws_port", translate("ws порт"),
	translate("ws протокол， порт：11010. Означает что ws монитотор включен на 11011 порту"))
ws_port.datatype = "range(1,65535)"
ws_port.default = "11011"
ws_port:depends("listenermode", "ON")

wss_port = s:taboption("general",Value, "wss_port", translate("wss порт"),
	translate("wss протокол，порт：11012. Означает что wss монитор включее на 11012 порту"))
wss_port.datatype = "range(1,65535)"
wss_port.default = "11012"
wss_port:depends("listenermode", "ON")

wg_port = s:taboption("general",Value, "wg_port", translate("wg порт"),
	translate("wireguard протокол，порт：11011. Означает что wg монитор включен на 11011 порту"))
wg_port.datatype = "range(1,65535)"
wg_port.placeholder = "11011"
wg_port:depends("listenermode", "ON")

local model = fs.readfile("/proc/device-tree/model") or ""
local hostname = fs.readfile("/proc/sys/kernel/hostname") or ""
model = model:gsub("\n", "")
hostname = hostname:gsub("\n", "")
local device_name = (model ~= "" and model) or (hostname ~= "" and hostname) or "OpenWrt"
device_name = device_name:gsub(" ", "_")
desvice_name = s:taboption("general", Value, "desvice_name", translate("имя хоста"),
    translate("Имя хоста, используемое для идентификации этого устройства. （--hostname парамер）"))
desvice_name.placeholder = device_name
desvice_name.default = device_name

instance_name = s:taboption("privacy",Value, "instance_name", translate("Имя экземпляра"),
	translate("Имя экземпляра, используемое для идентификации этого узла VPN на этой же машине （--instance-name параметр）"))
instance_name.placeholder = "default"

vpn_portal = s:taboption("privacy",Value, "vpn_portal", translate("VPN URL"),
	translate("Определите URL-адрес VPN-портала, позволяющий подключаться другим VPN-клиентам.  <br> Пример: wg://0.0.0.0:11011/10.14.14.0/24, что указывает на то, что VPN-портал представляет собой сервер WireGuard, прослушивающий vpn.example.com:11010, а VPN-клиент находится в сети по адресу 10.14.14.0/24.（--vpn-portal параметр）"))
vpn_portal.placeholder = "wg://0.0.0.0:11011/10.14.14.0/24"

mtu = s:taboption("privacy",Value, "mtu", translate("MTU"),
	translate("MTU устройства TUN, по умолчанию 1380 для незашифрованного и 1360 для зашифрованного"))
mtu.datatype = "range(1,1500)"
mtu.placeholder = "1300"

default_protocol = s:taboption("privacy",ListValue, "default_protocol", translate("Протокол по умолчанию"),
	translate("Протокол по умолчанию, используемый при подключении к узлам（--default-protocol параметр）"))
default_protocol:value("-",translate("По умолчанию"))
default_protocol:value("tcp")
default_protocol:value("udp")
default_protocol:value("ws")
default_protocol:value("wss")

tunname = s:taboption("privacy",Value, "tunname", translate("Имя TUN интерфейса"),
	translate("Настройка имени интерфейса виртуальной сетевой карты TUN（--dev-name параметр）"))
tunname.placeholder = "easytier"

disable_encryption = s:taboption("general",Flag, "disable_encryption", translate("Отключить шифрование"),
	translate("Отключите шифрование для связи с одноранговыми узлами, если шифрование отключено, то другие узлы также должны отключить шифрование （-u параметр）"))

multi_thread = s:taboption("general",Flag, "multi_thread", translate("Включить многопоточность"),
	translate("По умолчанию устанавливается однопоточный, этот режим для работы с несколькими потоками （--multi-thread параметр）"))

disable_ipv6 = s:taboption("privacy",Flag, "disable_ipv6", translate("Отключить ipv6"),
	translate("Отключает ipv6 （--disable-ipv6 параметр）"))
	
latency_first = s:taboption("general",Flag, "latency_first", translate("Включить приоритет задержки"),
	translate("Режим Latency-first, будет пытаться пересылать трафик, используя путь с наименьшей задержкой, по умолчанию - кратчайший путь （--latency-first параметр）"))
	
exit_node = s:taboption("privacy",Flag, "exit_node", translate("Включить выходной узел"),
	translate("Разрешить этому узлу стать выходным узлом （--enable-exit-node параметр）"))
	
exit_nodes = s:taboption("privacy",DynamicList, "exit_nodes", translate("Адрес выходного узла"),
	translate("Выходной узел для пересылки всего трафика, виртуальный IPv4-адрес, приоритет определяется порядком списка.（--exit-nodes параметр）"))
	
smoltcp = s:taboption("privacy",Flag, "smoltcp", translate("включить стек smoltcp"),
	translate("Включить стек smoltcp для прокси-сервера подсети（--use-smoltcp параметр）"))
smoltcp.rmempty = false

no_tun = s:taboption("privacy",Flag, "no_tun", translate(" No tun"),
	translate("Не создавая устройство TUN, вы можете использовать прокси-сервер подсети для доступа к узлу.（ --no-tun параметр）"))
no_tun.rmempty = false

manual_routes = s:taboption("privacy",DynamicList, "manual_routes", translate("Маршрутизация CIDR"),
	translate("Назначение CIDR маршрутизации вручную отключит прокси-серверы подсети и распространение маршрутов WireGuard от узлов.（--manual-routes параметр）"))
manual_routes.placeholder = "192.168.0.0/16"

relay_network = s:taboption("privacy",Flag, "relay_network", translate("Пересылать трафик из сетей из белого списка"),
	translate("Пересылать трафик только из сетей из белого списка, все сети разрешены по умолчанию."))
relay_network.rmempty = false

whitelist = s:taboption("privacy",DynamicList, "whitelist", translate("Белые списки сети"),
	translate("Переадресация трафика только из сетей, включенных в белый список. В качестве входного параметра используется строка с подстановочным знаком, например, '*' (все сети), 'def*' (сети с префиксом def)<br> Можно указать несколько сетей. Если параметр пуст, пересылка отключена.（--relay-network-whitelist параметр）"))
whitelist:depends("relay_network", "1")

socks_port = s:taboption("privacy",Value, "socks_port", translate("socks5 порт"),
	translate("Включите сервер Socks5 и разрешите клиентам Socks5 доступ к виртуальной сети. Оставьте это поле пустым, чтобы отключить его.（--socks5 параметр）"))
socks_port.datatype = "range(1,65535)"
socks_port.placeholder = "1080"

disable_p2p = s:taboption("privacy",Flag, "disable_p2p", translate("Отключить P2P"),
	translate("Отключить P2P-коммуникации и пересылать пакеты только через узел, указанный командой -p （ --disable-p2p параметр）"))
disable_p2p.rmempty = false

disable_udp = s:taboption("privacy",Flag, "disable_udp", translate("Отключить UDP"),
	translate("Отключает UPD（ --disable-udp-hole-punching параметр）"))
disable_udp.rmempty = false

relay_all = s:taboption("privacy",Flag, "relay_all", translate("Relay"),
	translate("Пересылать пакеты RPC всем узлам, даже если узел не находится в белом списке сети пересылки.  <br>Это помогает узлам в сетях за пределами белого списка устанавливать P2P-соединения."))
relay_all.rmempty = false

log = s:taboption("general",ListValue, "log", translate("log"),
	translate("Путь журнала отладки /tmp/easytier.log"))
log.default = "info"
log:value("off",translate("off-закрытие"))
log:value("warn",translate("warn-предупреждать"))
log:value("info",translate("info-информация"))
log:value("debug",translate("debug-отладка"))
log:value("trace",translate("trace-отслеживать"))

check = s:taboption("privacy",Flag, "check", translate("обнаружение включения и выключения"),
        translate("После включения функции обнаружения прохода вы можете указать IP-адрес однорангового устройства на противоположном конце, когда все указанные IP-адреса не могут быть пропингованы, программа easytier будет перезапущена."))

checkip=s:taboption("privacy",DynamicList,"checkip",translate("Проверить IP"),
        translate("Убедитесь, что IP-адрес однорангового устройства здесь указан правильно и доступен. Если он заполнен неправильно, пинг завершится неудачно, и программа будет перезапущена повторно."))
checkip.rmempty = true
checkip.datatype = "ip4addr"
checkip:depends("check", "1")

checktime = s:taboption("privacy",ListValue, "checktime", translate("Время интервала  (минуты)"),
        translate("Время интервала обнаружения, как часто указанный IP проверяется на возможность подключения."))
for s=1,60 do
checktime:value(s)
end
checktime:depends("check", "1")

local process_status = luci.sys.exec("ps | grep easytier-core| grep -v grep")

btn0 = s:taboption("infos", Button, "btn0")
btn0.inputtitle = translate("node инфо")
btn0.description = translate("Нажмите кнопку, чтобы обновить и просмотреть информацию о локальном компьютере.")
btn0.inputstyle = "apply"
btn0.write = function()
if process_status ~= "" then
   luci.sys.call("$(dirname $(uci -q get easytier.@easytier[0].easytierbin))/easytier-cli node >/tmp/easytier-cli_node")
else
    luci.sys.call("echo 'Ошибка: Программа не запущена!  Пожалуйста, запустите программу и снова нажмите «Обновить».' >/tmp/easytier-cli_node")
end
end

btn0info = s:taboption("infos", DummyValue, "btn0info")
btn0info.rawhtml = true
btn0info.cfgvalue = function(self, section)
    local content = nixio.fs.readfile("/tmp/easytier-cli_node") or ""
    return string.format("<pre>%s</pre>", luci.util.pcdata(content))
end

btn1 = s:taboption("infos", Button, "btn1")
btn1.inputtitle = translate("peer инфо")
btn1.description = translate("Нажмите кнопку, чтобы обновить и просмотреть информацию об одноранговых узлах.")
btn1.inputstyle = "apply"
btn1.write = function()
if process_status ~= "" then
   luci.sys.call("$(dirname $(uci -q get easytier.@easytier[0].easytierbin))/easytier-cli peer >/tmp/easytier-cli_peer")
else
    luci.sys.call("echo 'Ошибка: Программа не запущена!  Пожалуйста, запустите программу и снова нажмите «Обновить».' >/tmp/easytier-cli_peer")
end
end

btn1info = s:taboption("infos", DummyValue, "btn1info")
btn1info.rawhtml = true
btn1info.cfgvalue = function(self, section)
    local content = nixio.fs.readfile("/tmp/easytier-cli_peer") or ""
    return string.format("<pre>%s</pre>", luci.util.pcdata(content))
end

btn2 = s:taboption("infos", Button, "btn2")
btn2.inputtitle = translate("connector инфо")
btn2.description = translate("Нажмите кнопку Обновить, чтобы просмотреть информацию о коннекторе")
btn2.inputstyle = "apply"
btn2.write = function()
if process_status ~= "" then
   luci.sys.call("$(dirname $(uci -q get easytier.@easytier[0].easytierbin))/easytier-cli connector >/tmp/easytier-cli_connector")
else
    luci.sys.call("echo 'Ошибка: Программа не запущена!  Пожалуйста, запустите программу и снова нажмите «Обновить».' >/tmp/easytier-cli_connector")
end
end

btn2info = s:taboption("infos", DummyValue, "btn2info")
btn2info.rawhtml = true
btn2info.cfgvalue = function(self, section)
    local content = nixio.fs.readfile("/tmp/easytier-cli_connector") or ""
    return string.format("<pre>%s</pre>", luci.util.pcdata(content))
end

btn3 = s:taboption("infos", Button, "btn3")
btn3.inputtitle = translate("stun инфо")
btn3.description = translate("Информация об stun")
btn3.inputstyle = "apply"
btn3.write = function()
if process_status ~= "" then
   luci.sys.call("$(dirname $(uci -q get easytier.@easytier[0].easytierbin))/easytier-cli stun >/tmp/easytier-cli_stun")
else
    luci.sys.call("echo 'Ошибка: Программа не запущена!  Пожалуйста, запустите программу и снова нажмите «Обновить».' >/tmp/easytier-cli_stun")
end
end

btn3info = s:taboption("infos", DummyValue, "btn3info")
btn3info.rawhtml = true
btn3info.cfgvalue = function(self, section)
    local content = nixio.fs.readfile("/tmp/easytier-cli_stun") or ""
    return string.format("<pre>%s</pre>", luci.util.pcdata(content))
end


btn4 = s:taboption("infos", Button, "btn4")
btn4.inputtitle = translate("route инфо")
btn4.description = translate("Нажмите кнопку, чтобы обновить и просмотреть информацию о маршрутах.")
btn4.inputstyle = "apply"
btn4.write = function()
if process_status ~= "" then
   luci.sys.call("$(dirname $(uci -q get easytier.@easytier[0].easytierbin))/easytier-cli route >/tmp/easytier-cli_route")
else
    luci.sys.call("echo 'Ошибка: Программа не запущена!  Пожалуйста, запустите программу и снова нажмите «Обновить».' >/tmp/easytier-cli_route")
end
end

btn4info = s:taboption("infos", DummyValue, "btn4info")
btn4info.rawhtml = true
btn4info.cfgvalue = function(self, section)
    local content = nixio.fs.readfile("/tmp/easytier-cli_route") or ""
    return string.format("<pre>%s</pre>", luci.util.pcdata(content))
end

btn6 = s:taboption("infos", Button, "btn6")
btn6.inputtitle = translate("peer-center инфо")
btn6.description = translate("Нажмите кнопку, чтобы обновить и просмотреть информацию о peer-center")
btn6.inputstyle = "apply"
btn6.write = function()
if process_status ~= "" then
   luci.sys.call("$(dirname $(uci -q get easytier.@easytier[0].easytierbin))/easytier-cli peer-center >/tmp/easytier-cli_peer-center")
else
    luci.sys.call("echo 'Ошибка: Программа не запущена!  Пожалуйста, запустите программу и снова нажмите «Обновить».' >/tmp/easytier-cli_peer-center")
end
end

btn6info = s:taboption("infos", DummyValue, "btn6info")
btn6info.rawhtml = true
btn6info.cfgvalue = function(self, section)
    local content = nixio.fs.readfile("/tmp/easytier-cli_peer-center") or ""
    return string.format("<pre>%s</pre>", luci.util.pcdata(content))
end

btn7 = s:taboption("infos", Button, "btn7")
btn7.inputtitle = translate("vpn-portal инфо")
btn7.description = translate("Нажмите кнопку, чтобы обновить и просмотреть информацию о vpn-portal")
btn7.inputstyle = "apply"
btn7.write = function()
if process_status ~= "" then
   luci.sys.call("$(dirname $(uci -q get easytier.@easytier[0].easytierbin))/easytier-cli vpn-portal >/tmp/easytier-cli_vpn-portal")
else
    luci.sys.call("echo 'Ошибка: Программа не запущена!  Пожалуйста, запустите программу и снова нажмите «Обновить».' >/tmp/easytier-cli_vpn-portal")
end
end

btn7info = s:taboption("infos", DummyValue, "btn7info")
btn7info.rawhtml = true
btn7info.cfgvalue = function(self, section)
    local content = nixio.fs.readfile("/tmp/easytier-cli_vpn-portal") or ""
    return string.format("<pre>%s</pre>", luci.util.pcdata(content))
end

btn5 = s:taboption("infos", Button, "btn5")
btn5.inputtitle = translate("Собственные параметры запуска")
btn5.description = translate("Нажмите кнопку, чтобы обновить, чтобы просмотреть полные параметры запуска.")
btn5.inputstyle = "apply"
btn5.write = function()
if process_status ~= "" then
    luci.sys.call("echo $(cat /proc/$(pidof easytier-core)/cmdline | awk '{print $1}') >/tmp/easytier_cmd")
else
    luci.sys.call("echo 'Ошибка: Программа не запущена!  Пожалуйста, запустите программу и снова нажмите «Обновить».' >/tmp/easytier_cmd")
end
end

btn5cmd = s:taboption("infos", DummyValue, "btn5cmd")
btn5cmd.rawhtml = true
btn5cmd.cfgvalue = function(self, section)
    local content = nixio.fs.readfile("/tmp/easytier_cmd") or ""
    return string.format("<pre>%s</pre>", luci.util.pcdata(content))
end

btnrm = s:taboption("infos", Button, "btnrm")
btnrm.inputtitle = translate("Проверьте наличие обновлений")
btnrm.description = translate("Нажмите кнопку, чтобы начать проверку обновлений")
btnrm.inputstyle = "apply"
btnrm.write = function()
  os.execute("rm -rf /tmp/easytier*.tag /tmp/easytier*.newtag /tmp/easytier-core_*")
end


easytierbin = s:taboption("upload", Value, "easytierbin", translate("путь к easytier-core"),
	translate("Настройте путь к easytier-core，Обязательно укажите полный путь и имя. Если по указанному пути недостаточно свободного места, он будет автоматически перемещен в /tmp/easytier-core"))
easytierbin.placeholder = "/tmp/vnt-cli"

local upload = s:taboption("upload", FileUpload, "upload_file")
upload.optional = true
upload.default = ""
upload.template = "easytier/other_upload"
upload.description = translate("Вы можете напрямую загружать двоичные программы easytier-core и easytier-cli или сжатые пакеты, заканчивающиеся на .zip. При загрузке новой версии адрес загрузки старой версии: <a href='https://github.com/EasyTier/. EasyTier/релизы'  target='_blank'>github.com/EasyTier/EasyTier</a> <br>Загруженный файл будет сохранен в папке /tmp. Если путь к программе настроен, он будет автоматически перемещен по этому пути при запуске. путь<br>.")
local um = s:taboption("upload",DummyValue, "", nil)
um.template = "easytier/other_dvalue"

local dir, fd, chunk
dir = "/tmp/"
nixio.fs.mkdir(dir)
http.setfilehandler(
    function(meta, chunk, eof)
        if not fd then
            if not meta then return end

            if meta and chunk then fd = nixio.open(dir .. meta.file, "w") end

            if not fd then
                um.value = translate("Ошибка: не удалось загрузить！")
                return
            end
        end
        if chunk and fd then
            fd:write(chunk)
        end
        if eof and fd then
            fd:close()
            fd = nil
            um.value = translate("Файл был загружен в") .. ' "/tmp/' .. meta.file .. '"'

            if string.sub(meta.file, -4) == ".zip" then
                local file_path = dir .. meta.file
                os.execute("unzip -q " .. file_path .. " -d " .. dir)
                local extracted_dir = "/tmp/easytier-linux-*/"
                os.execute("mv " .. extracted_dir .. "easytier-cli /tmp/easytier-cli")
                os.execute("mv " .. extracted_dir .. "easytier-core /tmp/easytier-core")
               if nixio.fs.access("/tmp/easytier-cli") then
                    um.value = um.value .. "\n" .. translate("Программа /tmp/easytier-cli успешно загружена, и плагин вступит в силу после перезапуска.")
                end
               if nixio.fs.access("/tmp/easytier-core") then
                    um.value = um.value .. "\n" .. translate("Программа/tmp/easytier-core успешно загружена, и плагин вступит в силу после перезапуска.")
                end
               end
	    if string.sub(meta.file, -7) == ".tar.gz" then
                local file_path = dir .. meta.file
                os.execute("tar -xzf " .. file_path .. " -C " .. dir)
		local extracted_dir = "/tmp/easytier-linux-*/"
                os.execute("mv " .. extracted_dir .. "easytier-cli /tmp/easytier-cli")
                os.execute("mv " .. extracted_dir .. "easytier-core /tmp/easytier-core")
               if nixio.fs.access("/tmp/easytier-cli") then
                    um.value = um.value .. "\n" .. translate("Программа/tmp/easytier-cli успешно загружена, перезапустите")
                end
               if nixio.fs.access("/tmp/easytier-core") then
                    um.value = um.value .. "\n" .. translate("Программа/tmp/easytier-core успешно загружена, перезапустите")
                end
               end
                os.execute("chmod +x /tmp/easytier-core")
                os.execute("chmod +x /tmp/easytier-cli")                
        end
    end
)
if luci.http.formvalue("upload") then
    local f = luci.http.formvalue("ulfile")
end

return m
