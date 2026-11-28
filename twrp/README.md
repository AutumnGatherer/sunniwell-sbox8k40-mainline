# Sunniwell S-BOX8K40 Pro (p291_iptv) TWRP 9.0 设备树

本目录包含适用于朝歌 **S-BOX8K40 Pro**（Android 9 / `p291_iptv` / 32 位 ARM 内核 `4.9.113`）的 **TWRP 9.0 (`omni_p291_iptv`)** 设备树及 GitHub Actions 云端编译配置。

## 设备树特性

- **架构与内核**：`armeabi-v7a`（ARMv7-A NEON, Cortex-A53），复用原厂 `recovery.img` 提取的 `Linux-4.9.113` `uImage` 内核与压缩 DTB（header v1 偏移完全对齐，上限 `24 MiB`）
- **显示界面**：`TW_THEME := landscape_hdpi`（1080p 横屏，默认中文 `zh_CN`），默认 `TARGET_RECOVERY_PIXEL_FORMAT := "BGRA_8888"` + `RECOVERY_GRAPHICS_USE_LINELENGTH := true`
- **操作方式**：支持 **USB 鼠标**点击操作，并保留原厂 `/sbin/remotecfg` + `/etc/remote.tab1~4` 红外遥控器配置
- **分区挂载**：已映射 `boot`、`recovery`、`logo`、`dtbo`、`vbmeta`、`bootloader`、`system`、`vendor`、`odm`、`product`、`cache`、`data`、`swdb` 及外接 U 盘 `/udisk`（含 NTFS-3G 与 exFAT）

---

## 云端编译方法（GitHub Actions）

1. 在 GitHub 仓库页进入 **Actions -> Build TWRP 9.0**（或推送更新至 `twrp/**` / `.github/workflows/build-twrp.yml` 自动触发）。
2. 如在电视上出现画面偏色（红蓝反转），可在 **Run workflow** 时直接选择 `pixel_format` 参数切换为 `RGBA_8888` 或 `RGBX_8888` 一键重新编译。
3. 编译完成后可直接从 **Workflow Artifacts** 或 **Releases (`twrp-latest`)** 下载 `twrp-sbox8k40-p291_iptv.img`。

---

## 刷入与测试方式（仅限原厂 Android 9 eMMC 分区表）

1. **已进入带 Root 的原厂 Android 9 系统时刷入**：
   ```bash
   adb push twrp-sbox8k40-p291_iptv.img /sdcard/twrp.img
   adb shell su -c "dd if=/sdcard/twrp.img of=/dev/block/recovery bs=4M && sync && reboot recovery"
   ```
2. **仅临时测试（不写 eMMC `recovery` 分区）**：
   - 若处于原厂 Android 引导环境，可将 `twrp-sbox8k40-p291_iptv.img` 重命名为 `recovery.img` 放到 FAT32 格式 U 盘根目录，在开机按住电源键/恢复键（`GPIOAO_4`）或进 U-Boot 触发 `run recovery_from_udisk` 引导。
3. **进入后建议插入 USB 鼠标**，即可直接浏览和备份/还原分区或刷入卡刷包。
