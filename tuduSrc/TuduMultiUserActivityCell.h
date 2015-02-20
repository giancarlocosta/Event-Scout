//
//  TuduMultiUserActivityCell.h
//  tudu
//

#import "TuduBaseTextCell.h"
@protocol TuduMultiUserActivityCellDelegate;

@interface TuduMultiUserActivityCell : TuduBaseTextCell

/*!Setter for the activity associated with this cell */
@property (nonatomic, strong) PFObject *activity;

@property (nonatomic, strong) UIButton *eventButton;
@property (nonatomic, strong) UIButton *toUserButton;

@property (nonatomic) BOOL hasEvent;

/*! Private setter for the right-hand side image */
- (void)setActivityEvent:(PFObject *)event;

/*!Set the new state. This changes the background of the cell. */
- (void)setIsNew:(BOOL)isNew;

- (void)didTapEventButton:(id)sender;
- (void)didTapToUserButton:(id)sender;

/*! Static helper method to calculate the space available for text given images and insets */
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth;

@end


/*!
 The protocol defines methods a delegate of a PAPBaseTextCell should implement.
 */
@protocol TuduMultiUserActivityCellDelegate <TuduBaseTextCellDelegate>
@optional

/*!
 Sent to the delegate when the event or ToUser button is tapped
 @param activity the PFObject of the activity that was tapped
 */
- (void)cell:(TuduMultiUserActivityCell *)cellView didTapEventButton:(PFObject *)event;
- (void)cell:(TuduMultiUserActivityCell *)cellView didTapToUserButton:(PFObject *)user;

@end