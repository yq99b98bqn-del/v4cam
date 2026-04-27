include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = v4hApp
v4hApp_FILES = main.m v4hAppDelegate.m v4hRootViewController.m
v4hApp_FRAMEWORKS = UIKit CoreGraphics Foundation
v4hApp_CFLAGS = -fobjc-arc -Wno-error -Wno-deprecated-declarations
v4hApp_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS_MAKE_PATH)/application.mk
