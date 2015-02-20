//
//  TuduFriendsListViewController.h
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//

#import <Parse/Parse.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "TuduFriendSelectorCell.h"
#import "TuduFollowCell.h"
#import "TuduInviteCell.h"

@interface  TuduFriendsListViewController : UITableViewController <TuduFriendSelectorCellDelegate,
ABPeoplePickerNavigationControllerDelegate,
MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate,
UIActionSheetDelegate,
UITableViewDataSource,
UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *queryObjects;

@end
