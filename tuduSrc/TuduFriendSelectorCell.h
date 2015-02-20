//
//  TuduFriendSelectorCell.h
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//

#import <UIKit/UIKit.h>

@class PAPProfileImageView;
@protocol TuduFriendSelectorCellDelegate;

@interface TuduFriendSelectorCell : UITableViewCell {
    id _delegate;
}

@property(nonatomic, strong) id delegate;

/*! The user represented in the cell */
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIButton *nameButton;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UILabel *eventLabel;
//@property (nonatomic, strong) UIButton *actionButton;

/*! Setters for the cell's content */
- (void)setUser:(PFUser *)user;
- (void)didTapUserButtonAction:(id)sender;
//- (void)didTapActionButtonAction:(id)sender;

/*! Static Helper methods */
+ (CGFloat)heightForCell;

@end

/*! Layout constants */
#define vertBorderSpacing 8.0f
#define vertElemSpacing 0.0f

#define horiBorderSpacing 8.0f
#define horiBorderSpacingBottom 9.0f
#define horiElemSpacing 5.0f

#define vertTextBorderSpacing 10.0f

#define avatarX horiBorderSpacing
#define avatarY vertBorderSpacing
#define avatarDim 33.0f

#define nameX avatarX+avatarDim+horiElemSpacing
#define nameY vertTextBorderSpacing
#define nameMaxWidth 200.0f

#define timeX avatarX+avatarDim+horiElemSpacing

/*!
 The protocol defines methods a delegate of a TuduFriendSelectorCell should implement.
 */
@protocol TuduFriendSelectorCellDelegate <NSObject>
@optional

/*!
 Sent to the delegate when a user button is tapped
 @param aUser the PFUser of the user that was tapped
 */
-(void)cell:(TuduFriendSelectorCell *)cellView didTapUserButton : (PFUser *)aUser;
//-(void)cell:(TuduFriendSelectorCell *)cellView didTapFollowButton : (PFUser *)aUser;

@end
