//
//  TuduFriendsListViewController.m
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//


#import "TuduAppDelegate.h"
#import "TuduFriendsListViewController.h"
#import "TuduFriendSelectorCell.h"
#import "TuduFollowCell.h"
#import "TuduInviteCell.h"
#import "TuduProfileViewController.h"
#import "TuduProfileImageView.h"
#import "MBProgressHUD.h"
//#import "TuduLoadMoreCell.h"
//#import "TuduAccountViewController.h"

/*
typedef enum {
    TuduFriendsListFollowingNone = 0,    // User isn't following anybody in Friends list
    TuduFriendsListFollowingAll,         // User is following all Friends
    TuduFriendsListFollowingSome         // User is following some of their Friends
} TuduFriendsListFollowStatus;
*/

@interface TuduFriendsListViewController ()
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) NSString *selectedEmailAddress;
@property (nonatomic, strong) NSMutableDictionary *outstandingCountQueries;
//@property (nonatomic, assign) TuduFriendsListFollowStatus followStatus;
//@property (nonatomic, strong) NSMutableDictionary *outstandingFollowQueries;
@end

@implementation TuduFriendsListViewController
@synthesize queryObjects;
@synthesize headerView;
@synthesize selectedEmailAddress;
@synthesize outstandingCountQueries;
//@synthesize outstandingFollowQueries;
//@synthesize followStatus;
#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        // Used to determine Follow/Unfollow All button status
        //self.outstandingFollowQueries = [NSMutableDictionary dictionary];
        //self.followStatus = TuduFriendsListFollowingSome;
        
        self.outstandingCountQueries = [NSMutableDictionary dictionary];
        
        self.selectedEmailAddress = @"";
        
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.png"]]];
    self.tableView.backgroundView = texturedBackgroundView;
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TitleFindFriends.png"]];
    
    /*
     if ([MFMailComposeViewController canSendMail] || [MFMessageComposeViewController canSendText]) {
     self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 67)];
     [self.headerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundFindFriendsCell.png"]]];
     UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
     [clearButton setBackgroundColor:[UIColor clearColor]];
     [clearButton addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
     [clearButton setFrame:self.headerView.frame];
     [self.headerView addSubview:clearButton];
     NSString *inviteString = NSLocalizedString(@"Invite friends", @"Invite friends");
     CGRect boundingRect = [inviteString boundingRectWithSize:CGSizeMake(310.0f, CGFLOAT_MAX)
     options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
     attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18.0f]}
     context:nil];
     CGSize inviteStringSize = boundingRect.size;
     
     UILabel *inviteLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (self.headerView.frame.size.height-inviteStringSize.height)/2, inviteStringSize.width, inviteStringSize.height)];
     [inviteLabel setText:inviteString];
     [inviteLabel setFont:[UIFont boldSystemFontOfSize:18]];
     [inviteLabel setTextColor:[UIColor colorWithRed:87.0f/255.0f green:72.0f/255.0f blue:49.0f/255.0f alpha:1.0]];
     [inviteLabel setBackgroundColor:[UIColor clearColor]];
     [self.headerView addSubview:inviteLabel];
     UIImageView *separatorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SeparatorTimeline.png"]];
     [separatorImage setFrame:CGRectMake(0, self.headerView.frame.size.height-2, 320, 2)];
     [self.headerView addSubview:separatorImage];
     [self.tableView setTableHeaderView:self.headerView];
     }
     */
}


/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * TableViewDelegate Methods
 *
 */
#pragma - markup TableView Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.queryObjects.count;
}

// Action when row is clicked
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.queryObjects.count) {
        return [TuduFriendSelectorCell heightForCell];
    } else {
        return 44.0f;
    }
}







#pragma mark - TuduFriendSelectorCellDelegate

- (void)cell:(TuduFriendSelectorCell *)cellView didTapUserButton:(PFUser *)aUser {
    // Push account view controller
    TuduProfileViewController *profileViewController = [[TuduProfileViewController alloc] init];
    [profileViewController setUser:aUser];
    [self.navigationController pushViewController:profileViewController animated:YES];
}



#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (buttonIndex == 0) {
        [self presentMailComposeViewController:self.selectedEmailAddress];
    } else if (buttonIndex == 1) {
        [self presentMessageComposeViewController:self.selectedEmailAddress];
    }
}

#pragma mark - ()

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)inviteFriendsButtonAction:(id)sender {
    ABPeoplePickerNavigationController *addressBook = [[ABPeoplePickerNavigationController alloc] init];
    addressBook.peoplePickerDelegate = self;
    
    if ([MFMailComposeViewController canSendMail] && [MFMessageComposeViewController canSendText]) {
        addressBook.displayedProperties = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonEmailProperty], [NSNumber numberWithInt:kABPersonPhoneProperty], nil];
    } else if ([MFMailComposeViewController canSendMail]) {
        addressBook.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]];
    } else if ([MFMessageComposeViewController canSendText]) {
        addressBook.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
    }
    
    [self presentViewController:addressBook animated:YES completion:nil];
}




- (void)presentMailComposeViewController:(NSString *)recipient {
    // Create the compose email view controller
    MFMailComposeViewController *composeEmailViewController = [[MFMailComposeViewController alloc] init];
    
    // Set the recipient to the selected email and a default text
    [composeEmailViewController setMailComposeDelegate:self];
    [composeEmailViewController setSubject:@"Join me on Tudu"];
    [composeEmailViewController setToRecipients:[NSArray arrayWithObjects:recipient, nil]];
    [composeEmailViewController setMessageBody:@"<h2>Share your pictures, share your story.</h2><p><a href=\"http://tudu.org\">Tudu</a> is the easiest way to share events with your friends. Get the app and share your fun events with the world.</p><p><a href=\"http://tudu.org\">Tudu</a> is fully powered by <a href=\"http://parse.com\">Parse</a>.</p>" isHTML:YES];
    
    // Dismiss the current modal view controller and display the compose email one.
    // Note that we do not animate them. Doing so would require us to present the compose
    // mail one only *after* the address book is dismissed.
    [self dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:composeEmailViewController animated:NO completion:nil];
}

- (void)presentMessageComposeViewController:(NSString *)recipient {
    // Create the compose text message view controller
    MFMessageComposeViewController *composeTextViewController = [[MFMessageComposeViewController alloc] init];
    
    // Send the destination phone number and a default text
    [composeTextViewController setMessageComposeDelegate:self];
    [composeTextViewController setRecipients:[NSArray arrayWithObjects:recipient, nil]];
    [composeTextViewController setBody:@"Check out Tudu! http://tudu.org"];
    
    // Dismiss the current modal view controller and display the compose text one.
    // See previous use for reason why these are not animated.
    [self dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:composeTextViewController animated:NO completion:nil];
}

- (void)followUsersTimerFired:(NSTimer *)timer {
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:TuduUtilityUserFollowingChangedNotification object:nil];
}

#pragma mark - ABPeoplePickerDelegate

/* Called when the user cancels the address book view controller. We simply dismiss it. */
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/* Called when a member of the address book is selected, we return YES to display the member's details. */
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}

/* Called when the user selects a property of a person in their address book (ex. phone, email, location,...)
 This method will allow them to send a text or email inviting them to Tudu.  */
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    if (property == kABPersonEmailProperty) {
        
        ABMultiValueRef emailProperty = ABRecordCopyValue(person,property);
        NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailProperty,identifier);
        self.selectedEmailAddress = email;
        
        if ([MFMailComposeViewController canSendMail] && [MFMessageComposeViewController canSendText]) {
            // ask user
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Invite %@",@""] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"iMessage", nil];
            [actionSheet showFromTabBar:self.tabBarController.tabBar];
        } else if ([MFMailComposeViewController canSendMail]) {
            // go directly to mail
            [self presentMailComposeViewController:email];
        } else if ([MFMessageComposeViewController canSendText]) {
            // go directly to iMessage
            [self presentMessageComposeViewController:email];
        }
        
    } else if (property == kABPersonPhoneProperty) {
        ABMultiValueRef phoneProperty = ABRecordCopyValue(person,property);
        NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneProperty,identifier);
        
        if ([MFMessageComposeViewController canSendText]) {
            [self presentMessageComposeViewController:phone];
        }
    }
    
    return NO;
}

#pragma mark - MFMailComposeDelegate

/* Simply dismiss the MFMailComposeViewController when the user sends an email or cancels */
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - MFMessageComposeDelegate

/* Simply dismiss the MFMessageComposeViewController when the user sends a text or cancels */
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
}



///// NOT USING //////

#pragma mark - PFQueryTableViewController
/*
 - (PFQuery *)queryForTable {
 
 //PFQuery *query = [PFQuery queryWithClassName:@"_User"];
 
 
 // Use cached facebook friend ids
 NSArray *facebookFriends = [[TuduCache sharedCache] facebookFriends];
 
 // Query for all friends you have on facebook and who are using the app
 PFQuery *friendsQuery = [PFUser query];
 [friendsQuery whereKey:kTuduUserFacebookIDKey containedIn:facebookFriends];
 
 // Query for all Parse employees
 NSMutableArray *parseEmployees = [[NSMutableArray alloc] initWithArray:kTuduParseEmployeeAccounts];
 [parseEmployees removeObject:[[PFUser currentUser] objectForKey:kTuduUserFacebookIDKey]];
 PFQuery *parseEmployeeQuery = [PFUser query];
 [parseEmployeeQuery whereKey:kTuduUserFacebookIDKey containedIn:parseEmployees];
 
 // Combine the two queries with an OR
 PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:friendsQuery, parseEmployeeQuery, nil]];
 query.cachePolicy = kPFCachePolicyNetworkOnly;
 */

/*
 if (self.objects.count == 0) {
 query.cachePolicy = kPFCachePolicyCacheThenNetwork;
 }
 
 [query orderByAscending:kTuduUserDisplayNameKey];
 
 return query;
 
 }*/


/*
- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
 
 
     PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kTuduActivityClassKey];
     [isFollowingQuery whereKey:kTuduActivityFromUserKey equalTo:[PFUser currentUser]];
     [isFollowingQuery whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeFollow];
     [isFollowingQuery whereKey:kTuduActivityToUserKey containedIn:self.objects];
     [isFollowingQuery setCachePolicy:kPFCachePolicyNetworkOnly];
     
     [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
     if (!error) {
     if (number == self.objects.count) {
     self.followStatus = TuduFriendsListFollowingAll;
     [self configureUnfollowAllButton];
     for (PFUser *user in self.objects) {
     [[TuduCache sharedCache] setFollowStatus:YES user:user];
     }
     } else if (number == 0) {
     self.followStatus = TuduFriendsListFollowingNone;
     [self configureFollowAllButton];
     for (PFUser *user in self.objects) {
     [[TuduCache sharedCache] setFollowStatus:NO user:user];
     }
     } else {
     self.followStatus = TuduFriendsListFollowingSome;
     [self configureFollowAllButton];
     }
     }
     
     if (self.objects.count == 0) {
     self.navigationItem.rightBarButtonItem = nil;
     }
     }];
     
 
    if (self.queryObjects.count == 0) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}*/

- (void)shouldToggleFollowFriendForCell:(TuduFriendSelectorCell*)cell {
    PFUser *cellUser = cell.user;
    if ([((TuduFollowCell *)cell).followButton isSelected]) {
        // Unfollow
        ((TuduFollowCell *)cell).followButton.selected = NO;
        [Utility unfollowUserEventually:cellUser];
        [[NSNotificationCenter defaultCenter] postNotificationName:TuduUtilityUserFollowingChangedNotification object:nil];
    } else {
        // Follow
        ((TuduFollowCell *)cell).followButton.selected = YES;
        [Utility followUserEventually:cellUser block:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:TuduUtilityUserFollowingChangedNotification object:nil];
            } else {
                ((TuduFollowCell *)cell).followButton.selected = NO;
            }
        }];
    }
}

- (void)configureUnfollowAllButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow All" style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowAllFriendsButtonAction:)];
}

- (void)configureFollowAllButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow All" style:UIBarButtonItemStyleBordered target:self action:@selector(followAllFriendsButtonAction:)];
}

/*
 - (void)followAllFriendsButtonAction:(id)sender {
 [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
 
 self.followStatus = TuduFindFriendsFollowingAll;
 [self configureUnfollowAllButton];
 
 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
 self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow All" style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowAllFriendsButtonAction:)];
 
 NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.objects.count];
 for (int r = 0; r < self.objects.count; r++) {
 PFObject *user = [self.objects objectAtIndex:r];
 NSIndexPath *indexPath = [NSIndexPath indexPathForRow:r inSection:0];
 TuduFindFriendsCell *cell = (TuduFindFriendsCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath object:user];
 cell.followButton.selected = YES;
 [indexPaths addObject:indexPath];
 }
 
 [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
 [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
 
 NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(followUsersTimerFired:) userInfo:nil repeats:NO];
 [TuduUtility followUsersEventually:self.objects block:^(BOOL succeeded, NSError *error) {
 // note -- this block is called once for every user that is followed successfully. We use a timer to only execute the completion block once no more saveEventually blocks have been called in 2 seconds
 [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2.0f]];
 }];
 
 });
 }
 
 - (void)unfollowAllFriendsButtonAction:(id)sender {
 [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
 
 self.followStatus = TuduFindFriendsFollowingNone;
 [self configureFollowAllButton];
 
 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
 self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow All" style:UIBarButtonItemStyleBordered target:self action:@selector(followAllFriendsButtonAction:)];
 
 NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.objects.count];
 for (int r = 0; r < self.objects.count; r++) {
 PFObject *user = [self.objects objectAtIndex:r];
 NSIndexPath *indexPath = [NSIndexPath indexPathForRow:r inSection:0];
 TuduFindFriendsCell *cell = (TuduFindFriendsCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath object:user];
 cell.followButton.selected = NO;
 [indexPaths addObject:indexPath];
 }
 
 [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
 [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
 
 [TuduUtility unfollowUsersEventually:self.objects];
 
 [[NSNotificationCenter defaultCenter] postNotificationName:TuduUtilityUserFollowingChangedNotification object:nil];
 });
 
 }
 */


@end
