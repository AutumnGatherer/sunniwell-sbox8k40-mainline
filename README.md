# Meson SM1 S-BOX8K40 设备树配置
> ⚠️ **WARNING / 严重警告**
> This Device Tree is strictly for the **Advanced Version (Pro)** of Sunniwell S-BOX8K40.  
> **DO NOT USE** this DTB if your device is the **Kirin Version (Standard)**, as the hardware configuration differs and flashing it may brick your device!  
> （本设备树仅适用于朝歌科技 S-BOX8K40 **高级版(Pro)**。若您的设备为 **普通版(Kirin)**，请勿使用，以免硬件不匹配导致变砖！）
**朝歌科技 Sunniwell S-BOX8K40（高配版 Pro）** — 硬件实测为 **Amlogic Meson G12A** (`Revision 28:e / 70:2`，4× Cortex-A53，原厂 DTB `g12a_u212_4g`；为兼容现有 Armbian/ophub 镜像沿用 `meson-sm1-sbox8k40` 文件名）

| 硬件 | 型号 / 状态 |
|------|------|
| SoC | Amlogic Meson G12A (`28:e / 70:2`, ARMv8 Cortex-A53) |
| 内存 | 4GB DDR4 |
| GPU | Mali-G31 MP2 (`panfrost` + `vdd_ee` 800mV) |
| WiFi / 蓝牙 | Realtek RTL8822CS (SDIO + UART) |
| 有线网 | RTL8211F 千兆 PHY (RGMII) |
| USB | 前置 1× USB 2.0 + 侧边 3× USB 2.0（板载 Genesys Logic `05e3:0610` Hub，host 模式） |
| HDMI | 视频与 HDMI 数字音频正常 |
| 3.5mm 音频 | 3.5mm 耳机 / 模拟输出正常（片内 `t9015` DAC + `GPIOAO_2` 功放控制） |
| 按键与指示灯 | 物理电源键 (`GPIOAO_4`)、绿色状态灯 (`GPIOAO_10`) |

---

## ⚠️ 刷机前必读

本设备树仅适用于 **朝歌科技 S-BOX8K40（标准版）**。

该盒子存在 **麒麟版（Kirin version）**，硬件配置可能不同。  
**刷机前请务必确认你的盒子版本，核对硬件配置，变砖概不负责。**

---

## 文件说明

- `meson-sm1-sbox8k40.dts `— 设备树源码
- `meson-sm1-sbox8k40.dtb `— 编译后的二进制
- `u-boot.bin `— **原机 bootloader 备份**（从 Android 系统提取），用于刷机后恢复原厂引导。刷机前建议先备份自己的 bootloader

基础包含：`meson-sm1-ac2xx.dtsi ` 
内核版本：**Linux 6.12**（主线 / ophub）

---

## 与 ac2xx 默认配置的差异

| 改动项 | 默认值 | S-BOX8K40 |
|--------|--------|-----------|
| SDIO UHS 模式 | sdr104 | sdr12 / sdr25 / sdr50 |
| SDIO 最高频率 | 200 MHz | 50 MHz |
| WiFi 子节点 | 无 | rtl8822cs SDIO |
| WiFi 中断 | 无 | 已移除（rtw88 使用 SDIO 带内中断） |
| 蓝牙波特率 | 115200 | 1500000 |
| 蓝牙 host-wake GPIO | 无 | GPIOX_19 |
| 蓝牙 enable GPIO | 无 | GPIOX_17 |
| 蓝牙 device-wake GPIO | 无 | GPIOX_18 |
| 网口 PHY | 内部 mdio | 外部 RTL8211F (RGMII) |
| USB 模式 | otg | host |
| CPU 频率上限 | 全部启用 | 禁用 2.0 / 2.1 GHz |
| 重启机制 | PSCI `SYSTEM_RESET` | `syscon-reboot` 接管至 EE Watchdog (`0xffd0f0d0`)，优先级 192 |
| 节点清理与规范 | 包含无效 `aml_reboot`/`fd655_dev`、`simplefb_hdmi` 32 位 `reg` | 已移除无用 Android BSP 残留节点，修正 `simplefb_hdmi` 为 64 位 `reg` |
| 电源域与音频总线 | 继承 SM1 `pwrc` 与 `0xff660000` (`bus@60000`) | 修正为真实 G12A `pwrc`（仅保留 VPU / `ETH=1` 电源域），音频总线修正为 `0xff642000` (`bus@42000`) + `g12a-audio-clkc` |
| 音频输出 | 全部禁用 | 启用 HDMI 音频（`TDMOUT_B -> TOHDMITX`）与 3.5mm 模拟音频（`TDMOUT_C -> TOACODEC -> t9015` + `GPIOAO_2` 功放 `10U2`） |
| 指示灯与按键 | 未定义 / 已禁用 | 启用绿色状态灯 `green:status`（`GPIOAO_10`）与 `gpio-keys-polled` 电源键（`GPIOAO_4`） |
| GPU 供电 | 缺少 `mali-supply` | 补充 `vdd_ee`（800mV fixed regulator）并绑定到 `&mali` |

---

## 已知问题

### 1. ~~重启后需手动按电源键~~（已修复）
原厂 bootloader 的 PSCI `SYSTEM_RESET` 在主线内核下会触发整机断电，且原 Android DTS 中的 `aml_reboot` 节点在主线内核中无对应驱动。

现已移除无效的 `aml_reboot` 节点，改为在设备树中添加 `wdt_syscon`（映射 EE Watchdog 控制器 `0xffd0f0d0`）与 `syscon-reboot`（优先级 `192`，高于 PSCI 的 `129`），在执行 `reboot` 时直接通过硬件看门狗触发 SoC 复位（已在 Linux `6.12.113-ophub` / `6.12.117-ophub` 实机验证可正常重启上线）。

### 2. ~~按 SM1 音频总线开启声卡会启动卡死~~（已修复）
该主板实测为 G12A 芯片（`Revision 28:e / 70:2`，音频总线在 `0xff642000`），而 `meson-sm1-ac2xx.dtsi` 默认定义的音频总线在 `0xff660000` 且使用了 `amlogic,meson-sm1-pwrc`。现已在设备树中删除 `bus@60000` 并改为 G12A `bus@42000`（`amlogic,g12a-audio-clkc` / `amlogic,meson-axg-audio-arb`），同时将 `pwrc` 改为 `amlogic,meson-g12a-pwrc`，实测 HDMI 与 3.5mm 音频均正常注册且无掉电/总线挂死。

### 3. WiFi TX 报告超时
RTL8822CS 固件在 SDIO 上不可靠地发送 TX 状态报告。
rtw88 驱动可能会打印 "failed to get tx report from firmware"，但可自动恢复（ophub 内核下工作正常）。

---

## 编译

需要 arm64 交叉编译工具链：

```
cd linux-6.12.y
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- dtbs
```

输出：arch/arm64/boot/dts/amlogic/meson-sm1-sbox8k40.dtb

## 部署

```
cp meson-sm1-sbox8k40.dtb /boot/dtb/amlogic/
sync
```

## 验证

```
dtc -I dtb -O dts /boot/dtb/amlogic/meson-sm1-sbox8k40.dtb | grep -E "model|bluetooth|wifi|sound|acodec|green:status"
```

已在 Linux `6.12.113-ophub` 与 `6.12.117-ophub` 上实机验证通过（含 `reboot` 正常热重启、HDMI + 3.5mm 声卡 `MESON-G12A-SBOX8K40`、`panfrost` GPU、状态灯/电源键、`RTL8211F` 千兆网与 SDIO Wi-Fi/蓝牙）。

---

## WiFi 连接

### 手动连接

```bash
# 扫描
iw dev wlan0 scan | grep SSID

# 配置
cat > /etc/wpa_supplicant/wpa_supplicant.conf << 'WEOF'
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=CN
network={
`    ssid="你的WiFi名称"
`    psk="你的WiFi密码"
`    key_mgmt=WPA-PSK
}
WEOF

# 连接
wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
sleep 8
dhcpcd wlan0
```

### 开机自连（Armbian / ophub）

添加 crontab：

```
@reboot sleep 10 && wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf && sleep 5 && dhcpcd wlan0
```

---

## 蓝牙

```bash
# 安装 bluez（如未安装）
wget http://ports.ubuntu.com/pool/main/b/bluez/bluez_5.72-0ubuntu5.5_arm64.deb
dpkg -i bluez_5.72-0ubuntu5.5_arm64.deb

# 开启蓝牙并扫描
bluetoothctl power on
bluetoothctl scan on

# 配对
bluetoothctl pair XX:XX:XX:XX:XX:XX
bluetoothctl connect XX:XX:XX:XX:XX:XX
```

---

## 许可

GPL-2.0+ OR MIT（与上游 Amlogic DTS 文件一致）

---

> 如果觉得有用，请给我点亮 Star ⭐
