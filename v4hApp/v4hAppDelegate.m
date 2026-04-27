#import "v4hAppDelegate.h"
#import "v4hRootViewController.h"

@implementation v4hAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[v4hRootViewController alloc] init]];
    [self.window makeKeyAndVisible];
    return YES;
}
@end