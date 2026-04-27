#import "v4hRootViewController.h"

@implementation v4hRootViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"v4h USB Cam";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    UISwitch *sw = [[UISwitch alloc] init];
    sw.center = self.view.center;
    [sw addTarget:self action:@selector(toggleTweak:) forControlEvents:UIControlEventValueChanged];
    
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.v4h.usbcam"];
    [sw setOn:[prefs boolForKey:@"enabled"]];
    
    [self.view addSubview:sw];
}

- (void)toggleTweak:(UISwitch *)sender {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.v4h.usbcam"];
    [prefs setBool:sender.isOn forKey:@"enabled"];
    [prefs synchronize];
    // Gửi thông báo để Tweak.x nhận lệnh ngay lập tức
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.v4h.usbcam/Reload"), NULL, NULL, YES);
}
@end