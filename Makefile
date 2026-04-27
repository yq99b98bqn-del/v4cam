ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = v4hUSBPro
v4hUSBPro_FILES = Tweak.x
v4hUSBPro_FRAMEWORKS = AVFoundation CoreVideo CoreMedia UIKit Foundation
v4hUSBPro_CFLAGS = -fobjc-arc -Wno-error -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-but-set-variable -Wno-implicit-function-declaration -Wno-deprecated-non-prototype
v4hUSBPro_LDFLAGS =

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += v4hApp
include $(THEOS_MAKE_PATH)/aggregate.mk
