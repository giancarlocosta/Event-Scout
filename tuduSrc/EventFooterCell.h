//
//  EventFooterView.h
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//

#import <UIKit/UIKit.h>
#import "TuduProfileImageView.h"

#define CELL_HEIGHT 60
#define BUTTONS_WIDTH 80
#define BUTTONS_HEIGHT 25

typedef enum {
	EventFooterButtonsNone = 0,
	EventFooterButtonsAttend = 1 << 0,
	EventFooterButtonsComment = 1 << 1,
    
	EventFooterButtonsDefault = EventFooterButtonsAttend | EventFooterButtonsComment
} EventFooterButtons;

@protocol  EventFooterCellDelegate;

@interface  EventFooterCell : UITableViewCell //UITableViewHeaderFooterView

/*! @name Creating Photo Header View */
/*!
 Initializes the view with the specified interaction elements.
 @param buttons A bitmask specifying the interaction elements which are enabled in the view
 */
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier buttons:(EventFooterButtons)otherButtons;

@property (nonatomic, strong) UIView *containerView;

/// The event associated with this view
@property(nonatomic, strong) PFObject *event;

/// The bitmask which specifies the enabled interaction elements in the view
@property(nonatomic, readonly, assign) EventFooterButtons buttons;

/*! @name Accessing Interaction Elements */

/// The Like Photo button
@property(nonatomic, strong) UIButton *attendButton;

/// The List of Attending people button
@property(nonatomic, strong) UIButton *attendingListButton;

/// The Comment On Photo button
@property(nonatomic, strong) UIButton *commentButton;

/// The List of Attending people button
@property(nonatomic, strong) UIButton *commentListButton;

/// The Invited List button
@property(nonatomic, strong) UIButton *invitedListButton;

/*! @name Delegate */
@property(nonatomic, weak) id <EventFooterCellDelegate> delegate;

/*! @name Modifying Interaction Elements Status */


+ (CGFloat)heightForFooterCell;

/*!
 Configures the Like Button to match the given like status.
 @param attending a BOOL indicating if the user will be attending
 */
-(void)setAttendStatus:(BOOL)attending;

/*!
 Enable the Attend button to start receiving actions.
 @param enable a BOOL indicating if the attend button should be enabled.
 */
-(void)shouldEnableAttendButton:(BOOL)enable;


- (void)setTheEvent:(PFObject *)theEvent;


@end


/*!
 The protocol defines methods a delegate of a EventFooterCell should implement.
 All methods of the protocol are optional.
 */
@protocol EventFooterCellDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the like event button is tapped
 @param photo the PFObject for the photo that is being liked or disliked
 */
-(void)eventFooterCell:(EventFooterCell *)eventFooterCell didTapAttendEventButton : (UIButton *)button event : (PFObject *)event;

/*!
 Sent to the delegate when the comment on event button is tapped
 @param photo the PFObject for the photo that will be commented on
 */
-(void)eventFooterCell:(EventFooterCell *)eventFooterCell didTapCommentOnEventButton : (UIButton *)button event : (PFObject *)event;

/*!
 Sent to the delegate when the comment on event button is tapped
 @param photo the PFObject for the photo that will be commented on
 */
-(void)eventFooterCell:(EventFooterCell *)eventFooterCell didTapAttendingListButton : (UIButton *)button event : (PFObject *)event;
/*!
 Sent to the delegate when the comment on event button is tapped
 @param photo the PFObject for the photo that will be commented on
 */
-(void)eventFooterCell:(EventFooterCell *)eventFooterCell didTapCommentListButton : (UIButton *)button event : (PFObject *)event;
/*!
 Sent to the delegate when the comment on event button is tapped
 @param photo the PFObject for the photo that will be commented on
 */
-(void)eventFooterCell:(EventFooterCell *)eventFooterCell didTapInvitedListButton : (UIButton *)button event : (PFObject *)event;


@end
