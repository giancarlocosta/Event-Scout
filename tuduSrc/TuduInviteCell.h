//
//  TuduInviteCell.h
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "TuduFriendSelectorCell.h"
@protocol TuduInviteCellDelegate;

@interface TuduInviteCell : TuduFriendSelectorCell

// The button specific to this type of cell ("Invite" Button)
@property (nonatomic, strong) UIButton *inviteButton;

/*!Setter for the activity associated with this cell */
//@property (nonatomic, strong) PFUser *user;

- (void)didTapInviteButtonAction:(id)sender;

@end


/*!
 The protocol defines methods a delegate of a TuduFriendSelectorCell should implement.
 */
@protocol TuduInviteCellDelegate <TuduFriendSelectorCellDelegate>
@optional

/*!
 Sent to the delegate when the activity button is tapped
 @param activity the PFObject of the activity that was tapped
 */
- (void)cell:(TuduInviteCell *)cellView didTapInviteButton:(PFUser *)user;

@end
