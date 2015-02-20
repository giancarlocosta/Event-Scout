//
//  TuduProfileViewController.m
//  tudu
//
//  Created by Gian Costa on 9/1/14.
//
//

#import "TuduProfileViewController.h"
#import "TuduProfileTableHeaderView.h"
#import "TuduFollowFriendsListViewController.h"

@interface TuduProfileViewController ()
@property (nonatomic, strong) NSString *eventQueryType;
@end

@implementation TuduProfileViewController

- (id)initWithUser:(PFUser *)user {
    self = [super init];
    if (self) {
        _user = user;
        self.eventQueryType = @"hosting";
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = nil;
    //self.navigationController.navigationBar.hidden = YES;
    
    self.profileTableHeaderView = [[TuduProfileTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 340) user:self.user];
    self.profileTableHeaderView.delegate = self;
    
    self.tableView.tableHeaderView = self.profileTableHeaderView;
    
	// Do any additional setup after loading the view.
    PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kTuduActivityClassKey];
    [queryFollowerCount whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeFollow];
    [queryFollowerCount whereKey:kTuduActivityToUserKey equalTo:self.user];
    [queryFollowerCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [self.profileTableHeaderView.followersButton setButtonNumberValue:[NSNumber numberWithInt:number]];
        }
    }];
    
    NSDictionary *followingDictionary = [[PFUser currentUser] objectForKey:@"following"];
    if (followingDictionary) {
        [self.profileTableHeaderView.followingButton setButtonNumberValue:[NSNumber numberWithUnsignedLong:(unsigned long)[[followingDictionary allValues] count]]];
    }
    
    PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kTuduActivityClassKey];
    [queryFollowingCount whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeFollow];
    [queryFollowingCount whereKey:kTuduActivityFromUserKey equalTo:self.user];
    [queryFollowingCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowingCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [self.profileTableHeaderView.followingButton setButtonNumberValue:[NSNumber numberWithInt:number]];
        }
    }];
    
    if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [loadingActivityIndicatorView startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
        
        // check if the currentUser is following this user
        PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kTuduActivityClassKey];
        [queryIsFollowing whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeFollow];
        [queryIsFollowing whereKey:kTuduActivityToUserKey equalTo:self.user];
        [queryIsFollowing whereKey:kTuduActivityFromUserKey equalTo:[PFUser currentUser]];
        [queryIsFollowing setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [queryIsFollowing countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (error && [error code] != kPFErrorCacheMiss) {
                NSLog(@"Couldn't determine follow relationship: %@", error);
                self.navigationItem.rightBarButtonItem = nil;
            } else {
                if (number == 0) {  //Current user is NOT following
                    //NSLog(@"Number is 0 ****************");
                    [self configureFollowButton];
                } else {            //Current user is following
                    //NSLog(@"Number is  NOT 0 ****************");
                    [self configureUnfollowButton];
                }
            }
        }];
    }
}

- (PFQuery *)queryForTable {
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    __block PFQuery *finalQuery;
    
    
    // Query based on what filter button is currently selected
    if([self.eventQueryType isEqualToString:@"hosting"]) {
        
        // Find events hosted by this user that you have been invited to
        PFQuery *invitedActivitiesQuery = [PFQuery queryWithClassName:kTuduActivityClassKey];
        [invitedActivitiesQuery whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeInvite];
        [invitedActivitiesQuery whereKey:kTuduActivityToUserKey equalTo:[PFUser currentUser]];
        [invitedActivitiesQuery whereKey:kTuduActivityFromUserKey equalTo:self.user];
        invitedActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        invitedActivitiesQuery.limit = 1000;
        //NSLog(@"I'm invited to %ld of %@'s events", (long)[invitedActivitiesQuery countObjects], [self.user username]);
        //NSLog(@"Event: %@",[invitedActivitiesQuery getFirstObject][kTuduActivityEventKey]);
        
        /*
        PFQuery *eventsInvitedToQuery = [PFQuery queryWithClassName:kTuduEventClassKey];
        [eventsInvitedToQuery whereKey: matchesKey:kTuduActivityEventKey inQuery:invitedActivitiesQuery];
        [eventsInvitedToQuery whereKeyExists:kTuduEventTitleKey];
        NSLog(@"eventsInvitedToQuery count: %ld", (long)[eventsInvitedToQuery countObjects]);
         */
        
        // Temporary Fix. Only checks the inviteList Field of Event class. (not a reliable check)
        PFQuery *eventsInvitedToQuery = [PFQuery queryWithClassName:kTuduEventClassKey];
        [eventsInvitedToQuery whereKey:kTuduEventUserKey equalTo:self.user];
        [eventsInvitedToQuery whereKey:kTuduEventInviteListKey equalTo:[PFUser currentUser][kTuduUserDisplayNameKey]];
        [eventsInvitedToQuery whereKeyExists:kTuduEventTitleKey];
        //NSLog(@"eventsInvitedToQuery count: %ld", (long)[eventsInvitedToQuery countObjects]);
        
        // Find public events hosted by this user
        PFQuery *publicEventsQuery = [PFQuery queryWithClassName:kTuduEventClassKey];
        [publicEventsQuery whereKey:kTuduEventUserKey equalTo:self.user];
        [publicEventsQuery whereKey:kTuduEventPrivacyTypeKey equalTo:kTuduEventPrivacyTypePublic];
        [publicEventsQuery whereKeyExists:kTuduEventTitleKey];
        
        // Combine events from user that you've been invited to and public events hosted by user
        finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:eventsInvitedToQuery, publicEventsQuery, nil]];
        //NSLog(@"finalQuery count: %ld", (long)[finalQuery countObjects]);
    }
    else if ([self.eventQueryType isEqualToString:@"attending"]) {
        
        NSMutableArray *yourInvitedEventsIds = [[NSMutableArray alloc] init];
        NSMutableArray *commonEventsIds = [[NSMutableArray alloc] init];
        NSMutableArray *userAttendingEventsIds = [[NSMutableArray alloc] init];

        
        // Find events this user is attending
        PFQuery *attendingActivitiesQuery = [PFQuery queryWithClassName:kTuduActivityClassKey];
        [attendingActivitiesQuery whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeAttend];
        [attendingActivitiesQuery whereKey:kTuduActivityFromUserKey equalTo:self.user];
        attendingActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        attendingActivitiesQuery.limit = 1000;
        //NSLog(@"%@ is attnding %ld events", [self.user username], (long)[attendingActivitiesQuery countObjects]);
        
        NSArray *objects = [attendingActivitiesQuery findObjects];
        for (PFObject *object in objects) {
            [userAttendingEventsIds addObject:((PFObject *)object[kTuduActivityEventKey]).objectId];
            //NSLog(@"UAE: %@", ((PFObject *)object[kTuduActivityEventKey]).objectId);
        }
        
        // Based on above events, find the ones that you have also been invited to
        PFQuery *invitedActivitiesQuery = [PFQuery queryWithClassName:kTuduActivityClassKey];
        [invitedActivitiesQuery whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeInvite];
        [invitedActivitiesQuery whereKey:kTuduActivityToUserKey equalTo:[PFUser currentUser]];
        invitedActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        invitedActivitiesQuery.limit = 1000;
        //NSLog(@"You are attnding %ld events", (long)[invitedActivitiesQuery countObjects]);
        
        objects = [invitedActivitiesQuery findObjects];
        for (PFObject *object in objects) {
            [yourInvitedEventsIds addObject:((PFObject *)object[kTuduActivityEventKey]).objectId];
            //NSLog(@"YIE: %@", ((PFObject *)object[kTuduActivityEventKey]).objectId);
        }
        
        for (NSString *attendingEvent in userAttendingEventsIds) {
            if([yourInvitedEventsIds containsObject:attendingEvent]) {
                [commonEventsIds addObject:attendingEvent];
            }
        }
        NSLog(@"%lu commonEventIds", (unsigned long)[commonEventsIds count]);
        
        finalQuery = [PFQuery queryWithClassName:kTuduEventClassKey];
        [finalQuery whereKey:@"objectId" containedIn:commonEventsIds];
        
        /*
        [attendingActivitiesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *object in objects) {
                    [userAttendingEventsIds addObject:((PFObject *)object[kTuduActivityEventKey]).objectId];
                    NSLog(@"UAE: %@", ((PFObject *)object[kTuduActivityEventKey]).objectId);
                }
                
                // Based on above events, find the ones that you have also been invited to
                PFQuery *invitedActivitiesQuery = [PFQuery queryWithClassName:kTuduActivityClassKey];
                [invitedActivitiesQuery whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeInvite];
                [invitedActivitiesQuery whereKey:kTuduActivityToUserKey equalTo:[PFUser currentUser]];
                invitedActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
                invitedActivitiesQuery.limit = 1000;
                //NSLog(@"You are attnding %ld events", (long)[invitedActivitiesQuery countObjects]);
                [invitedActivitiesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        for (PFObject *object in objects) {
                            [yourInvitedEventsIds addObject:((PFObject *)object[kTuduActivityEventKey]).objectId];
                            NSLog(@"YIE: %@", ((PFObject *)object[kTuduActivityEventKey]).objectId);
                        }
                        
                        for (NSString *attendingEvent in userAttendingEventsIds) {
                            if([yourInvitedEventsIds containsObject:attendingEvent]) {
                                [commonEventsIds addObject:attendingEvent];
                            }
                        }
                        NSLog(@"%lu commonEventIds", (unsigned long)[commonEventsIds count]);
                        
                        finalQuery = [PFQuery queryWithClassName:kTuduEventClassKey];
                        [finalQuery whereKey:@"objectId" containedIn:commonEventsIds];
                        
                        
                        [finalQuery includeKey:kTuduEventUserKey];
                        [finalQuery orderByDescending:@"createdAt"];
                        return;
                        
                    } else {
                    }
                }];
                
                
            } else {
                NSLog(@"ERRORRRRRR");
            }
        }];
         

        /*
        // Based on above events, find the ones that you have also been invited to
        PFQuery *invitedActivitiesQuery = [PFQuery queryWithClassName:kTuduActivityClassKey];
        [invitedActivitiesQuery whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeInvite];
        [invitedActivitiesQuery whereKey:kTuduActivityToUserKey equalTo:[PFUser currentUser]];
        invitedActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        invitedActivitiesQuery.limit = 1000;
        [invitedActivitiesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *object in objects) {
                    [yourInvitedEvents addObject:object[kTuduActivityEventKey]];
                }
            } else {
            }
        }];
        
        for (PFObject *attendingEvent in userAttendingEvents) {
            if([yourInvitedEvents containsObject:attendingEvent]) {
                [commonEventsIds addObject:attendingEvent.objectId];
            }
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"objectId IN %@ AND objectId IN %@", invitedActivitiesQuery, attendingActivitiesQuery];
        
        PFQuery *eventsInvitedToQuery = [PFQuery queryWithClassName:kTuduEventClassKey predicate:predicate];
        [eventsInvitedToQuery whereKeyExists:kTuduEventTitleKey];
        
        // Find public events that this user is attending
        PFQuery *publicEventsQuery = [PFQuery queryWithClassName:kTuduEventClassKey];
        [publicEventsQuery whereKey:@"objectId" matchesKey:kTuduActivityEventKey inQuery:attendingActivitiesQuery];
        [publicEventsQuery whereKey:kTuduEventPrivacyTypeKey equalTo:kTuduEventPrivacyTypePublic];
        [publicEventsQuery whereKeyExists:kTuduEventTitleKey];
        
        // Combine events that user is attending that you've been invited to and public events that the user is attending
        finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:eventsInvitedToQuery, publicEventsQuery, nil]];
        
         //
        finalQuery = [PFQuery queryWithClassName:kTuduEventClassKey];
        [finalQuery whereKey:@"objectId" containedIn:commonEventsIds];
         */
    }
    
    
     // A pull-to-refresh should always trigger a network request.
     [finalQuery setCachePolicy:kPFCachePolicyNetworkOnly];
     /*
     // If no objects are loaded in memory, we look to the cache first to fill the table
     // and then subsequently do a query against the network.
     //
     // If there is no network connection, we will hit the cache first.
     if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
     [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
     }
     */
    
    [finalQuery includeKey:kTuduEventUserKey];
    [finalQuery orderByDescending:@"createdAt"];
    NSLog(@"FINAL QUERY has %ld events",(long)[finalQuery countObjects]);
    return finalQuery;
}


- (void)configureUnfollowButton {
    self.profileTableHeaderView.followButton.selected = YES;
    [self.profileTableHeaderView.followButton setTitle:@"Following" forState:UIControlStateSelected];
    [[TuduCache sharedCache] setFollowStatus:YES user:self.user];
}


- (void)configureFollowButton {
    self.profileTableHeaderView.followButton.selected = NO;
    [self.profileTableHeaderView.followButton setTitle:@"Follow" forState:UIControlStateNormal];
    [[TuduCache sharedCache] setFollowStatus:NO user:self.user];
}


-(void)profileHeaderView:(TuduProfileTableHeaderView *)profileHeaderView didTapFollowButton : (UIButton *)button user: (PFUser *)user {

    BOOL previoulyFollowing = self.profileTableHeaderView.followButton.selected;
    if(previoulyFollowing) {    // Unfollow user
        [Utility unfollowUserEventually:self.user];
        [self configureFollowButton];
    }
    else {  // Follow user
        [Utility followUserEventually:self.user block:^(BOOL succeeded, NSError *error) {
            if (error) {
                [self configureFollowButton];
            }
        }];
        
        [self configureUnfollowButton];
    }
}


-(void)profileHeaderView:(TuduProfileTableHeaderView *)profileHeaderView didTapFollowersButton : (UIButton *)button user: (PFUser *)user {
    TuduFollowFriendsListViewController *followersListVC = [[TuduFollowFriendsListViewController alloc] initWithStyle:UITableViewStylePlain];
    followersListVC.user = user;
    followersListVC.searchType = @"followersList";
    
    [self.navigationController pushViewController:followersListVC animated:YES];
}


-(void)profileHeaderView:(TuduProfileTableHeaderView *)profileHeaderView didTapFollowingButton : (UIButton *)button user: (PFUser *)user {
    self.profileTableHeaderView.hostingEventsButton.selected = NO;
    self.profileTableHeaderView.attendingEventsButton.selected = YES;
    
    TuduFollowFriendsListViewController *followingListVC = [[TuduFollowFriendsListViewController alloc] initWithStyle:UITableViewStylePlain];
    followingListVC.user = user;
    followingListVC.searchType = @"followingList";
    
    [self.navigationController pushViewController:followingListVC animated:YES];
}


-(void)profileHeaderView:(TuduProfileTableHeaderView *)profileHeaderView didTapSeeHostingEventsButton : (UIButton *)button user: (PFUser *)user {
    
    // Don't redo query if the button is tapped twice or more in a row
    if(!button.selected) {
        [self.profileTableHeaderView setSelectedButton:button];
        self.eventQueryType = @"hosting";
        [self queryForTable];
        [self loadObjects];
        //[self.tableView reloadData];
    }
    
}


-(void)profileHeaderView:(TuduProfileTableHeaderView *)profileHeaderView didTapSeeAttendingEventsButton : (UIButton *)button user: (PFUser *)user {
    // Don't redo query if the button is tapped twice or more in a row
    if(!button.selected) {
        [self.profileTableHeaderView setSelectedButton:button];
        self.eventQueryType = @"attending";
        [self queryForTable];
        [self loadObjects];
        //[self.tableView reloadData];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUser:(PFUser *)user { }

@end
