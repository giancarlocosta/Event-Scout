//
//  TuduInviteFriendsListViewController.m
//  tudu
//
//  Created by Gian Costa on 9/9/14.
//
//

#import "TuduInviteFriendsListViewController.h"
#import "TuduNextButtonItem.h"
#import "TuduReviewEventCreationViewController.h"

@interface TuduInviteFriendsListViewController ()

@end

@implementation TuduInviteFriendsListViewController
@synthesize inviteList;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[TuduNextButtonItem alloc] initWithTarget:self action:@selector(nextButtonAction:)];
    
    self.inviteList = [NSMutableArray array];
	// Do any additional setup after loading the view.
}



- (PFQuery *)queryForTable {
    
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    
    /*
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
    if (self.queryObjects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByAscending:kTuduUserDisplayNameKey];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    //[super tableView:tableView cellForRowAtIndexPath:indexPath object:object];
    
    static NSString *FriendCellIdentifier = @"FriendCell";
    
    TuduInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
    if (cell == nil) {
        cell = [[TuduInviteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FriendCellIdentifier];
        [cell setDelegate:self]; //This controller will be the delegate (event handler) for the TuduInviteCell
    }
    PFUser *curUser = (PFUser*)object;
    
    [cell setUser:(PFUser*)object];
    
    [cell.nameButton setTitle:curUser[kTuduUserDisplayNameKey] forState:UIControlStateNormal];
    [cell.eventLabel setText:@"0 events"]; // change this to "Available or not " label
    
    
    cell.inviteButton.selected = NO;
    cell.tag = indexPath.row;
        
    return cell;
}





//////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - TuduFollowCellDelegate

- (void)cell:(TuduInviteCell *)cellView didTapInviteButton:(PFUser *)user {
    [self shouldToggleInviteFriendForCell:cellView];
}

- (void)shouldToggleInviteFriendForCell:(TuduFriendSelectorCell*)cell {
    PFUser *cellUser = cell.user;
    
    // If the invite button previously was seleted, then uninvtie the person
    if ([((TuduInviteCell *)cell).inviteButton isSelected]) {
        // UnInvite
        ((TuduInviteCell *)cell).inviteButton.selected = NO;
        
        // Remove user displayName from inviteList
        [self.inviteList removeObject:cellUser[kTuduUserDisplayNameKey]];
        
        [Utility unfollowUserEventually:cellUser];
        //[[NSNotificationCenter defaultCenter] postNotificationName:TuduUtilityUserFollowingChangedNotification object:nil];
    } else {
        // Invite
        ((TuduInviteCell *)cell).inviteButton.selected = YES;
        
        // Add user displayName inviteList
        [self.inviteList addObject:cellUser[kTuduUserDisplayNameKey]];
    }
}



/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * When NEXT button is clicked
 *
 */
-(void)nextButtonAction:(id)sender
{
	TuduReviewEventCreationViewController *reviewEventViewController = [[TuduReviewEventCreationViewController alloc] init];
    reviewEventViewController.inviteList = self.inviteList;
    
	[self.navigationController pushViewController:reviewEventViewController animated:YES];
}






















/*
- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kTuduActivityClassKey];
    [isFollowingQuery whereKey:kTuduActivityFromUserKey equalTo:[PFUser currentUser]];
    [isFollowingQuery whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeFollow];
    [isFollowingQuery whereKey:kTuduActivityToUserKey containedIn:self.queryObjects];
    [isFollowingQuery setCachePolicy:kPFCachePolicyNetworkOnly];
    
    [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            if (number == self.queryObjects.count) {
                // Do stuff
            } else if (number == 0) {
                // Do stuff
            } else {
                // Do stuff
            }
        }
        
        if (self.queryObjects.count == 0) {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }];
    
    if (self.queryObjects.count == 0) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}
*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
