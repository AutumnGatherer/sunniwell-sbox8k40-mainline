LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),p291_iptv)
include $(call all-subdir-makefiles,$(LOCAL_PATH))
endif
