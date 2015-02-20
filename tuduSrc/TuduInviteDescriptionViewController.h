//
//  TuduFriendsSearchViewController.h
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
#import "TuduFollowCell.h"
#import "TuduInviteCell.h"

@interface TuduInviteDescriptionViewController : UIViewController
<
TuduFriendSelectorCellDelegate,
TuduFollowCellDelegate,
TuduInviteCellDelegate,
ABPeoplePickerNavigationControllerDelegate,
MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate,
UIActionSheetDelegate,
UISearchBarDelegate,
UITableViewDataSource,
UITableViewDelegate,
UITextViewDelegate
>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *resultsTable;
@property (nonatomic, strong) NSArray *queryObjects;
@property (nonatomic, strong) NSMutableArray *inviteList;
@property (nonatomic, strong) NSMutableArray *inviteObjects;
@property (nonatomic, strong) UITextView *descriptionTextView;

@end
