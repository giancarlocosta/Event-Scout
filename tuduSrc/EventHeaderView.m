//
//  EventHeaderView.m
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//

#import <Parse/Parse.h>

#import "EventHeaderView.h"
#import "TuduProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "Utility.h"
#import "Constants.h"

@interface EventHeaderView ()

@end


@implementation EventHeaderView
@synthesize containerView;
@synthesize avatarImageView;
@synthesize userButton;
@synthesize timestampLabel;
@synthesize timeIntervalFormatter;
@synthesize event;
@synthesize buttons;
@synthesize delegate;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame buttons:(EventHeaderButtons)otherButtons {
    self = [super initWithFrame:frame];
    if (self) {
        [EventHeaderView validateButtons:otherButtons];
        buttons = otherButtons;
        
        self.clipsToBounds = NO;
        self.containerView.clipsToBounds = NO;
        self.superview.clipsToBounds = NO;
        //[self setBackgroundColor:[UIColor redColor]];
        
        // translucent portion
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.bounds.size.width/*self.bounds.size.width - 20.0f * 2.0f*/, self.bounds.size.height)];
        [self addSubview:self.containerView];
        [self.containerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundComments.png"]]];
        
        
        self.avatarImageView = [[TuduProfileImageView alloc] init];
        self.avatarImageView.frame = CGRectMake( 4.0f, 4.0f, 35.0f, 35.0f);
        //self.avatarImageView = [UIImage imageNamed:@"AvatarPlaceholder.png"];
        [self.avatarImageView.profileButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:self.avatarImageView];
        
        
        if (self.buttons & EventHeaderButtonsUser) {
            // This is the user's display name, on a button so that we can tap on it
            self.userButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView addSubview:self.userButton];
            [self.userButton setBackgroundColor:[UIColor clearColor]];
            [[self.userButton titleLabel] setFont:[UIFont boldSystemFontOfSize:15]];
            [self.userButton setTitleColor:[UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [self.userButton setTitleColor:[UIColor colorWithRed:134.0f/255.0f green:100.0f/255.0f blue:65.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
            [[self.userButton titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
            [[self.userButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
            [self.userButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f] forState:UIControlStateNormal];
        }
        
        self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        
        // timestamp
        self.timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake( 50.0f, 24.0f, containerView.bounds.size.width - 50.0f - 72.0f, 18.0f)];
        [containerView addSubview:self.timestampLabel];
        [self.timestampLabel setTextColor:[UIColor colorWithRed:124.0f/255.0f green:124.0f/255.0f blue:124.0f/255.0f alpha:1.0f]];
        [self.timestampLabel setShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f]];
        [self.timestampLabel setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
        [self.timestampLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [self.timestampLabel setBackgroundColor:[UIColor clearColor]];
        
        
        CALayer *layer = [containerView layer];
        layer.backgroundColor = [[UIColor whiteColor] CGColor];
         /*
        layer.masksToBounds = NO;
        layer.shadowRadius = 1.0f;
        layer.shadowOffset = CGSizeMake( 0.0f, 2.0f);
        layer.shadowOpacity = 0.5f;
        layer.shouldRasterize = YES;
        layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake( 0.0f, containerView.frame.size.height - 4.0f, containerView.frame.size.width, 4.0f)].CGPath;
         */
    }
    
    return self;
}


#pragma mark - EventHeaderView

- (void)setTheEvent:(PFObject *)theEvent {
    //NSLog(@"----IN SET EVENT: %@", theEvent[@"title"]);
    self.event = theEvent;
    
    //[query includeKey:kTuduEventUserKey];
    PFUser *user = [self.event objectForKey:kTuduEventUserKey];
    //NSLog(@"User's displayName: %@", user[@"displayName"]);
    /*
    PFFile *profilePictureSmall = [user objectForKey:kTuduUserProfilePicSmallKey];
    if(profilePictureSmall){
        [self.avatarImageView setFile:profilePictureSmall];
    }
     */
    
    NSString *authorName = [user objectForKey:kTuduUserDisplayNameKey];
    [self.userButton setTitle:authorName forState:UIControlStateNormal];
    
    CGFloat constrainWidth = containerView.bounds.size.width;
    
    if (self.buttons & EventHeaderButtonsUser) {
        [self.userButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // we resize the button to fit the user's name to avoid having a huge touch area
    CGPoint userButtonPoint = CGPointMake(50.0f, 6.0f);
    constrainWidth -= userButtonPoint.x;
    CGSize constrainSize = CGSizeMake(constrainWidth, containerView.bounds.size.height - userButtonPoint.y*2.0f);
    
    CGSize userButtonSize = [self.userButton.titleLabel.text boundingRectWithSize:constrainSize
                                                                          options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                                       attributes:@{NSFontAttributeName:self.userButton.titleLabel.font}
                                                                          context:nil].size;
    
    CGRect userButtonFrame = CGRectMake(userButtonPoint.x, userButtonPoint.y, userButtonSize.width, userButtonSize.height);
    [self.userButton setFrame:userButtonFrame];
    
    NSTimeInterval timeInterval = [[self.event createdAt] timeIntervalSinceNow];
    NSString *timestamp = [self.timeIntervalFormatter stringForTimeInterval:timeInterval];
    [self.timestampLabel setText:timestamp];
    
    [self setNeedsDisplay];
}


#pragma mark - ()

+ (void)validateButtons:(EventHeaderButtons)buttons {
    if (buttons == EventHeaderButtonsNone) {
        [NSException raise:NSInvalidArgumentException format:@"Buttons must be set before initializing PAPPhotoHeaderView."];
    }
}

- (void)didTapUserButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(eventHeaderView:didTapUserButton:user:)]) {
        PFUser *theUser = [self.event objectForKey:kTuduEventUserKey];
        [delegate eventHeaderView:self didTapUserButton:sender user:theUser];
    }
}

@end

