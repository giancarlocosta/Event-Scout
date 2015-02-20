//
//  TuduFollowFriendsListViewController.m
//  tudu
//
//  Created by Gian Costa on 9/9/14.
//
//

#import "TuduFollowFriendsListViewController.h"
#import "TuduFriendSelectorCell.h"
#import "TuduFollowCell.h"
#import "MBProgressHUD.h"


typedef enum {
    TuduFriendsListFollowingNone = 0,    // User isn't following anybody in Friends list
    TuduFriendsListFollowingAll,         // User is following all Friends
    TuduFriendsListFollowingSome         // User is following some of their Friends
} TuduFriendsListFollowStatus;


@interface TuduFollowFriendsListViewController ()
@property (nonatomic, assign) TuduFriendsListFollowStatus followStatus;
@property (nonatomic, strong) NSMutableDictionary *outstandingFollowQueries;
@end

@implementation TuduFollowFriendsListViewController

@synthesize followStatus;
@synthesize outstandingFollowQueries;
@synthesize event;
@synthesize searchType;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {        
        self.outstandingFollowQueries = [NSMutableDictionary dictionary];
        
        // Used to determine Follow/Unfollow All button status
        self.followStatus = TuduFriendsListFollowingSome;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kTuduActivityClassKey];
    [isFollowingQuery whereKey:kTuduActivityFromUserKey equalTo:[PFUser currentUser]];
    [isFollowingQuery whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeFollow];
    [isFollowingQuery whereKey:kTuduActivityToUserKey containedIn:self.queryObjects];
    [isFollowingQuery setCachePolicy:kPFCachePolicyNetworkOnly];
    
    [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            if (number == self.queryObjects.count) {
                self.followStatus = TuduFriendsListFollowingAll;
                [self configureUnfollowAllButton];
                for (PFUser *user in self.queryObjects) {
                    [[TuduCache sharedCache] setFollowStatus:YES user:user];
                }
            } else if (number == 0) {
                self.followStatus = TuduFriendsListFollowingNone;
                [self configureFollowAllButton];
                for (PFUser *user in self.queryObjects) {
                    [[TuduCache sharedCache] setFollowStatus:NO user:user];
                }
            } else {
                self.followStatus = TuduFriendsListFollowingSome;
                [self configureFollowAllButton];
            }
        }
        
        if (self.queryObjects.count == 0) {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }];
    
    if (self.queryObjects.count == 0) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    
    // Query should
    if( [self.searchType isEqualToString:@"followersList"] || [self.searchType isEqualToString:@"followingList"] )
        [self performQuery:self.user searchType:self.searchType];
    else //[self.searchType isEqualToString:@"invitedList"] || [self.searchType isEqualToString:@"attendingList"]
        [self performQuery:self.event searchType:self.searchType];
}

// Perform query on _Users given the prefix of the user display name ("userInput")
- (void) performQuery:(PFObject *)eventOrUser searchType:(NSString *)searchType {
    PFQuery *query;
    
    if (self.event || self.user) {
        
        // Get users who are invited to the event
        if ([self.searchType isEqual:@"invitedList"]) {
            query = [PFQuery queryWithClassName:kTuduActivityClassKey];
            [query whereKey:kTuduActivityEventKey equalTo:eventOrUser];
            [query whereKey:kTuduActivityFromUserKey equalTo:eventOrUser[kTuduEventUserKey]];
            [query whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeInvite];
            [query includeKey:kTuduActivityToUserKey];
            [query setCachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
                if (!error) {
                    self.queryObjects = nil;
                    self.queryObjects = [NSMutableArray array];
                    for (PFObject *activity in activities) {
                        NSLog(@"one");
                        [self.queryObjects addObject:activity[kTuduActivityToUserKey]];
                    }
                    [self.tableView reloadData];
                } else {
                    NSLog(@"performQuery error in FollowFriendsList 1");
                }
            }];
        }
        
        // Get users who are attending the event
        else if([self.searchType isEqual:@"attendingList"]) {
            query = [PFQuery queryWithClassName:kTuduActivityClassKey];
            [query whereKey:kTuduActivityEventKey equalTo:eventOrUser];
            [query whereKey:kTuduActivityToUserKey equalTo:eventOrUser[kTuduEventUserKey]];
            [query whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeAttend];
            [query includeKey:kTuduActivityFromUserKey];
            [query setCachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
                if (!error) {
                    self.queryObjects = nil;
                    self.queryObjects = [NSMutableArray array];
                    for (PFObject *activity in activities) {
                        NSLog(@"Adding Event");
                        [self.queryObjects addObject:activity[kTuduActivityFromUserKey]];
                    }
                    NSLog(@"queryObjects Count: (%i) :", [self.queryObjects count]);
                    [self.tableView reloadData];
                } else {
                    NSLog(@"performQuery error in FollowFriendsList 2");
                }
            }];
        }
        // Get users who are following the user
        else if([self.searchType isEqual:@"followingList"]) {
            query = [PFQuery queryWithClassName:kTuduActivityClassKey];
            [query whereKey:kTuduActivityFromUserKey equalTo:eventOrUser];
            [query whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeFollow];
            [query includeKey:kTuduActivityToUserKey];
            [query setCachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
                if (!error) {
                    self.queryObjects = nil;
                    self.queryObjects = [NSMutableArray array];
                    for (PFObject *activity in activities) {
                        NSLog(@"Adding Event");
                        [self.queryObjects addObject:activity[kTuduActivityToUserKey]];
                    }
                    NSLog(@"queryObjects Count: (%i) :", [self.queryObjects count]);
                    [self.tableView reloadData];
                } else {
                    NSLog(@"performQuery error in FollowFriendsList 2");
                }
            }];
        }
        // Get users that the user is following
        else if([self.searchType isEqual:@"followersList"]) {
            query = [PFQuery queryWithClassName:kTuduActivityClassKey];
            [query whereKey:kTuduActivityToUserKey equalTo:eventOrUser];
            [query whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeFollow];
            [query includeKey:kTuduActivityFromUserKey];
            [query setCachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
                if (!error) {
                    self.queryObjects = nil;
                    self.queryObjects = [NSMutableArray array];
                    for (PFObject *activity in activities) {
                        NSLog(@"Adding Event");
                        [self.queryObjects addObject:activity[kTuduActivityFromUserKey]];
                    }
                    NSLog(@"queryObjects Count: (%i) :", [self.queryObjects count]);
                    [self.tableView reloadData];
                } else {
                    NSLog(@"performQuery error in FollowFriendsList 2");
                }
            }];
        }
    } else {
        query = [PFQuery queryWithClassName:@"_User"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
            if (!error) {
                    self.queryObjects = nil;
                    self.queryObjects = (NSMutableArray *)users;
                [self.tableView reloadData];
            } else {
                NSLog(@"performQuery error in FollowFriendsList 2");
            }
        }];
    }
    
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
}




// If event is set the query should depend on that
- (void)setTheEvent:(PFObject *)theEvent {
    self.event = theEvent;
}

// If instead the user is set the query should depend on that
- (void)setTheUser:(PFObject *)theUser {
    _user = theUser;
}


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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"HER------");
    [super tableView:tableView cellForRowAtIndexPath:indexPath];
    PFUser *curUser = ((PFUser *)[self.queryObjects objectAtIndex:indexPath.row]);
    NSLog(@"%@", curUser.username);
    static NSString *FriendCellIdentifier = @"FriendCell";
    
    TuduFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
    if (cell == nil) {
        cell = [[TuduFollowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FriendCellIdentifier];
        [cell setDelegate:self]; //This controller will be the delegate (event handler) for the TuduFollowCell's
    }
    
    [cell setUser:(PFUser*)curUser];
    
    [cell.nameButton setTitle:curUser[kTuduUserDisplayNameKey] forState:UIControlStateNormal];
    [cell.eventLabel setText:@"0 events"];
    
    NSDictionary *attributes = [[TuduCache sharedCache] attributesForUser:curUser];
    
    /* SHOWS EVENT COUNT FOR USER CELL
     if (attributes) {
     // set them now
     NSNumber *number = [[TuduCache sharedCache] eventCountForUser:(PFUser *)object];
     [cell.eventLabel setText:[NSString stringWithFormat:@"%@ event%@", number, [number intValue] == 1 ? @"": @"s"]];
     } else {
     @synchronized(self) {
     NSNumber *outstandingCountQueryStatus = [self.outstandingCountQueries objectForKey:indexPath];
     if (!outstandingCountQueryStatus) {
     [self.outstandingCountQueries setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
     PFQuery *eventNumQuery = [PFQuery queryWithClassName:kTuduEventClassKey];
     [eventNumQuery whereKey:kTuduEventUserKey equalTo:object];
     [eventNumQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
     [eventNumQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
     @synchronized(self) {
     [[TuduCache sharedCache] setEventCount:[NSNumber numberWithInt:number] user:(PFUser *)object];
     [self.outstandingCountQueries removeObjectForKey:indexPath];
     }
     TuduFriendSelectorCell *actualCell = (TuduFriendSelectorCell*)[tableView cellForRowAtIndexPath:indexPath];
     [actualCell.eventLabel setText:[NSString stringWithFormat:@"%d event%@", number, number == 1 ? @"" : @"s"]];
     }];
     };
     }
     }
     */
    
    cell.followButton.selected = NO;
    cell.tag = indexPath.row;
    
    if (self.followStatus == TuduFriendsListFollowingSome) {
        if (attributes) {
            [cell.followButton setSelected:[[TuduCache sharedCache] followStatusForUser:curUser]];
        } else {
            @synchronized(self) {
                NSNumber *outstandingQuery = [self.outstandingFollowQueries objectForKey:indexPath];
                if (!outstandingQuery) {
                    [self.outstandingFollowQueries setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
                    PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kTuduActivityClassKey];
                    [isFollowingQuery whereKey:kTuduActivityFromUserKey equalTo:[PFUser currentUser]];
                    [isFollowingQuery whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeFollow];
                    [isFollowingQuery whereKey:kTuduActivityToUserKey equalTo:curUser];
                    [isFollowingQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
                    
                    [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                        @synchronized(self) {
                            [self.outstandingFollowQueries removeObjectForKey:indexPath];
                            [[TuduCache sharedCache] setFollowStatus:(!error && number > 0) user:curUser];
                        }
                        if (cell.tag == indexPath.row) {
                            [cell.followButton setSelected:(!error && number > 0)];
                        }
                    }];
                }
            }
        }
    } else {
        [cell.followButton setSelected:(self.followStatus == TuduFriendsListFollowingAll)];
    }
    
    return cell;
}





//////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - TuduFollowCellDelegate

- (void)cell:(TuduFollowCell *)cellView didTapFollowButton:(PFUser *)user {
    [self shouldToggleFollowFriendForCell:cellView];
}

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





/*////////////////////////////////////////////////////////////////////////////////////////////////////
 *
 * Methods for If "Follow All" Button is selected
 *
 */
- (void)configureFollowAllButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow All" style:UIBarButtonItemStyleBordered target:self action:@selector(followAllFriendsButtonAction:)];
}

- (void)followAllFriendsButtonAction:(id)sender {
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    self.followStatus = TuduFriendsListFollowingAll;
    [self configureUnfollowAllButton];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow All" style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowAllFriendsButtonAction:)];
        
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.queryObjects.count];
        for (int r = 0; r < self.queryObjects.count; r++) {
            PFObject *user = [self.queryObjects objectAtIndex:r];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:r inSection:0];
            //TuduFollowCell *cell = (TuduFollowCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath object:user];
            TuduFollowCell *cell = (TuduFollowCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
            cell.followButton.selected = YES;
            [indexPaths addObject:indexPath];
        }
        
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(followUsersTimerFired:) userInfo:nil repeats:NO];
        [Utility followUsersEventually:self.queryObjects block:^(BOOL succeeded, NSError *error) {
            // note -- this block is called once for every user that is followed successfully. We use a timer to only execute the completion block once no more saveEventually blocks have been called in 2 seconds
            [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2.0f]];
        }];
        
    });
}





/*////////////////////////////////////////////////////////////////////////////////////////////////////
 *
 * Methods for If "Follow All" Button is UNselected
 *
 */
- (void)configureUnfollowAllButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow All" style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowAllFriendsButtonAction:)];
}

- (void)unfollowAllFriendsButtonAction:(id)sender {
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    self.followStatus = TuduFriendsListFollowingNone;
    [self configureFollowAllButton];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow All" style:UIBarButtonItemStyleBordered target:self action:@selector(followAllFriendsButtonAction:)];
        
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.queryObjects.count];
        for (int r = 0; r < self.queryObjects.count; r++) {
            PFObject *user = [self.queryObjects objectAtIndex:r];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:r inSection:0];
            //TuduFollowCell *cell = (TuduFollowCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath object:user];
            TuduFollowCell *cell = (TuduFollowCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
            cell.followButton.selected = NO;
            [indexPaths addObject:indexPath];
        }
        
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        [Utility unfollowUsersEventually:self.queryObjects];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TuduUtilityUserFollowingChangedNotification object:nil];
    });
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


/* //// NOT USING //////
 - (PFQuery *)queryForTable {
 
 PFQuery *query;
 
 
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
 
 if (self.queryObjects.count == 0) {
 query.cachePolicy = kPFCachePolicyCacheThenNetwork;
 }
 
 [query orderByAscending:kTuduUserDisplayNameKey];
 
 return query;
 } */




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
 self.followStatus = TuduFriendsListFollowingAll;
 [self configureUnfollowAllButton];
 for (PFUser *user in self.queryObjects) {
 [[TuduCache sharedCache] setFollowStatus:YES user:user];
 }
 } else if (number == 0) {
 self.followStatus = TuduFriendsListFollowingNone;
 [self configureFollowAllButton];
 for (PFUser *user in self.queryObjects) {
 [[TuduCache sharedCache] setFollowStatus:NO user:user];
 }
 } else {
 self.followStatus = TuduFriendsListFollowingSome;
 [self configureFollowAllButton];
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



