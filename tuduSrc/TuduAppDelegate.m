//
//  TuduAppDelegate.m
//  tudu
//
//  Copyright 2014 Parse, Inc. All rights reserved.
//

#import <Parse/Parse.h>

// If you are using Facebook, uncomment this line
#import <ParseFacebookUtils/PFFacebookUtils.h>

#import "Reachability.h"
#import "UIImage+ResizeAdditions.h"
#import "MBProgressHUD.h"
#import "ParseStarterProjectAppDelegate.h"
#import "ParseStarterProjectViewController.h"
#import "TuduEventCreatorViewController.h"
#import "TuduWelcomeViewController.h"
#import "TuduLoginViewController.h"
#import "TuduSearchViewController.h"
#import "TuduProfileViewController.h"
#import "TuduHomeViewController.h"
#import "TuduActivityFeedViewController.h"
#import "TuduCache.h"
#import "TuduInviteDescriptionViewController.h"

@interface TuduAppDelegate () {
    NSMutableData *_data;
    BOOL firstLaunch;
}

@property (nonatomic, strong) TuduHomeViewController *homeViewController;
@property (nonatomic, strong) TuduActivityFeedViewController *activityViewController;
@property (nonatomic, strong) TuduWelcomeViewController *welcomeViewController;
@property (nonatomic, strong) TuduLoginViewController *loginViewController;
@property (nonatomic, strong) TuduSearchViewController *searchViewController;
@property (nonatomic, strong) TuduEventCreatorViewController *eventCreatorViewController;
@property (nonatomic, strong) TuduProfileViewController *profileViewController;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSTimer *autoFollowTimer;

- (void)setupAppearance;
- (BOOL)shouldProceedToMainInterface:(PFUser *)user;
- (BOOL)handleActionURL:(NSURL *)url;
@end

@implementation TuduAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    // ****************************************************************************
    // Parse credentials:
    [Parse setApplicationId:@"ndhiv6jPpnmaXQJnwRHYi0Lc4cMzFqZ8rt5F2fbc" clientKey:@"cD7r34xpm1F5rlFnb4a7JoWH4Yy4pEB8td0qu282"];
    //
    // If using Facebook, uncomment and add FacebookAppID to your bundle's plist as
    // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
    [PFFacebookUtils initializeFacebook];
    // ****************************************************************************

    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }
    
    [PFUser enableAutomaticUser];

    PFACL *defaultACL = [PFACL ACL];

    // If you would like all objects to be private by default, remove this line.
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // Set up our app's global UIAppearance
    [self setupAppearance];
    
    // Use Reachability to monitor connectivity
    //[self monitorReachability];
    
    self.welcomeViewController = [[TuduWelcomeViewController alloc] init];
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.welcomeViewController];
     
    /*
    self.loginViewController = [[TuduLoginViewController alloc] init];
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.loginViewController];
    */
    self.navController.navigationBarHidden = YES;
    
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];

    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                     UIRemoteNotificationTypeAlert |
                                                     UIRemoteNotificationTypeSound)];
    //[self handlePush:launchOptions];
    return YES;
}

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}

- (void)presentLoginViewControllerAnimated:(BOOL)animated {
    TuduLoginViewController *loginViewController = [[TuduLoginViewController alloc] init];
    // If TuduLogin extends PFLogin
    /*
    [loginViewController setDelegate:self];
    loginViewController.fields = (PFLogInFieldsUsernameAndPassword
    | PFLogInFieldsLogInButton
    | PFLogInFieldsSignUpButton
    | PFLogInFieldsPasswordForgotten
    | PFLogInFieldsDismissButton
    | PFLogInFieldsFacebook);
    //loginViewController.fields = PFLogInFieldsFacebook;
    loginViewController.facebookPermissions = @[ @"user_about_me" ];
     */
     //
    [self.navController pushViewController:loginViewController animated:YES];
    //[self.welcomeViewController presentViewController:loginViewController animated:NO completion:nil];
}

- (void)presentLoginViewController {
    [self presentLoginViewControllerAnimated:YES];
}

- (void)presentTabBarController {
    self.tabBarController = [[TuduTabBarController alloc] init];
    
    // Inititalize the 5 main ViewControllers that will be used when their TabBarItems are selected
    self.eventCreatorViewController = [[TuduEventCreatorViewController alloc] init];
    self.searchViewController = [[TuduSearchViewController alloc] init];
    self.profileViewController = [[TuduProfileViewController alloc] initWithUser:[PFUser currentUser]];
    self.homeViewController = [[TuduHomeViewController alloc] initWithStyle:UITableViewStylePlain];
    self.activityViewController = [[TuduActivityFeedViewController alloc] initWithUser:nil];
    [self.homeViewController setFirstLaunch:firstLaunch];
     
    
    // Make NavigationControllers that each of the respective ViewControllers above will be place in //tudu
    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
    UINavigationController *activityFeedNavigationController = [[UINavigationController alloc] initWithRootViewController:self.activityViewController];
    UINavigationController *searchNavigationController = [[UINavigationController alloc] initWithRootViewController:self.searchViewController];
    UINavigationController *profileNavigationController = [[UINavigationController alloc] initWithRootViewController:self.profileViewController];
    UINavigationController *eventCreatorNavigationController = [[UINavigationController alloc] initWithRootViewController:self.eventCreatorViewController];
    
    [Utility addBottomDropShadowToNavigationBarForNavigationController:homeNavigationController];
    [Utility addBottomDropShadowToNavigationBarForNavigationController:activityFeedNavigationController];
    [Utility addBottomDropShadowToNavigationBarForNavigationController:searchNavigationController];
    [Utility addBottomDropShadowToNavigationBarForNavigationController:profileNavigationController];
    [Utility addBottomDropShadowToNavigationBarForNavigationController:eventCreatorNavigationController];
    
    // "Home" TabBarItem
    UITabBarItem *homeTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Home", @"Home") image:[[UIImage imageNamed:@"IconHome.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"IconHomeSelected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [homeTabBarItem setTitleTextAttributes: @{ NSForegroundColorAttributeName: [UIColor colorWithRed:86.0f/255.0f green:55.0f/255.0f blue:42.0f/255.0f alpha:1.0f] } forState:UIControlStateNormal];
    [homeTabBarItem setTitleTextAttributes: @{ NSForegroundColorAttributeName: [UIColor colorWithRed:129.0f/255.0f green:99.0f/255.0f blue:69.0f/255.0f alpha:1.0f] } forState:UIControlStateSelected];
    
    // "ActivityFeed" TabBarItem
    UITabBarItem *activityFeedTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Activity", @"Activity") image:[[UIImage imageNamed:@"IconActivityTimeline.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"IconActivityTimelineSelected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [activityFeedTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor colorWithRed:86.0f/255.0f green:55.0f/255.0f blue:42.0f/255.0f alpha:1.0f] } forState:UIControlStateNormal];
    [activityFeedTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor colorWithRed:129.0f/255.0f green:99.0f/255.0f blue:69.0f/255.0f alpha:1.0f] } forState:UIControlStateSelected];
    
    // "Search" TabBarItem //tudu
    UITabBarItem *searchTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Search", @"Search") image:[[UIImage imageNamed:@"IconSearch.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"IconSearchSelected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [searchTabBarItem setTitleTextAttributes: @{ NSForegroundColorAttributeName: [UIColor colorWithRed:86.0f/255.0f green:55.0f/255.0f blue:42.0f/255.0f alpha:1.0f] } forState:UIControlStateNormal];
    [searchTabBarItem setTitleTextAttributes: @{ NSForegroundColorAttributeName: [UIColor colorWithRed:129.0f/255.0f green:99.0f/255.0f blue:69.0f/255.0f alpha:1.0f] } forState:UIControlStateSelected];
    
    // "Profile" TabBarItem //tudu
    UITabBarItem *profileTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Profile", @"Profile") image:[[UIImage imageNamed:@"IconProfile.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"IconProfileSelected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [profileTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor colorWithRed:86.0f/255.0f green:55.0f/255.0f blue:42.0f/255.0f alpha:1.0f] } forState:UIControlStateNormal];
    [profileTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor colorWithRed:129.0f/255.0f green:99.0f/255.0f blue:69.0f/255.0f alpha:1.0f] } forState:UIControlStateSelected];
    
    // "EventCreator" TabBarItem //tudu
    UITabBarItem *eventCreatorTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Create", @"Create") image:[[UIImage imageNamed:@"IconCreate.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"IconCreateSelected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [eventCreatorTabBarItem setTitleTextAttributes: @{ NSForegroundColorAttributeName: [UIColor colorWithRed:86.0f/255.0f green:55.0f/255.0f blue:42.0f/255.0f alpha:1.0f] } forState:UIControlStateNormal];
    [eventCreatorTabBarItem setTitleTextAttributes: @{ NSForegroundColorAttributeName: [UIColor colorWithRed:129.0f/255.0f green:99.0f/255.0f blue:69.0f/255.0f alpha:1.0f] } forState:UIControlStateSelected];
    
    
    [homeNavigationController setTabBarItem:homeTabBarItem];
    [activityFeedNavigationController setTabBarItem:activityFeedTabBarItem];
    [searchNavigationController setTabBarItem:searchTabBarItem]; //tudu
    [profileNavigationController setTabBarItem:profileTabBarItem]; //tudu
    [eventCreatorNavigationController setTabBarItem:eventCreatorTabBarItem]; //tudu
    
    // Add the navigation controllers, with their respective viewcontrollers in side them, to tab bar
    self.tabBarController.delegate = self;
    self.tabBarController.viewControllers = @[ eventCreatorNavigationController,
                                               searchNavigationController,
                                               homeNavigationController,
                                               activityFeedNavigationController,
                                               profileNavigationController ];
    
    // Make Home(EventFeed) the first selecte view that user sees
    [self.tabBarController setSelectedViewController:homeNavigationController];
    
    [self.navController setViewControllers:@[ /*self.welcomeViewController,*/ self.tabBarController ] animated:NO];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
    // Download user's profile picture
    
    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [[PFUser currentUser] objectForKey:kTuduUserFacebookIDKey]]];
    NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]; // Facebook profile picture cache policy: Expires in 2 weeks
    [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
    
}



- (void)logOut {
    // clear cache
    [[TuduCache sharedCache] clear];
    
    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTuduUserDefaultsCacheFacebookFriendsKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTuduUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Unsubscribe from push notifications by removing the user association from the current installation.
    [[PFInstallation currentInstallation] removeObjectForKey:kTuduInstallationUserKey];
    [[PFInstallation currentInstallation] saveInBackground];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // Log out
    [PFUser logOut];
    
    // clear out cached data, view controllers, etc
    [self.navController popToRootViewControllerAnimated:NO];
    
    [self presentLoginViewController];
    
    self.homeViewController = nil;
    self.activityViewController = nil;
    self.eventCreatorViewController = nil;
    self.searchViewController = nil;
    self.profileViewController = nil;
}






 - (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
 return [PFFacebookUtils handleOpenURL:url];
 }

//Parse
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}



/*
 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
 */
- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // Clear badge and update installation, required for auto-incrementing badges.
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }
    
    // Clears out all notifications from Notification Center.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;
    
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [[PFFacebookUtils session] close];
}

/*
 * Protocol delegate method of PFLogInViewController called if user was logged out previously
 */
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    NSLog(@"didLogInUser1");
    // user has logged in - we need to fetch all of their Facebook data before we let them in
    if (![self shouldProceedToMainInterface:user]) {
        //self.hud = [MBProgressHUD showHUDAddedTo:self.navController.presentedViewController.view animated:YES];
        //self.hud.labelText = NSLocalizedString(@"Loading", nil);
        //self.hud.dimBackground = YES;
    }
    NSLog(@"didLogInUser4");
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSLog(@"STORING CURRENT USER'S FACEBOOK ID");
            // Store the current user's Facebook ID on the user
            [[PFUser currentUser] setObject:[result objectForKey:@"id"]
                                     forKey:@"fbId"];
            [[PFUser currentUser] saveInBackground];

            
                // Parse the data received
                NSLog(@"PARSING DATA!");
                NSDictionary *userData = (NSDictionary *)result;
                
                NSString *facebookID = userData[@"id"];
                
                
                NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
                
                if (facebookID) {
                    userProfile[@"facebookId"] = facebookID;
                }
                
                NSString *name = userData[@"name"];
                if (name) {
                    NSLog([NSString stringWithFormat:@"%@/%@", @"---USERNAME IS:", name]);
                    userProfile[@"name"] = name;
                }
            NSLog(@"xxxxxxfacebookRequestDidLoad");
            [self facebookRequestDidLoad:result];
        } else {
            NSLog(@"xxxxxxfacebookRequestDidFailWithError");
            [self facebookRequestDidFailWithError:error];
        }
    }];
}

/*
 * Only proceeds if userHasValidFacebookData. This method also moves the view to the TabBarController
 */
- (BOOL)shouldProceedToMainInterface:(PFUser *)user {
    NSLog(@"shouldProceedToMainInterface2");
    if ([Utility userHasValidFacebookData:[PFUser currentUser]]) {
        //[MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
        [self presentTabBarController];
        [self.navController dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"shouldProceedToMainInterface3");
        return YES;
    }
    
    return NO;
}


/*
 * Called from didLogUserIn, when user tries to log in after having been logged out
 */
- (void)facebookRequestDidFailWithError:(NSError *)error {
    NSLog(@"Facebook error: %@", error);
    
    if ([PFUser currentUser]) {
        if ([[error userInfo][@"error"][@"type"] isEqualToString:@"OAuthException"]) {
            NSLog(@"The Facebook token was invalidated. Logging out.");
            [self logOut];
        }
    }
}


/*
 * Called from didLogUserIn, when user tries to log in after having been logged out
 */
- (void)facebookRequestDidLoad:(id)result {
    // This method is called twice - once for the user's /me profile, and a second time when obtaining their friends. We will try and handle both scenarios in a single method.
    PFUser *user = [PFUser currentUser];
    
    NSArray *data = [result objectForKey:@"data"];
    
    if (data) {
        NSLog(@"WE HAVE FRIENDS");
        // we have friends data
        NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:[data count]];
        for (NSDictionary *friendData in data) {
            if (friendData[@"id"]) {
                [facebookIds addObject:friendData[@"id"]];
            }
        }
        
        // cache friend data
        [[TuduCache sharedCache] setFacebookFriends:facebookIds];
        
        if (user) {
            if ([user objectForKey:kTuduUserFacebookFriendsKey]) {
                [user removeObjectForKey:kTuduUserFacebookFriendsKey];
            }
            
            if (![user objectForKey:kTuduUserAlreadyAutoFollowedFacebookFriendsKey]) {
                self.hud.labelText = NSLocalizedString(@"Following Friends", nil);
                firstLaunch = YES;
                
                [user setObject:@YES forKey:kTuduUserAlreadyAutoFollowedFacebookFriendsKey];
                NSError *error = nil;
                
                // find common Facebook friends already using Tudu
                PFQuery *facebookFriendsQuery = [PFUser query];
                [facebookFriendsQuery whereKey:kTuduUserFacebookIDKey containedIn:facebookIds];
                
                // auto-follow Parse employees
                PFQuery *parseEmployeesQuery = [PFUser query];
                [parseEmployeesQuery whereKey:kTuduUserFacebookIDKey containedIn:kTuduParseEmployeeAccounts];
                
                // combined query
                PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:parseEmployeesQuery,facebookFriendsQuery, nil]];
                
                NSArray *tuduFriends = [query findObjects:&error];
                
                if (!error) {
                    [tuduFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop) {
                        PFObject *joinActivity = [PFObject objectWithClassName:kTuduActivityClassKey];
                        [joinActivity setObject:user forKey:kTuduActivityFromUserKey];
                        [joinActivity setObject:newFriend forKey:kTuduActivityToUserKey];
                        [joinActivity setObject:kTuduActivityTypeJoined forKey:kTuduActivityTypeKey];
                        
                        PFACL *joinACL = [PFACL ACL];
                        [joinACL setPublicReadAccess:YES];
                        joinActivity.ACL = joinACL;
                        
                        // make sure our join activity is always earlier than a follow
                        [joinActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [Utility followUserInBackground:newFriend block:^(BOOL succeeded, NSError *error) {
                                // This block will be executed once for each friend that is followed.
                                // We need to refresh the timeline when we are following at least a few friends
                                // Use a timer to avoid refreshing innecessarily
                                if (self.autoFollowTimer) {
                                    [self.autoFollowTimer invalidate];
                                }
                                
                                self.autoFollowTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(autoFollowTimerFired:) userInfo:nil repeats:NO];
                            }];
                        }];
                    }];
                }
                
                if (![self shouldProceedToMainInterface:user]) {
                    [self logOut];
                    return;
                }
                
                if (!error) {
                    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:NO];
                    if (tuduFriends.count > 0) {
                        self.hud = [MBProgressHUD showHUDAddedTo:self.homeViewController.view animated:NO];
                        self.hud.dimBackground = YES;
                        self.hud.labelText = NSLocalizedString(@"Following Friends", nil);
                    } else {
                        [self.homeViewController loadObjects];
                    }
                }
            }
            
            [user saveEventually];
        } else {
            NSLog(@"No user session found. Forcing logOut.");
            [self logOut];
        }
    } else {
        self.hud.labelText = NSLocalizedString(@"Creating Profile", nil);
        
        if (user) {
            NSString *facebookName = result[@"name"];
            if (facebookName && [facebookName length] != 0) {
                [user setObject:facebookName forKey:kTuduUserDisplayNameKey];
            } else {
                [user setObject:@"Someone" forKey:kTuduUserDisplayNameKey];
            }
            
            NSString *facebookId = result[@"id"];
            if (facebookId && [facebookId length] != 0) {
                [user setObject:facebookId forKey:kTuduUserFacebookIDKey];
            }
            
            [user saveEventually];
        }
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self facebookRequestDidLoad:result];
            } else {
                [self facebookRequestDidFailWithError:error];
            }
        }];
    }
}


- (void)monitorReachability {
    Reachability *hostReach = [Reachability reachabilityWithHostname:@"api.parse.com"];
    
    hostReach.reachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
        
        if ([self isParseReachable] && [PFUser currentUser] && self.homeViewController.objects.count == 0) {
            // Refresh home timeline on network restoration. Takes care of a freshly installed app that failed to load the main timeline under bad network conditions.
            // In this case, they'd see the empty timeline placeholder and have no way of refreshing the timeline unless they followed someone.
            [self.homeViewController loadObjects];
        }
    };
    
    hostReach.unreachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
    };
    
    [hostReach startNotifier];
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [Utility processFacebookProfilePictureData:_data];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    [PFPush storeDeviceToken:newDeviceToken];
    [PFPush subscribeToChannelInBackground:@"" target:self selector:@selector(subscribeFinished:error:)];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

- (void)setupAppearance {
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    /*
     NSShadow *shadow = [[NSShadow alloc] init];
     shadow.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.750f];
     shadow.shadowOffset = CGSizeMake(0.0f, 1.0f);
     
     [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.498f green:0.388f blue:0.329f alpha:1.0f]];
     [[UINavigationBar appearance] setTitleTextAttributes:@{
     NSForegroundColorAttributeName: [UIColor whiteColor],
     NSShadowAttributeName: shadow
     }];
     
     [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"BackgroundNavigationBar.png"]
     forBarMetrics:UIBarMetricsDefault];
     
     [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0f]
     forState:UIControlStateNormal];
     
     [[UIBarButtonItem appearance] setTitleTextAttributes:@{
     NSForegroundColorAttributeName:
     [UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0f],
     NSShadowAttributeName: shadow
     }
     forState:UIControlStateNormal];
     */
    
    [[UISearchBar appearance] setTintColor:[UIColor colorWithRed:32.0f/255.0f green:19.0f/255.0f blue:16.0f/255.0f alpha:1.0f]];
}


#pragma mark - ()

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error {
    if ([result boolValue]) {
        NSLog(@"ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
    } else {
        NSLog(@"ParseStarterProject failed to subscribe to push notifications on the broadcast channel.");
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state.
     This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
     or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates.
     Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state
     information to restore your application to its current state in case it is terminated later.
     If your application supports background execution,
     this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}




- (BOOL)handleActionURL:(NSURL *)url {
    /*
     if ([[url host] isEqualToString:kPAPLaunchURLHostTakePicture]) {
     if ([PFUser currentUser]) {
     return [self.tabBarController shouldPresentPhotoCaptureController];
     }
     } else {
     if ([[url fragment] rangeOfString:@"^pic/[A-Za-z0-9]{10}$" options:NSRegularExpressionSearch].location != NSNotFound) {
     NSString *photoObjectId = [[url fragment] substringWithRange:NSMakeRange(4, 10)];
     if (photoObjectId && photoObjectId.length > 0) {
     [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kPAPPhotoClassKey objectId:photoObjectId]];
     return YES;
     }
     }
     }
     
     return NO;
     */
    return YES;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Uncomment this method if using Facebook ///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 - (BOOL)application:(UIApplication *)application
 openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
 annotation:(id)annotation {
 return [PFFacebookUtils handleOpenURL:url];
 }*/

/*
 // Tudu
 - (BOOL)application:(UIApplication *)application
 openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
 annotation:(id)annotation {
 if ([self handleActionURL:url]) {
 return YES;
 }
 
 return [FBAppCall handleOpenURL:url
 sourceApplication:sourceApplication
 withSession:[PFFacebookUtils session]];
 }*/
/*
- (void)handlePush:(NSDictionary *)launchOptions {
 
    // If the app was launched in response to a push notification, we'll handle the payload here
    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationPayload) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TuduAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:remoteNotificationPayload];
        
        if (![PFUser currentUser]) {
            return;
        }
        
        // If the push notification payload references a photo, we will attempt to push this view controller into view
        NSString *photoObjectId = [remoteNotificationPayload objectForKey:kTuduPushPayloadPhotoObjectIdKey];
        if (photoObjectId && photoObjectId.length > 0) {
            [self shouldNavigateToEvent:[PFObject objectWithoutDataWithClassName:kTuduEventClassKey objectId:photoObjectId]];
            return;
        }
        
        // If the push notification payload references a user, we will attempt to push their profile into view
        NSString *fromObjectId = [remoteNotificationPayload objectForKey:kTuduPushPayloadFromUserObjectIdKey];
        if (fromObjectId && fromObjectId.length > 0) {
            PFQuery *query = [PFUser query];
            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
            [query getObjectInBackgroundWithId:fromObjectId block:^(PFObject *user, NSError *error) {
                if (!error) {
                    UINavigationController *homeNavigationController = self.tabBarController.viewControllers[TuduHomeTabBarItemIndex];
                    self.tabBarController.selectedViewController = homeNavigationController;
                
                    TuduProfileViewController *profileViewController = [[TuduProfileViewController alloc] init];
                    profileViewController.user = (PFUser *)user;
                    [homeNavigationController pushViewController:profileViewController animated:YES];
                }
            }];
        }
    }
}
*/



@end
