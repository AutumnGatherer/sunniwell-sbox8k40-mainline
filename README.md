# 朝歌 Sunniwell S-BOX8K40 Pro (Amlogic Meson G12A) 主线设备树

> ⚠️ **WARNING / 严重警告**
>
> 本仓库设备树 **仅适用于 朝歌科技 Sunniwell S-BOX8K40 高配版（Pro，4GB DDR4 / 原厂 DTB `g12a_u212_4g`）**。  
> **切勿刷入「麒麟版（Kirin）」或其它硬件版本**，硬件配置不匹配可能导致无法启动或变砖；刷机前请务必在 U 盘系统上先行测试并备份原机引导分区。

---

## 快速识别（S-BOX8K40 高配版 Pro）

- **机身接口**：`1× HDMI`、`1× 12V DC`、`1× RJ45 千兆网口`、`1× 3.5mm 模拟音频/耳机输出`（无 AV 视频接口）、前置 `1× USB` + 侧边 `3× USB`
- **原厂 DTB 标识**：`g12a_u212_4g`（SoC 实测为 `Amlogic Meson G12A Revision 28:e / 70:2`，4× ARM Cortex-A53 `0xd03`）
- **文件命名说明**：为保持与现有 Armbian / ophub 引导脚本及 `uEnv.txt` 的向后兼容，设备树源码与二进制文件名沿用 `meson-sm1-sbox8k40.*`（基础包含 `meson-sm1-ac2xx.dtsi`），内部已将 `pwrc` 电源域控制器与音频总线（`0xff642000` / `bus@42000`）全面修正为真实 **G12A** 硬件配置。

---

## 硬件配置与主线适配状态

| 硬件模块 | 规格 / 驱动说明 | 状态 |
| --- | --- | --- |
| **SoC / CPU** | Amlogic Meson G12A (`Revision 28:e (70:2)`)，4× Cortex-A53（最高限制在 2.0 GHz 以下） | ✅ 正常 |
| **内存与存储** | 4GB DDR4 + 16GB eMMC (`mmcblk2`) | ✅ 正常 |
| **GPU** | Mali-G31 MP2（`panfrost` + 补充 `vdd_ee` 800mV 稳压供电） | ✅ 正常 |
| **有线网络** | Realtek `RTL8211F` 千兆 PHY（RGMII，`GPIOZ_15` 复位，`PWRC_G12A_ETH_ID`） | ✅ 正常 |
| **Wi-Fi / 蓝牙** | Realtek `RTL8822CS`（SDIO Wi-Fi 50MHz SDR50 + UART 蓝牙 1.5Mbps） | ✅ 正常 |
| **USB** | 板载 Genesys Logic (`05e3:0610`) 4 口 USB 2.0 Hub（前置 1 + 侧边 3）+ USB 3.0，Host 模式 | ✅ 正常 |
| **HDMI 视频** | `meson-dw-hdmi` + `simplefb_hdmi`（开机早期显示控制台） | ✅ 正常 |
| **HDMI 音频** | `axg-sound-card` (`MESON-G12A-SBOX8K40`) -> `TDMOUT_B` -> `TOHDMITX` | ✅ 正常 |
| **3.5mm 音频** | 片内 `t9015` DAC -> `TOACODEC` -> `TDMOUT_C` + `GPIOAO_2` 功放使能 (`10U2`) | ✅ 正常 |
| **指示灯与按键** | 绿色状态灯 `green:status`（`GPIOAO_10`）、物理电源键（`gpio-keys-polled`，`GPIOAO_4`） | ✅ 正常 |
| **红外 / CEC** | `meson-ir` + `meson_g12a_ao_cec` | ✅ 正常 |
| **系统重启** | EE Watchdog (`0xffd0f0d0`) + `syscon-reboot`（优先级 192，解决 `reboot` 变关机） | ✅ 正常 |

---

## 仓库文件说明

| 文件 | 说明 |
| --- | --- |
| [`meson-sm1-sbox8k40.dtb`](./meson-sm1-sbox8k40.dtb) | 已编译并实机验证通过的设备树二进制，可直接放入 `/boot/dtb/amlogic/` 使用 |
| [`meson-sm1-sbox8k40.dts`](./meson-sm1-sbox8k40.dts) | 对应设备树源码（基于 Linux 6.12 主线头文件） |
| [`u-boot.bin`](./u-boot.bin) | 原机 bootloader 备份（供救砖或恢复原厂引导参考，刷写前建议先自行备份本机引导） |

- **实测验证环境**：Linux `6.12.113-ophub`（内置 eMMC）与 `6.12.117-ophub`（外置 U 盘），`devices_deferred` 为空、`systemctl --failed` 为 `0`。

---

## 部署与验证

### 1. 部署到 Armbian / ophub

> 建议先在可插拔 **U 盘启动系统** 上验证无误后再写入内置 eMMC。

```bash
# 1. 备份现有 DTB（如已存在）
cp /boot/dtb/amlogic/meson-sm1-sbox8k40.dtb /boot/dtb/amlogic/meson-sm1-sbox8k40.dtb.bak 2>/dev/null || true

# 2. 复制新 DTB 并确认 /boot/uEnv.txt 中的 FDT 指向
cp meson-sm1-sbox8k40.dtb /boot/dtb/amlogic/meson-sm1-sbox8k40.dtb
grep -E '^FDT=' /boot/uEnv.txt || echo '请检查 /boot/uEnv.txt 中 FDT=/dtb/amlogic/meson-sm1-sbox8k40.dtb'

# 3. 落盘并热重启
sync && reboot
```

### 2. 开机验证

```bash
# 检查声卡（HDMI + 3.5mm 模拟输出同卡注册为 MESON-G12A-SBOX8K40）
cat /proc/asound/cards
aplay -l

# 检查是否存在延迟/失败挂载设备与异常服务
cat /sys/kernel/debug/devices_deferred
systemctl --failed --no-pager

# 检查绿色状态灯与电源键输入设备
ls -la /sys/class/leds/
grep -E 'Name=|Handlers=' /proc/bus/input/devices
```

---

## 外设使用说明

### 音频（HDMI 与 3.5mm 输出）

HDMI 与 3.5mm（`ACODEC` / `t9015`）共享前端播放设备 `card 0`（`MESON-G12A-SBOX8K40`，`device 0/1/2` 对应 `FRDDR_A/B/C`），可通过 `amixer` / `alsamixer` 切换路由与开关：

```bash
# 查看混音器控件（包含 ACODEC、TOACODEC、TOHDMITX、TDMOUT_B、TDMOUT_C）
amixer -c 0 scontrols
```

### 绿色状态灯

```bash
# 关闭 / 点亮绿色状态灯
echo 0 > /sys/class/leds/green:status/brightness
echo 1 > /sys/class/leds/green:status/brightness
```

### Wi-Fi 连接（RTL8822CS）

```bash
# 扫描附近 Wi-Fi
iw dev wlan0 scan | grep SSID

# 写入配置文件
cat > /etc/wpa_supplicant/wpa_supplicant.conf << 'WEOF'
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=CN
network={
    ssid="你的WiFi名称"
    psk="你的WiFi密码"
    key_mgmt=WPA-PSK
}
WEOF

# 启动连接并获取 IP
wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
sleep 8
dhcpcd wlan0
```

如需开机自动连接，可在 `crontab -e` 添加：

```cron
@reboot sleep 10 && wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf && sleep 5 && dhcpcd wlan0
```

### 蓝牙（RTL8822CS UART BT）

```bash
# 若系统尚未安装 bluez，按需安装后使用 bluetoothctl 配对
bluetoothctl power on
bluetoothctl scan on
# bluetoothctl pair XX:XX:XX:XX:XX:XX
# bluetoothctl connect XX:XX:XX:XX:XX:XX
```

---

## 与 `meson-sm1-ac2xx.dtsi` 的主要改动

| 改动项 | 默认（`meson-sm1-ac2xx.dtsi`） | S-BOX8K40 修正 |
| --- | --- | --- |
| **电源域 (`pwrc`)** | `amlogic,meson-sm1-pwrc` | 修正为 `amlogic,meson-g12a-pwrc`，`ethmac` 使用 `PWRC_G12A_ETH_ID`，移除 `usb`/`pcie`/`npu` 的 SM1 电源域引用 |
| **音频总线** | `0xff660000` (`bus@60000`, `sm1-audio-clkc`) | 替换为 G12A `0xff642000` (`bus@42000`, `g12a-audio-clkc` + `meson-axg-audio-arb`) |
| **声卡链路 (`sound`)** | 未完整适配 | 启用 HDMI (`TDMOUT_B -> TOHDMITX`) 与 3.5mm 模拟输出 (`TDMOUT_C -> TOACODEC -> t9015` + `GPIOAO_2` 功放) |
| **GPU 供电** | 缺少 `mali-supply` | 增加 `vdd_ee` 800mV fixed regulator 并绑定到 `&mali` |
| **LED 与按键** | 未定义 / 禁用 | 新增 `led-green`（`GPIOAO_10`）与 `gpio-keys-polled` 电源键（`GPIOAO_4`） |
| **热重启机制** | PSCI `SYSTEM_RESET` / 无效 `aml_reboot` | 增加 `wdt_syscon` (`0xffd0f0d0`) + `syscon-reboot`（优先级 `192`） |
| **Wi-Fi (SDIO)** | SDR104 @ 200 MHz，带外中断 | 调整为 SDR12/SDR25/SDR50 @ 50 MHz，SDIO 带内中断，添加 `rtl8822cs` 子节点 |
| **蓝牙 (UART_A)** | 115200 bps | 1.5 Mbps，`GPIOX_17`（enable）、`GPIOX_18`（dev-wake）、`GPIOX_19`（host-wake） |
| **有线网口** | 内部 MDIO PHY | 外部 `RTL8211F`（RGMII，`tx-delay-ns = <2>`，`GPIOZ_15` 复位） |
| **USB / 早期显示** | `usb` 默认 OTG、`simplefb_hdmi` 32 位 `reg` | `dr_mode = "host"`；清理 `fd655_dev` 等残留并修正 `simplefb_hdmi` 64 位 `reg` |
| **CPU 频率上限** | 含 2.0 / 2.1 GHz OPP | 禁用 `2016 MHz` 与 `2100 MHz` 档位以保证长期稳定运行 |

---

## 已知与已修复问题记录

1. **【已修复】执行 `reboot` 变成关机断电**  
   原厂 bootloader 的 PSCI `SYSTEM_RESET` 在主线内核下会触发整机断电，且 BSP 遗留 `aml_reboot` 在主线无驱动。现已移除 `aml_reboot`，改为映射 Watchdog `0xffd0f0d0` 并启用高于 PSCI 的 `syscon-reboot`（优先级 `192`），可正常热重启。
2. **【已修复】开启 SM1 音频节点导致启动卡死在 `sda: sda1 sda2` 附近**  
   实机识别为 G12A（`Revision 28:e / 70:2`），硬件不存在 SM1 的 `0xff660000` 音频总线。迁移音频总线至 G12A `0xff642000`（`bus@42000`）并修正 `meson-g12a-pwrc` 后问题彻底解决。
3. **Wi-Fi `failed to get tx report from firmware` 日志提示**  
   `RTL8822CS` 固件在 SDIO 模式下偶发不回报 TX 状态，`rtw88` 会打印提示并自动恢复，实机联网正常。
4. **红色电源/待机 LED（`GPIOAO_11`）**  
   由于主线中 `GPIOAO_11` 与 `pwm_AO_ab`（`VDDEE` 调压相关引脚复用）存在关联，为确保核心供电稳定，当前版本仅启用绿色工作指示灯（`GPIOAO_10`），未强行接管 `GPIOAO_11`。

---

## 从源码编译

如需在内核源码树中自行重新编译：

```bash
# 将 meson-sm1-sbox8k40.dts 放入 arch/arm64/boot/dts/amlogic/
cd linux-6.12.y
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- dtbs
# 输出文件：arch/arm64/boot/dts/amlogic/meson-sm1-sbox8k40.dtb
```

---

## 许可协议

`GPL-2.0+ OR MIT`（与上游 Linux Amlogic 设备树保持一致）。
