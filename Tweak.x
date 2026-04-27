#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <substrate.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>

static BOOL tweakEnabled = YES;
static BOOL receiverStarted = NO;

static void loadPrefs(void) {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.v4h.usbcam"];
    id saved = [prefs objectForKey:@"enabled"];
    tweakEnabled = saved ? [prefs boolForKey:@"enabled"] : YES;
}

static void prefsChanged(CFNotificationCenterRef center,
                         void *observer,
                         CFStringRef name,
                         const void *object,
                         CFDictionaryRef userInfo) {
    loadPrefs();
}

// Receiver stub: keeps build/runtime safe. Real frame decoding/AVSampleBuffer injection is not included here.
static void setupUSBReceiver(void) {
    if (receiverStarted) return;
    receiverStarted = YES;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        int fd = socket(AF_INET, SOCK_STREAM, 0);
        if (fd < 0) return;

        int opt = 1;
        setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

        struct sockaddr_in addr;
        memset(&addr, 0, sizeof(addr));
        addr.sin_family = AF_INET;
        addr.sin_port = htons(8888);
        if (inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr) != 1) {
            close(fd);
            return;
        }

        if (bind(fd, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
            close(fd);
            return;
        }
        if (listen(fd, 1) != 0) {
            close(fd);
            return;
        }

        while (1) {
            int client = accept(fd, NULL, NULL);
            if (client >= 0) {
                char buf[1024];
                while (read(client, buf, sizeof(buf)) > 0) { }
                close(client);
            }
        }
    });
}

%hook AVCaptureVideoDataOutput
- (void)captureOutput:(id)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(id)connection {
    // Build-safe toggle point. When disabled/enabled, original camera still works normally.
    // Add legal/owned-device frame processing here if needed.
    %orig(output, sampleBuffer, connection);
}
%end

%ctor {
    @autoreleasepool {
        loadPrefs();
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        prefsChanged,
                                        CFSTR("com.v4h.usbcam/Reload"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
        setupUSBReceiver();
    }
}
