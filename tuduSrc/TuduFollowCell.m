//
//  TuduFollowCell.m
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//

#import "TuduFollowCell.h"
#import "TuduFriendSelectorCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "TuduProfileImageView.h"
#import "TuduFriendsListViewController.h"

//static TTTTimeIntervalFormatter *timeFormatter;

@interface TuduFollowCell ()

/*! Static helper method to calculate the space available for text given images and insets */
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth;

@end

@implementation TuduFollowCell


#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Create subviews and set cell properties
        self.opaque = YES;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.followButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        self.followButton.titleEdgeInsets = UIEdgeInsetsMake( 0.0f, 10.0f, 0.0f, 0.0f);
        [self.followButton setBackgroundImage:[UIImage imageNamed:@"ButtonFollow.png"]
                                     forState:UIControlStateNormal];
        [self.followButton setBackgroundImage:[UIImage imageNamed:@"ButtonFollowing.png"]
                                     forState:UIControlStateSelected];
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
        [self.mainView addSubview:self.followButton];
    }
    return self;
}

- (void)setUser:(PFUser *)aUser {
    [super setUser:aUser];
    
    // Set follow button
    [self.followButton setFrame:CGRectMake( 208.0f, 20.0f, 103.0f, 32.0f)];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Do layout work here
}

// Since we remove the compile-time check for the delegate conforming to the protocol
// in order to allow inheritance, we add run-time checks.
- (id<TuduFollowCellDelegate>)delegate {
    return (id<TuduFollowCellDelegate>)_delegate;
}

- (void)setDelegate:(id<TuduFollowCellDelegate>)delegate {
    if(_delegate != delegate) {
        _delegate = delegate;
    }
}

- (void)didTapFollowButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapFollowButton:)]) {
        [self.delegate cell:self didTapFollowButton:self.user];
    }
}

@end

