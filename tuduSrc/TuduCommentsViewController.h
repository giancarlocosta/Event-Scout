//
//  TuduCommentsViewController.h
//  tudu
//
//  Created by Gian Costa on 9/11/14.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "TuduFriendSelectorCell.h"
#import "TuduBaseTextCell.h"
#import "TuduFriendSelectorCell.h"

@interface TuduCommentsViewController : UIViewController
<
TuduFriendSelectorCellDelegate,
UIActionSheetDelegate,
UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate
>

@property (nonatomic, strong) PFObject *event;
- (id)initWithEvent:(PFObject *)aEvent;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *queryObjects;

@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIView *commentPanel;

@end