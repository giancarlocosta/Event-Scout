//
//  TuduReviewEventCreationViewController.h
//  tudu
//
//  Created by Gian Costa on 9/10/14.
//
//

#import <UIKit/UIKit.h>
#import "TuduInviteCell.h"

@interface TuduReviewEventCreationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tView;
@property (nonatomic, strong) NSMutableArray *inviteList;
@property (nonatomic, strong) UILabel *detailsLabel;
@property (nonatomic, strong) UITextView *descriptionTextView;
@property (nonatomic, strong) UIView *containerView;

@end
