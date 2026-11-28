DEVICE_PATH := device/sunniwell/p291_iptv

# Architecture (32-bit ARMv7-A userland + 32-bit Linux 4.9.113 uImage on G12A Cortex-A53)
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := cortex-a53

TARGET_BOARD_PLATFORM := amlogic
TARGET_BOOTLOADER_BOARD_NAME := p291_iptv
TARGET_NO_BOOTLOADER := true

# Kernel & Stock Header v1 Layout (extracted verbatim from org/recovery.img)
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/kernel
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_CMDLINE := androidboot.dtbo_idx=0 buildvariant=userdebug
BOARD_MKBOOTIMG_ARGS := --kernel_offset 0x01080000 --ramdisk_offset 0x01000000 --second_offset 0x00f00000 --tags_offset 0x00000100 --header_version 1 --second $(DEVICE_PATH)/prebuilt/second

PLATFORM_VERSION := 9.0.0
PLATFORM_SECURITY_PATCH := 2018-08-05

# Partition & Filesystem
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 25165824
BOARD_FLASH_BLOCK_SIZE := 512
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_HAS_LARGE_FILESYSTEM := true

# TWRP UI & TV Box Input/Display
TW_THEME := landscape_hdpi
TARGET_RECOVERY_PIXEL_FORMAT := "BGRA_8888"
RECOVERY_GRAPHICS_USE_LINELENGTH := true
TW_DEFAULT_LANGUAGE := zh_CN
TW_EXTRA_LANGUAGES := true
TW_NO_SCREEN_TIMEOUT := true
TW_NO_SCREEN_BLANK := true
TW_NO_BATT_PERCENT := true
TW_BRIGHTNESS_PATH := "/dev/null"
TW_EXCLUDE_SUPERSU := true
TW_INCLUDE_NTFS_3G := true
TW_USE_NEW_MINADBD := true
RECOVERY_SDCARD_ON_DATA := true

ALLOW_MISSING_DEPENDENCIES := true
