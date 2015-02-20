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
#import "TuduNumberTitleButton.h"
#import "TTTTimeIntervalFormatter.h"


@protocol  TuduProfileTableHeaderViewDelegate;

@interface  TuduProfileTableHeaderView : UIView

/*! @name Creating Photo Header View */
/*!
 Initializes the view with the specified interaction elements.
 @param buttons A bitmask specifying the interaction elements which are enabled in the view
 */
- (id)initWithFrame:(CGRect)frame user:(PFUser *)user;

- (void)setSelectedButton:(UIButton *)selectedButton;

@property (nonatomic, strong) PFUser *user;

@property (nonatomic, strong) TuduProfileImageView *avatarImageView;
@property (nonatomic, strong) UIView *coreInfoContainer;
@property (nonatomic, strong) UILabel *userDisplayNameLabel;

@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UIView *followListsContainer;
@property (nonatomic, strong) TuduNumberTitleButton *followingButton;
@property (nonatomic, strong) TuduNumberTitleButton *followersButton;

@property (nonatomic, strong) UIView *buttonPanelContainer;
@property (nonatomic, strong) UIButton *hostingEventsButton;
@property (nonatomic, strong) UIButton *attendingEventsButton;
@property (nonatomic, strong) UIButton *button3;
@property (nonatomic, strong) UIButton *button4;

@property(nonatomic, weak) id <TuduProfileTableHeaderViewDelegate> delegate;

@end

/*!
 The protocol defines methods a delegate of a TuduProfileTableHeaderView should implement.
 All methods of the protocol are optional.
 */
@protocol TuduProfileTableHeaderViewDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the user button is tapped
 @param user the PFUser associated with this button
 */
-(void)profileHeaderView:(TuduProfileTableHeaderView *)profileHeaderView didTapFollowersButton : (UIButton *)button user: (PFUser *)user;

-(void)profileHeaderView:(TuduProfileTableHeaderView *)profileHeaderView didTapFollowingButton : (UIButton *)button user: (PFUser *)user;

-(void)profileHeaderView:(TuduProfileTableHeaderView *)profileHeaderView didTapFollowButton : (UIButton *)button user: (PFUser *)user;


-(void)profileHeaderView:(TuduProfileTableHeaderView *)profileHeaderView didTapSeeHostingEventsButton : (UIButton *)button user: (PFUser *)user;

-(void)profileHeaderView:(TuduProfileTableHeaderView *)profileHeaderView didTapSeeAttendingEventsButton : (UIButton *)button user: (PFUser *)user;

@end