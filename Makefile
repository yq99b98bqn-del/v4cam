ARCHS = arm64
TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = v4hUSBPro
v4hUSBPro_FILES = Tweak.x
v4hUSBPro_FRAMEWORKS = AVFoundation CoreVideo CoreMedia

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += v4hApp
include $(THEOS_MAKE_PATH)/aggregate.mk