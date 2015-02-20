//
//  TuduInviteCell.m
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//

#import "TuduInviteCell.h"
#import "TuduProfileImageView.h"
//#import "TTTTimeIntervalFormatter.h"
//#import "PAPActivityFeedViewController.h"
//static TTTTimeIntervalFormatter *timeFormatter;

@interface TuduInviteCell ()

/*! Static helper method to calculate the space available for text given images and insets */
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth;

@end

@implementation TuduInviteCell


#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Create subviews and set cell properties
        self.opaque = YES;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        self.inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.inviteButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        self.inviteButton.titleEdgeInsets = UIEdgeInsetsMake( 0.0f, 10.0f, 0.0f, 0.0f);
        [self.inviteButton setBackgroundImage:[UIImage imageNamed:@"ButtonInvite.png"]
                                     forState:UIControlStateNormal];
        [self.inviteButton setBackgroundImage:[UIImage imageNamed:@"ButtonInvited.png"]
                                     forState:UIControlStateSelected];
        [self.inviteButton setImage:[UIImage imageNamed:@"IconTick.png"]
                           forState:UIControlStateSelected];
        [self.inviteButton setTitle:NSLocalizedString(@"Invite  ", @"Invite string, with spaces added for centering")
                           forState:UIControlStateNormal];
        [self.inviteButton setTitle:@"Invited"
                           forState:UIControlStateSelected];
        [self.inviteButton setTitleColor:[UIColor whiteColor]
                                forState:UIControlStateNormal];
        [self.inviteButton setTitleColor:[UIColor whiteColor]
                                forState:UIControlStateSelected];
        [self.inviteButton setTitleShadowColor:[UIColor colorWithRed:232.0f/255.0f green:203.0f/255.0f blue:168.0f/255.0f alpha:1.0f]
                                      forState:UIControlStateNormal];
        [self.inviteButton setTitleShadowColor:[UIColor blackColor]
                                      forState:UIControlStateSelected];
        self.inviteButton.titleLabel.shadowOffset = CGSizeMake( 0.0f, -1.0f);
        [self.inviteButton addTarget:self action:@selector(didTapInviteButton:)
                    forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:self.inviteButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Do layout work here
}

- (void)setUser:(PFUser *)aUser {
    [super setUser:aUser];
    
    // Set invite button
    [self.inviteButton setFrame:CGRectMake( 208.0f, 20.0f, 103.0f, 32.0f)];
}

// Since we remove the compile-time check for the delegate conforming to the protocol
// in order to allow inheritance, we add run-time checks.
- (id<TuduInviteCellDelegate>)delegate {
    return (id<TuduInviteCellDelegate>)_delegate;
}

- (void)setDelegate:(id<TuduInviteCellDelegate>)delegate {
    if(_delegate != delegate) {
        _delegate = delegate;
    }
}

- (void)didTapInviteButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapInviteButton:)]) {
        [self.delegate cell:self didTapInviteButton:self.user];
    }
}

@end

