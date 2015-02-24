//
//  TuduLoginViewController.m
//  tudu
//
//  Created by Gian Costa on 9/1/14.
//
//

#import "TuduLoginViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "TuduAppDelegate.h"

@interface TuduLoginViewController ()

@end

@implementation TuduLoginViewController
@synthesize loginButton;

- (void)viewDidLoad {
    [super viewDidLoad];

    //See if you can skip to the TabBarHome
    if ([PFUser currentUser] && // Check if user is cached
        [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) { // Check if user is linked to Facebook
        NSLog(@"Already linked to FB");
        [(TuduAppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
    }
    
    // There is no documentation on how to handle assets with the taller iPhone 5 screen as of 9/13/2012
    /*
    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        // for the iPhone 5
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLogin-568h.png"]];
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLogin.png"]];
    }*/
    
    NSString *text = NSLocalizedString(@"Sign up and start sharing your story with your friends.", @"Sign up and start sharing your story with your friends.");
    
    CGSize textSize = [text boundingRectWithSize:CGSizeMake(255.0f, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin // wordwrap?
                                      attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0f]}
                                         context:nil].size;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake( ([UIScreen mainScreen].bounds.size.width - textSize.width)/2.0f, 160.0f, textSize.width, textSize.height)];
    [textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0f]];
    [textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [textLabel setNumberOfLines:0];
    [textLabel setText:text];
    [textLabel setTextColor:[UIColor colorWithRed:214.0f/255.0f green:206.0f/255.0f blue:191.0f/255.0f alpha:1.0f]];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setTextAlignment:NSTextAlignmentCenter];

    self.loginButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, 100.0f, 200.0f, 20.0f) ];
                        [self.loginButton addTarget:self
                                             action:@selector(loginButtonTouchHandler:)
                                   forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.loginButton setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:textLabel];
    [self.view addSubview:self.loginButton];
     

}
-(void)loginButtonTouchHandler : (id)sender {
    [PFUser logInWithUsernameInBackground:@"gcosta" password:@"userPass"
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            // Do stuff after successful login.
                                            NSLog(@"Login SUCCESS");
                                            [(TuduAppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
                                        } else {
                                            // The login failed. Check error to see why.
                                            NSLog(@"Login FAILED");
                                        }
                                    }];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


// IF YOU EXTENDING PFLogInViewController
/*
 [self.logInView setLogo:nil];
 [self.logInView addSubview:textLabel];
 
 self.signUpController.fields = (PFSignUpFieldsUsernameAndPassword
 | PFSignUpFieldsSignUpButton
 | PFSignUpFieldsDismissButton);
 //self.fields = PFLogInFieldsUsernameAndPassword;
 self.fields = (PFLogInFieldsUsernameAndPassword
 | PFLogInFieldsLogInButton
 | PFLogInFieldsSignUpButton
 | PFLogInFieldsPasswordForgotten
 | PFLogInFieldsDismissButton);
 self.logInView.usernameField.placeholder = @"Enter your email";
 */
//


/*USED TO FIND FRIENDS OF CURRENT USER. IMPORTANT INFO ABOUT WHY friendObjects may be empty: user_friends permission "Provides
 acesss the list of friends that ALSO USE YOUR APP"
 
 // Issue a Facebook Graph API request to get your user's friend list
 [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
 if (!error) {
 NSLog(@"------Successfully FINDING FRIENDS!----");
 // result will contain an array with your user's friends in the "data" key
 NSArray *friendObjects = [result objectForKey:@"data"];
 NSLog(@"-----FOUND %i FRIENDS", [friendObjects count]);
 NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
 // Create a list of friends' Facebook IDs
 for (NSDictionary *friendObject in friendObjects) {
 [friendIds addObject:[friendObject objectForKey:@"id"]];
 }
 
 // Construct a PFUser query that will find friends whose facebook ids
 // are contained in the current user's friend list.
 PFQuery *friendQuery = [PFUser query];
 [friendQuery whereKey:@"fbId" containedIn:friendIds];
 
 // findObjects will return a list of PFUsers that are friends
 // with the current user
 NSArray *friendUsers = [friendQuery findObjects];
 }
 }];
 */

@end
