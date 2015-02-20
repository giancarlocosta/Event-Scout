//
//  TuduFollowCell.h
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//

#import <UIKit/UIKit.h>
#import "TuduFriendSelectorCell.h"

@protocol TuduFollowCellDelegate;

@interface TuduFollowCell : TuduFriendSelectorCell

// The button specific to this type of cell ("Follow" Button)
@property (nonatomic, strong) UIButton *followButton;

/*!Setter for the activity associated with this cell */
//@property (nonatomic, strong) PFUser *user;

/*!Set the new state. This changes the background of the cell. */
- (void)didTapFollowButtonAction:(id)sender;

@end


/*!
 The protocol defines methods a delegate of a PAPBaseTextCell should implement.
 */
@protocol TuduFollowCellDelegate <TuduFriendSelectorCellDelegate>
@optional

/*!
 Sent to the delegate when the activity button is tapped
 @param activity the PFObject of the activity that was tapped
 */
- (void)cell:(TuduFollowCell *)cellView didTapFollowButton:(PFUser *)user;

@end
