#import <AVFoundation/AVFoundation.h>
#import <substrate.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>
#import <Foundation/Foundation.h>

static CVPixelBufferRef obsFrame = NULL;
static BOOL tweakEnabled = YES;

// Hàm nhận dữ liệu từ cổng USB (localhost)
void setupUSBReceiver() {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        int fd = socket(AF_INET, SOCK_STREAM, 0);
        struct sockaddr_in addr;
        addr.sin_family = AF_INET;
        addr.sin_port = htons(8888); // Cổng 8888
        inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr);

        bind(fd, (struct sockaddr *)&addr, sizeof(addr));
        listen(fd, 1);

        while(1) {
            int client = accept(fd, NULL, NULL);
            // Logic nhận frame thô từ OBS tại đây
            close(client);
        }
    });
}

void loadPrefs() {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.v4h.usbcam"];
    tweakEnabled = [prefs objectForKey:@"enabled"] ? [prefs boolForKey:@"enabled"] : YES;
}

%hook AVCaptureVideoDataOutput
- (void)captureOutput:(id)output didOutputSampleBuffer:(CMSampleBufferRef)sb fromConnection:(id)conn {
    if (tweakEnabled && obsFrame != NULL) {
        // Tạo buffer giả từ obsFrame và gửi đi
        %orig; 
    } else {
        %orig;
    }
}
%end

%ctor {
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.v4h.usbcam/Reload"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    setupUSBReceiver();
}