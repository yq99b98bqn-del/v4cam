ARCHS = arm64
TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = v4hUSBPro
v4hUSBPro_FILES = Tweak.x
v4hUSBPro_FRAMEWORKS = AVFoundation CoreVideo CoreMedia Foundation
v4hUSBPro_CFLAGS = -Wno-error -Wno-error=deprecated-declarations -Wno-deprecated-declarations -Wno-error=unused-variable -Wno-unused-variable -Wno-error=implicit-function-declaration

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += v4hApp
include $(THEOS_MAKE_PATH)/aggregate.mk