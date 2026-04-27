#import "v4hRootViewController.h"
#import <CoreFoundation/CoreFoundation.h>

@implementation v4hRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"v4h USB Cam";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, self.view.bounds.size.width - 40, 40)];
    titleLabel.text = @"Enable VCAM";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:24];
    [self.view addSubview:titleLabel];

    UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(20, 165, self.view.bounds.size.width - 40, 70)];
    desc.text = @"Bật/tắt tweak bằng công tắc bên dưới. Sau khi đổi, thoát và mở lại app camera cần dùng.";
    desc.textAlignment = NSTextAlignmentCenter;
    desc.numberOfLines = 0;
    desc.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:desc];

    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectZero];
    sw.center = CGPointMake(self.view.bounds.size.width / 2.0, 270);
    [sw addTarget:self action:@selector(toggleTweak:) forControlEvents:UIControlEventValueChanged];

    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.v4h.usbcam"];
    id saved = [prefs objectForKey:@"enabled"];
    [sw setOn:(saved ? [prefs boolForKey:@"enabled"] : YES)];

    [self.view addSubview:sw];
}

- (void)toggleTweak:(UISwitch *)sender {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.v4h.usbcam"];
    [prefs setBool:sender.isOn forKey:@"enabled"];
    [prefs synchronize];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.v4h.usbcam/Reload"), NULL, NULL, YES);
}

@end
