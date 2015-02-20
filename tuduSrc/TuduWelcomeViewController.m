//
//  TuduWelcomeViewController.m
//  tudu
//
//  Created by Gian Costa on 9/1/14.
//
//
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "TuduWelcomeViewController.h"
#import "TuduAppDelegate.h"

@interface TuduWelcomeViewController ()

@end

@implementation TuduWelcomeViewController

#pragma mark - UIViewController
- (void)loadView {
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [backgroundImageView setImage:[UIImage imageNamed:@"Default.png"]];
    self.view = backgroundImageView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // If not logged in, present login view controller
    if (![PFUser currentUser]) {
        [(TuduAppDelegate*)[[UIApplication sharedApplication] delegate] presentLoginViewControllerAnimated:NO];
        return;
    }
    
    // Present Anypic UI
    if ([PFUser currentUser] && // Check if user is cached
        [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) { // Check if user is linked to Facebook
        NSLog(@"Already linked to FB");
        // Skip to home TabBar
        [(TuduAppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
    }
    else {
        // Refresh current user with server side data -- checks if user is still valid and so on
        [[PFUser currentUser] refreshInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
    }
}


#pragma mark - ()

- (void)refreshCurrentUserCallbackWithResult:(PFObject *)refreshedObject error:(NSError *)error {
    
    // A kPFErrorObjectNotFound error on currentUser refresh signals a deleted user
    if (error && error.code == kPFErrorObjectNotFound) {
        NSLog(@"User does not exist.");
        [(TuduAppDelegate*)[[UIApplication sharedApplication] delegate] logOut];
        return;
    }
    
    // Check if user is missing a Facebook ID
    if ([Utility userHasValidFacebookData:[PFUser currentUser]]) {
        // User has Facebook ID.
        
        // refresh Facebook friends on each launch
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(facebookRequestDidLoad:)]) {
                    [[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidLoad:) withObject:result];
                }
            } else {
                if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(facebookRequestDidFailWithError:)]) {
                    [[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidFailWithError:) withObject:error];
                }
            }
        }];
    } else { // User does not have Facebook ID.
        NSLog(@"Current user is missing their Facebook ID");
        //////
        [(TuduAppDelegate*)[[UIApplication sharedApplication] delegate] presentLoginViewControllerAnimated:NO];
        return;
        //////
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSLog(@"------NO ERROR");
                if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(facebookRequestDidLoad:)]) {
                    [[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidLoad:) withObject:result];
                }
            } else {
                NSLog(@"YES ERROR");
                if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(facebookRequestDidFailWithError:)]) {
                    [[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidFailWithError:) withObject:error];
                }
            }
        }];
    }
    
}

@end
