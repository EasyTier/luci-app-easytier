# luci-app-easytier

Зависимости
opkg install kmod-tun luci-lib-fs
### Быстрая сборка пакета
```bash
Для сборки luci-app-easytier_all.ipk нажмите Fork， в своем форке actions затем run workflow，начнется компиляция .ipk, После можно скачть .ipk или luci-app-easytier.zip`

```
![actions界面](https://github.com/user-attachments/assets/7e5e843b-eb01-48f1-81ab-226a1418ca0f)
### Установка
```bash
 Раннее скачанный .ipk удобным для вас способом загрузите в удобный для вас каталог и установите.
opkg install luci-app-easytier_all.ipk

Удаление
opkg remove luci-app-easytier

Для обновления необходимо удалить старую версию, затем установить новую.
```

luci-app-easytier не содержит двоичных файлов easytier-core и easytier-cli, загрузите их самостоятельно https://github.com/EasyTier/EasyTier/releases и поместите по пути /usr/bin/
сделайте их исполняемыми
chmod +x /usr/bin/easytier-c* 

### Метод компиляции
```bash
#下载openwrt编译sdk到opt目录（不区分架构）
wget -qO /opt/sdk.tar.xz https://downloads.openwrt.org/releases/22.03.5/targets/rockchip/armv8/openwrt-sdk-22.03.5-rockchip-armv8_gcc-11.2.0_musl.Linux-x86_64.tar.xz
tar -xJf /opt/sdk.tar.xz -C /opt

cd /opt/openwrt-sdk*/package
#克隆luci-app-easytier到sdk的package目录里
git clone https://github.com/EasyTier/luci-app-easytier.git

cd /opt/openwrt-sdk*
#升级脚本创建模板
./scripts/feeds update -a
make defconfig

#开始编译
make package/luci-app-easytier/compile V=s -j1

#编译完成后在/opt/openwrt-sdk*/bin/packages/aarch64_generic/base目录里
cd /opt/openwrt-sdk*/bin/packages/aarch64_generic/base
#移动到/opt目录里
mv *.ipk /opt/luci-app-easytier_all.ipk
```
