//
//  EventHeaderView.h
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "TuduProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"

// TAKE OUT IF USING FOOTER
typedef enum {
    EventHeaderButtonsNone = 0,
    EventHeaderButtonsAttend = 1 << 0,
    EventHeaderButtonsComment = 1 << 1,
    EventHeaderButtonsUser = 1 << 2,
    
    EventHeaderButtonsDefault = EventHeaderButtonsAttend | EventHeaderButtonsComment | EventHeaderButtonsUser
} EventHeaderButtons;
/////
/* When footers used
typedef enum {
	EventHeaderButtonsNone = 0,
	EventHeaderButtonsUser = 1 << 0,
	EventHeaderButtonsDefault = EventHeaderButtonsUser
} EventHeaderButtons;
*/

@protocol  EventHeaderViewDelegate;

@interface  EventHeaderView : UIView

/*! @name Creating Photo Header View */
/*!
 Initializes the view with the specified interaction elements.
 @param buttons A bitmask specifying the interaction elements which are enabled in the view
 */
-(id)initWithFrame:(CGRect)frame buttons : (EventHeaderButtons)otherButtons;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) TuduProfileImageView *avatarImageView;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UILabel *timestampLabel;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;

/// The photo associated with this view
@property(nonatomic, strong) PFObject *event;

/// The bitmask which specifies the enabled interaction elements in the view
@property(nonatomic, readonly, assign) EventHeaderButtons buttons;

/// The Like Photo button
@property (nonatomic, strong) UIButton *attendButton;

/// The Comment On Photo button
@property (nonatomic, strong) UIButton *commentButton;

/*! @name Delegate */
@property(nonatomic, weak) id <EventHeaderViewDelegate> delegate;

- (void)setTheEvent:(PFObject *)theEvent;

// TAKE OUT IF USING FOOTER
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

@end


/*!
 The protocol defines methods a delegate of a EventHeaderView should implement.
 All methods of the protocol are optional.
 */
@protocol EventHeaderViewDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the user button is tapped
 @param user the PFUser associated with this button
 */
-(void)eventHeaderView:(EventHeaderView *)eventHeaderView didTapUserButton : (UIButton *)button user : (PFUser *)user;

// tAKE OUT IF USING FOOTER
-(void)eventHeaderView:(EventHeaderView *)eventHeaderView didTapAttendEventButton : (UIButton *)button event : (PFObject *)event;

/*!
 Sent to the delegate when the comment on event button is tapped
 @param photo the PFObject for the photo that will be commented on
 */
-(void)eventHeaderView:(EventHeaderView *)eventHeaderView didTapCommentOnEventButton : (UIButton *)button event : (PFObject *)event;
//////
@end
