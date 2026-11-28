LOCAL_PATH := device/sunniwell/p291_iptv

# Inherit basic embedded configuration & Omni TWRP common rules
$(call inherit-product, $(SRC_TARGET_DIR)/product/embedded.mk)
$(call inherit-product, vendor/omni/config/common.mk)

PRODUCT_DEVICE := p291_iptv
PRODUCT_NAME := omni_p291_iptv
PRODUCT_BRAND := Sunniwell
PRODUCT_MODEL := S-Box8K40
PRODUCT_MANUFACTURER := Sunniwell

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/twrp.fstab:recovery/root/etc/twrp.fstab \
    $(LOCAL_PATH)/recovery/root/init.recovery.amlogic.rc:recovery/root/init.recovery.amlogic.rc \
    $(LOCAL_PATH)/recovery/root/sbin/remotecfg:recovery/root/sbin/remotecfg \
    $(LOCAL_PATH)/recovery/root/etc/mesondisplay.cfg:recovery/root/etc/mesondisplay.cfg \
    $(LOCAL_PATH)/recovery/root/etc/remote.cfg:recovery/root/etc/remote.cfg \
    $(LOCAL_PATH)/recovery/root/etc/remote.tab1:recovery/root/etc/remote.tab1 \
    $(LOCAL_PATH)/recovery/root/etc/remote.tab2:recovery/root/etc/remote.tab2 \
    $(LOCAL_PATH)/recovery/root/etc/remote.tab3:recovery/root/etc/remote.tab3 \
    $(LOCAL_PATH)/recovery/root/etc/remote.tab4:recovery/root/etc/remote.tab4
