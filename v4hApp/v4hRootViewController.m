#import "v4hRootViewController.h"

static NSString * const kPrefsSuite = @"com.v4h.usbcam";
static NSString * const kReloadNotify = @"com.v4h.usbcam/Reload";

@interface v4hRootViewController ()
@property(nonatomic,strong) UISwitch *enableSwitch;
@property(nonatomic,strong) UILabel *statusLabel;
@end

@implementation v4hRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"v4h USB Cam";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.text = @"VCAM Toggle";
    title.font = [UIFont boldSystemFontOfSize:28];
    title.textAlignment = NSTextAlignmentCenter;
    title.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:title];

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.statusLabel.font = [UIFont systemFontOfSize:16];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.statusLabel];

    self.enableSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.enableSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [self.enableSwitch addTarget:self action:@selector(toggleTweak:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.enableSwitch];

    UIButton *respring = [UIButton buttonWithType:UIButtonTypeSystem];
    [respring setTitle:@"Respring" forState:UIControlStateNormal];
    respring.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    respring.translatesAutoresizingMaskIntoConstraints = NO;
    [respring addTarget:self action:@selector(respring) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:respring];

    [NSLayoutConstraint activateConstraints:@[
        [title.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:60],
        [title.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.enableSwitch.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:40],
        [self.enableSwitch.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.enableSwitch.bottomAnchor constant:25],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:24],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-24],
        [respring.topAnchor constraintEqualToAnchor:self.statusLabel.bottomAnchor constant:30],
        [respring.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor]
    ]];

    [self reloadState];
}

- (void)reloadState {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:kPrefsSuite];
    if ([prefs objectForKey:@"enabled"] == nil) {
        [prefs setBool:YES forKey:@"enabled"];
        [prefs synchronize];
    }
    BOOL enabled = [prefs boolForKey:@"enabled"];
    [self.enableSwitch setOn:enabled animated:NO];
    self.statusLabel.text = enabled ? @"Đang bật" : @"Đang tắt";
}

- (void)toggleTweak:(UISwitch *)sender {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:kPrefsSuite];
    [prefs setBool:sender.isOn forKey:@"enabled"];
    [prefs synchronize];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)kReloadNotify, NULL, NULL, YES);
    [self reloadState];
}

- (void)respring {
    system("/usr/bin/killall -9 SpringBoard");
}

@end
