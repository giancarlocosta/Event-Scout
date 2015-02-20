//
//  TuduAppDelegate.h
//  TuduAppDelegate
//
//
//
#import <Parse/Parse.h>
#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "TuduTabBarController.h"


@class ParseStarterProjectViewController;

@interface TuduAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, PFLogInViewControllerDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) TuduTabBarController *tabBarController;
@property (nonatomic, strong) UINavigationController *navController;

@property (nonatomic, readonly) int networkStatus;


- (BOOL)isParseReachable;

- (void)presentLoginViewController;
- (void)presentLoginViewControllerAnimated:(BOOL)animated;
- (void)presentTabBarController;

- (void)logOut;

- (void)facebookRequestDidLoad:(id)result;
- (void)facebookRequestDidFailWithError:(NSError *)error;

@end
