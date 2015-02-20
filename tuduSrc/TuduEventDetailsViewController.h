//
//  TuduEventDetailsViewController.h
//  tudu
//
//  Created by Gian Costa on 9/10/14.
//
//

#import <UIKit/UIKit.h>
#import "EventHeaderView.h"
#import "TuduNumberTitleButton.h"

#define BUTTONS_WIDTH 70
#define BUTTONS_HEIGHT 20
#define LIST_CONTAINER_HEIGHT 40

@interface TuduEventDetailsViewController : UIViewController <UIScrollViewDelegate, EventHeaderViewDelegate>

@property (nonatomic) BOOL presentTextViewFirst;

@property (nonatomic, strong) PFObject *event;
@property (nonatomic, strong) EventHeaderView *headerView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) UIView *detailsContainer;
@property (nonatomic, strong) UIView *actionsContainer;
@property (nonatomic, strong) UIView *listButtonsContainer;
@property (nonatomic, strong) UIView *actionsButtonsContainer;

@property (nonatomic, strong) UIView *descriptionContainer;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *descriptionContentLabel;
@property (nonatomic, strong) UIButton *editDescriptionButton;

@property (nonatomic, strong) UILabel *eventTitleLabel;
@property (nonatomic, strong) UILabel *eventDateLabel;
@property (nonatomic, strong) UILabel *eventLocationLabel;

@property (nonatomic, strong) UIButton *attendButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *inviteButton;

@property (nonatomic, strong) UIButton *editInviteButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *editDetailsButton;


@property (nonatomic, strong) TuduNumberTitleButton *attendingListButton;
@property (nonatomic, strong) TuduNumberTitleButton *commentListButton;
@property (nonatomic, strong) TuduNumberTitleButton *invitedListButton;

@property (nonatomic) BOOL *userCanEditEvent;
- (id)initWithEvent:(PFObject *)aEvent userCanEditEvent:(BOOL)editable;

@end
