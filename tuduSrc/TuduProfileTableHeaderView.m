//
//  EventHeaderView.m
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//

#import <Parse/Parse.h>

#import "TuduProfileTableHeaderView.h"
#import "TuduProfileImageView.h"
#import "TuduNumberTitleButton.h"
#import "TTTTimeIntervalFormatter.h"
#import "TuduProfileViewController.h"
#import "UIImage+ImageEffects.h"
#import "Utility.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>

@interface TuduProfileTableHeaderView ()

@end


@implementation TuduProfileTableHeaderView
@synthesize avatarImageView;
@synthesize delegate;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame user:(PFUser *)user{
    self = [super initWithFrame:frame];
    if (self) {
        self.user = user;
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.coreInfoContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 250)];
        self.coreInfoContainer.backgroundColor = [UIColor colorWithRed:0.82 green:0.98 blue:0.93 alpha:1];

        [self setupUserPicAndDisplayName];
        [self setupFollowInfoLists];
        [self setupFollowButton];
        [self setupButtonPanel];
        
        [self addSubview:self.coreInfoContainer];
        [self addSubview:self.followButton];
        [self addSubview:self.buttonPanelContainer];
    }
    return self;
}


-(void)setupUserPicAndDisplayName {
    UIView *profilePictureBackgroundView = [[UIView alloc] initWithFrame:CGRectMake( 94.0f, 30.0f, 132.0f, 132.0f)];
    [profilePictureBackgroundView setBackgroundColor:[UIColor darkGrayColor]];
    profilePictureBackgroundView.alpha = 0.0f;
    CALayer *layer = [profilePictureBackgroundView layer];
    layer.cornerRadius = 65.0f;
    layer.shadowOffset = CGSizeMake(4.0, 4.0);
    layer.borderColor = (__bridge CGColorRef)([ThemeAndStyle salmonColor]);
    layer.borderWidth = 2.0f;
    layer.masksToBounds = YES;
    //[self addSubview:profilePictureBackgroundView];
    [self.coreInfoContainer addSubview:profilePictureBackgroundView];
    
    PFImageView *profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake( 94.0f, 30.0f, 132.0f, 132.0f)];
    [self.coreInfoContainer addSubview:profilePictureImageView];
    [profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
    layer = [profilePictureImageView layer];
    layer.cornerRadius = 65.0f;
    layer.borderColor = (__bridge CGColorRef)([ThemeAndStyle salmonColor]);
    layer.shadowOffset = CGSizeMake(4.0, 4.0);
    layer.borderWidth = 2.0f;
    layer.masksToBounds = YES;
    profilePictureImageView.alpha = 0.0f;
    UIImageView *profilePictureStrokeImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 88.0f, 26.0f, 143.0f, 143.0f)];
    profilePictureStrokeImageView.alpha = 0.0f;
    [profilePictureStrokeImageView setImage:[UIImage imageNamed:@"ProfilePictureStroke.png"]];
    [self.coreInfoContainer addSubview:profilePictureStrokeImageView];
    
    
    PFFile *imageFile = [self.user objectForKey:kTuduUserProfilePicMediumKey];
    if (imageFile) {
        [profilePictureImageView setFile:imageFile];
        [profilePictureImageView loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                [UIView animateWithDuration:0.2f animations:^{
                    profilePictureBackgroundView.alpha = 1.0f;
                    profilePictureStrokeImageView.alpha = 1.0f;
                    profilePictureImageView.alpha = 1.0f;
                }];
                
                /*
                 UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[image applyLightEffect]];
                 backgroundImageView.frame = self.frame;
                 backgroundImageView.alpha = 0.0f;
                 [self addSubview:backgroundImageView];
                 
                 [UIView animateWithDuration:0.2f animations:^{
                 backgroundImageView.alpha = 1.0f;
                 }];
                 */
            }
        }];
    }
    
    self.userDisplayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, profilePictureImageView.frame.origin.y + profilePictureImageView.frame.size.height + 5, self.coreInfoContainer.frame.size.width, 22.0f)];
    [self.userDisplayNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.userDisplayNameLabel setBackgroundColor:[UIColor clearColor]];
    [self.userDisplayNameLabel setTextColor:[UIColor blackColor]];
    [self.userDisplayNameLabel setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.300f]];
    [self.userDisplayNameLabel setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
    [self.userDisplayNameLabel setText:[self.user objectForKey:@"displayName"]];
    [self.userDisplayNameLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    
    [self.coreInfoContainer addSubview:self.userDisplayNameLabel];
}


-(void)setupFollowInfoLists {
    self.followListsContainer = [[UIView alloc] initWithFrame:CGRectMake(40.0f, self.coreInfoContainer.frame.size.height - 40,
                                                                         self.coreInfoContainer.frame.size.width - 2*(40), 40)];
    
    // Following List Button
    self.followingButton = [[TuduNumberTitleButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                                   0.0f,
                                                                                   self.followListsContainer.frame.size.width/2,
                                                                                   self.followListsContainer.frame.size.height)];
    [self.followingButton addTarget:self action:@selector(didTapFollowingButton:) forControlEvents:UIControlEventTouchUpInside];
    //[self.followingButton.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    //[self.followingButton.layer setBorderWidth:1.0f];
    [self.followingButton setSelected:NO];
    [self.followingButton setButtonTitleValue:@"FOLLOWING"];
    [self.followingButton setButtonNumberValue:[[TuduCache sharedCache] attendCountForEvent:self.user]];
    
    // Followers List Button
    self.followersButton = [[TuduNumberTitleButton alloc] initWithFrame:CGRectMake(self.followListsContainer.frame.size.width/2,
                                                                                   0.0f,
                                                                                   self.followListsContainer.frame.size.width/2,
                                                                                   self.followListsContainer.frame.size.height)];
    [self.followersButton addTarget:self action:@selector(didTapFollowersButton:) forControlEvents:UIControlEventTouchUpInside];
    //[self.followersButton.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    //[self.followersButton.layer setBorderWidth:1.0f];
    [self.followersButton setSelected:NO];
    [self.followersButton setButtonTitleValue:@"FOLLOWERS"];
    [self.followersButton setButtonNumberValue:[[TuduCache sharedCache] inviteCountForEvent:self.user]];
    
    [self.followListsContainer addSubview:self.followingButton];
    [self.followListsContainer addSubview:self.followersButton];

    [self.coreInfoContainer addSubview:self.followListsContainer];
}


-(void)setupFollowButton {
    self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.followButton.frame = CGRectMake(40.0f, self.coreInfoContainer.frame.origin.y + self.coreInfoContainer.frame.size.height + 5,
                                         self.frame.size.width - 2*(40), 40);
    self.followButton.layer.cornerRadius = 5.0f;
    self.followButton.layer.borderColor = [ThemeAndStyle blueGrayColor].CGColor;
    self.followButton.layer.borderWidth = 1.0f;
    self.followButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    self.followButton.titleEdgeInsets = UIEdgeInsetsMake( 0.0f, 10.0f, 0.0f, 0.0f);
    //[self.followButton setBackgroundImage:[UIImage imageNamed:@"ButtonFollow.png"] forState:UIControlStateNormal];
    //[self.followButton setBackgroundImage:[UIImage imageNamed:@"ButtonFollowing.png"] forState:UIControlStateSelected];
    [self.followButton setImage:[UIImage imageNamed:@"IconTick.png"]
                       forState:UIControlStateSelected];
    [self.followButton setTitle:NSLocalizedString(@"Follow  ", @"Follow string, with spaces added for centering")
                       forState:UIControlStateNormal];
    [self.followButton setTitle:@"Following"
                       forState:UIControlStateSelected];
    [self.followButton setTitleColor:[UIColor colorWithRed:84.0f/255.0f green:57.0f/255.0f blue:45.0f/255.0f alpha:1.0f]
                            forState:UIControlStateNormal];
    [self.followButton setTitleColor:[UIColor whiteColor]
                            forState:UIControlStateSelected];
    [self.followButton setTitleShadowColor:[UIColor colorWithRed:232.0f/255.0f green:203.0f/255.0f blue:168.0f/255.0f alpha:1.0f]
                                  forState:UIControlStateNormal];
    [self.followButton setTitleShadowColor:[UIColor blackColor]
                                  forState:UIControlStateSelected];
    self.followButton.titleLabel.shadowOffset = CGSizeMake( 0.0f, -1.0f);
    [self.followButton addTarget:self action:@selector(didTapFollowButton:)
                forControlEvents:UIControlEventTouchUpInside];
    self.followButton.selected = NO;
}


-(void)setupButtonPanel {
    self.buttonPanelContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 40,
                                                                         self.frame.size.width, 40)];
    
    // HOSTING Button
    self.hostingEventsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.hostingEventsButton.frame = CGRectMake(0.0f, 0.0f, self.buttonPanelContainer.frame.size.width/4, self.buttonPanelContainer.frame.size.height);
    [self.hostingEventsButton setTitle:@"Hosting" forState:UIControlStateNormal];
    [self.hostingEventsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.hostingEventsButton setTitleColor:[ThemeAndStyle salmonColor] forState:UIControlStateSelected];
    [self.hostingEventsButton.titleLabel setFont:[UIFont fontWithName:[ThemeAndStyle buttonFont] size:12.0f]];
    [self.hostingEventsButton.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [self.hostingEventsButton.layer setBorderWidth:1.0f];
    [self.hostingEventsButton addTarget:self action:@selector(didTapHostingEventsButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.hostingEventsButton setSelected:NO];
    
    
    // ATTENDING Button
    self.attendingEventsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.attendingEventsButton.frame = CGRectMake(self.buttonPanelContainer.frame.size.width/4,
                                                  0.0f, self.buttonPanelContainer.frame.size.width/4, self.buttonPanelContainer.frame.size.height);
    [self.attendingEventsButton setTitle:@"Attending" forState:UIControlStateNormal];
    [self.attendingEventsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.attendingEventsButton setTitleColor:[ThemeAndStyle salmonColor] forState:UIControlStateSelected];
    [self.attendingEventsButton.titleLabel setFont:[UIFont fontWithName:[ThemeAndStyle buttonFont] size:12.0f]];
    [self.attendingEventsButton.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [self.attendingEventsButton.layer setBorderWidth:1.0f];
    [self.attendingEventsButton addTarget:self action:@selector(didTapAttendingEventsButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.attendingEventsButton setSelected:NO];
    
    self.button3 = [[UIButton alloc] initWithFrame:CGRectMake(self.buttonPanelContainer.frame.size.width/2,
                                                              0.0f,
                                                              self.buttonPanelContainer.frame.size.width/4,
                                                              self.buttonPanelContainer.frame.size.height)];
    [self.button3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.button3 setTitleColor:[ThemeAndStyle salmonColor] forState:UIControlStateSelected];
    [self.button3.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [self.button3.layer setBorderWidth:1.0f];
    [self.button3 setSelected:NO];
    
    self.button4 = [[UIButton alloc] initWithFrame:CGRectMake(self.buttonPanelContainer.frame.size.width/2 + self.buttonPanelContainer.frame.size.width/4,
                                                              0.0f,
                                                              self.buttonPanelContainer.frame.size.width/4,
                                                              self.buttonPanelContainer.frame.size.height)];
    [self.button4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.button4 setTitleColor:[ThemeAndStyle salmonColor] forState:UIControlStateSelected];
    [self.button4.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [self.button4.layer setBorderWidth:1.0f];
    [self.button4 setSelected:NO];
    
    [self.buttonPanelContainer addSubview:self.hostingEventsButton];
    [self.buttonPanelContainer addSubview:self.attendingEventsButton];
    [self.buttonPanelContainer addSubview:self.button3];
    [self.buttonPanelContainer addSubview:self.button4];
}


/*
 * Button Listeners
 *
 *
 */
- (void)didTapFollowButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(profileHeaderView:didTapFollowButton:user:)]) {
        [self.delegate profileHeaderView:self didTapFollowButton:self.followButton user:self.user];
    }
}


- (void)didTapFollowersButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(profileHeaderView:didTapFollowersButton:user:)]) {
        [self.delegate profileHeaderView:self didTapFollowersButton:self.followersButton user:self.user];
    }
}


- (void)didTapFollowingButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(profileHeaderView:didTapFollowingButton:user:)]) {
        [self.delegate profileHeaderView:self didTapFollowingButton:self.followingButton user:self.user];
    }
}


- (void)didTapHostingEventsButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(profileHeaderView:didTapSeeHostingEventsButton:user:)]) {
        [self.delegate profileHeaderView:self didTapSeeHostingEventsButton:self.hostingEventsButton user:self.user];
    }
}

- (void)didTapAttendingEventsButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(profileHeaderView:didTapSeeAttendingEventsButton:user:)]) {
        [self.delegate profileHeaderView:self didTapSeeAttendingEventsButton:self.attendingEventsButton user:self.user];
    }
}

- (void)setSelectedButton:(UIButton *)selectedButton {
    for (UIButton *b in self.buttonPanelContainer.subviews) {
        if([b isEqual:selectedButton])
            [b setSelected:YES];
        else
            [b setSelected:NO];
    }
}

@end