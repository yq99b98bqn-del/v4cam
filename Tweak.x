#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <substrate.h>

#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>
#include <string.h>

static BOOL tweakEnabled = YES;
static BOOL receiverStarted = NO;
static int listenFd = -1;

static void loadPrefs(void) {
    @autoreleasepool {
        NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.v4h.usbcam"];
        if ([prefs objectForKey:@"enabled"] == nil) {
            tweakEnabled = YES;
            [prefs setBool:YES forKey:@"enabled"];
            [prefs synchronize];
        } else {
            tweakEnabled = [prefs boolForKey:@"enabled"];
        }
    }
}

static void prefsChanged(CFNotificationCenterRef center,
                         void *observer,
                         CFStringRef name,
                         const void *object,
                         CFDictionaryRef userInfo) {
    loadPrefs();
}

static void setupUSBReceiver(void) {
    if (receiverStarted) return;
    receiverStarted = YES;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        listenFd = socket(AF_INET, SOCK_STREAM, 0);
        if (listenFd < 0) return;

        int yes = 1;
        setsockopt(listenFd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes));

        struct sockaddr_in addr;
        memset(&addr, 0, sizeof(addr));
        addr.sin_family = AF_INET;
        addr.sin_port = htons(8888);
        inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr);

        if (bind(listenFd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
            close(listenFd);
            listenFd = -1;
            return;
        }

        if (listen(listenFd, 1) < 0) {
            close(listenFd);
            listenFd = -1;
            return;
        }

        while (1) {
            int client = accept(listenFd, NULL, NULL);
            if (client < 0) continue;

            char buffer[4096];
            while (read(client, buffer, sizeof(buffer)) > 0) {
                // Safe placeholder: receives USB/localhost stream data.
                // Frame injection/identity-spoofing logic is intentionally not included.
            }
            close(client);
        }
    });
}

%hook AVCaptureVideoDataOutput
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    loadPrefs();
    %orig(output, sampleBuffer, connection);
}
%end

%ctor {
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    prefsChanged,
                                    CFSTR("com.v4h.usbcam/Reload"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    setupUSBReceiver();
}
