#import "AppDelegate.h"
#import "ChatViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    ChatViewController *chatVC = [[ChatViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:chatVC];
    
    // Skeuomorphic iOS 6 Navigation Bar Styling (Glossy Look)
    navVC.navigationBar.barTintColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.22 alpha:1.0];
    navVC.navigationBar.tintColor = [UIColor whiteColor];
    navVC.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: [UIColor whiteColor],
        NSFontAttributeName: [UIFont boldSystemFontOfSize:20]
    };
    navVC.navigationBar.translucent = NO;
    
    // Add shadow to navigation bar for depth
    navVC.navigationBar.layer.shadowColor = [UIColor blackColor].CGColor;
    navVC.navigationBar.layer.shadowOffset = CGSizeMake(0, 2.0);
    navVC.navigationBar.layer.shadowRadius = 3.0;
    navVC.navigationBar.layer.shadowOpacity = 0.5;
    navVC.navigationBar.layer.masksToBounds = NO;
    
    self.window.rootViewController = navVC;
    [self.window makeKeyAndVisible];
    return YES;
}
@end
