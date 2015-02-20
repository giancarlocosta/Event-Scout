//
//  TuduEventFeedViewController.m
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//

#import "TuduEventFeedViewController.h"
#import "TuduEventFeedViewController.h"
#import "EventHeaderView.h"
#import "EventFooterCell.h"
#import "EventDisplayCell.h"
#import "TuduProfileViewController.h"
#import "Utility.h"
#import "TuduCache.h"
#import "TuduEventDetailsViewController.h"
#import "TuduFollowFriendsListViewController.h"
#import "TuduFriendsListViewController.h"
#import "TuduCommentsViewController.h"

//#import "TuduLoadMoreCell.h"

@interface TuduEventFeedViewController ()
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic, strong) NSMutableDictionary *outstandingSectionHeaderQueries;
@end

@implementation TuduEventFeedViewController
@synthesize reusableSectionHeaderViews;
@synthesize shouldReloadOnAppear;
@synthesize outstandingSectionHeaderQueries;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TuduTabBarControllerDidFinishEditingEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TuduUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TuduEventDetailsViewControllerUserAttendedUnattendedEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TuduUtilityUserAttendedUnattendedEventCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TuduEventDetailsViewControllerUserCommentedOnEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TuduEventDetailsViewControllerUserDeletedEventNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        self.outstandingSectionHeaderQueries = [NSMutableDictionary dictionary];
        
        // The className to query on
        self.parseClassName = kTuduEventClassKey;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 10;
        
        // Improve scrolling performance by reusing UITableView section headers
        self.reusableSectionHeaderViews = [NSMutableSet setWithCapacity:3];
        
        self.shouldReloadOnAppear = NO;
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [super viewDidLoad];
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    texturedBackgroundView.backgroundColor = [UIColor colorWithRed:0.55 green:0.49 blue:0.42 alpha:1];
    texturedBackgroundView.backgroundColor = [ThemeAndStyle blueGrayColor];
    //texturedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundWood.jpg"]];
    self.tableView.backgroundView = texturedBackgroundView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidPublishEvent:) name:TuduTabBarControllerDidFinishEditingEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFollowingChanged:) name:TuduUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeleteEvent:) name:TuduEventDetailsViewControllerUserDeletedEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidAttendOrUnattendEvent:) name:TuduEventDetailsViewControllerUserAttendedUnattendedEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidAttendOrUnattendEvent:) name:TuduUtilityUserAttendedUnattendedEventCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidCommentOnEvent:) name:TuduEventDetailsViewControllerUserCommentedOnEventNotification object:nil];
     
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog([PFUser currentUser][@"username"]);
    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = NO;
        [self loadObjects];
    }
}
#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *basicEventsQuery = [PFQuery queryWithClassName:kTuduEventClassKey];
    /*
     PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kTuduActivityClassKey];
     [followingActivitiesQuery whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeFollow];
     [followingActivitiesQuery whereKey:kTuduActivityFromUserKey equalTo:[PFUser currentUser]];
     followingActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
     followingActivitiesQuery.limit = 1000;
     
     PFQuery *eventsFromFollowedUsersQuery = [PFQuery queryWithClassName:self.parseClassName];
     [eventsFromFollowedUsersQuery whereKey:kTuduEventUserKey matchesKey:kTuduActivityToUserKey inQuery:followingActivitiesQuery];
     [eventsFromFollowedUsersQuery whereKeyExists:kTuduEventTitleKey];
     
     PFQuery *eventsFromCurrentUserQuery = [PFQuery queryWithClassName:self.parseClassName];
     [eventsFromCurrentUserQuery whereKey:kTuduEventUserKey equalTo:[PFUser currentUser]];
     [eventsFromCurrentUserQuery whereKeyExists:kTuduEventTitleKey];
     
     PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:eventsFromFollowedUsersQuery, eventsFromCurrentUserQuery, nil]];
     [query includeKey:kTuduEventUserKey];
     [query orderByDescending:@"createdAt"];
     
     // A pull-to-refresh should always trigger a network request.
     [query setCachePolicy:kPFCachePolicyNetworkOnly];
     
     // If no objects are loaded in memory, we look to the cache first to fill the table
     // and then subsequently do a query against the network.
     //
     // If there is no network connection, we will hit the cache first.
     if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
     [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
     }
     */
    
    /*
     This query will result in an error if the schema hasn't been set beforehand. While Parse usually handles this automatically, this is not the case for a compound query such as this one. The error thrown is:
     
     Error: bad special key: __type
     
     To set up your schema, you may post a event with a caption. This will automatically set up the Event and Activity classes needed by this query.
     
     You may also use the Data Browser at Parse.com to set up your classes in the following manner.
     
     Create a User class: "User" (if it does not exist)
     
     Create a Custom class: "Activity"
     - Add a column of type pointer to "User", named "fromUser"
     - Add a column of type pointer to "User", named "toUser"
     - Add a string column "type"
     
     Create a Custom class: "Event"
     - Add a column of type pointer to "User", named "user"
     
     You'll notice that these correspond to each of the fields used by the preceding query.
     */
    
    //return query;
    [basicEventsQuery includeKey:kTuduEventUserKey]; // Must use for pointer fields
    [basicEventsQuery orderByDescending:@"createdAt"];
    
    return basicEventsQuery;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = self.objects.count;
    if (self.paginationEnabled && sections != 0)
        sections++;
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        // Load More section
        return nil;
    }
    static NSString *headerReuseIdentifier = @"header";
    EventHeaderView *headerView = [self dequeueReusableSectionHeaderView];
    
    if (!headerView) {
        headerView = [[EventHeaderView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.view.bounds.size.width, 44.0f) buttons:EventHeaderButtonsDefault];
        headerView.delegate = self;
        [self.reusableSectionHeaderViews addObject:headerView];
    }
    
    PFObject *event = [self.objects objectAtIndex:section];
    
    //headerView.avatarImageView setFile:(PFFile *)
    headerView.avatarImageView.profileImageView.image = [UIImage imageNamed:@"AvatarPlaceholder.png"];
    [headerView setTheEvent:event];
    headerView.tag = section;

    return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f;
    }
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, 24.0f)];
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f;
    }
    return 24.0f;
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.objects.count) {
        // Load More Section
        return 44.0f;
    }
    
    if(indexPath.row == 0)
        return [EventDisplayCell heightForDisplayCell];
    else
        return [EventFooterCell heightForFooterCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == self.objects.count && self.paginationEnabled) {
        // Load More Cell
        [self loadNextPage];
    }
}


- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    // overridden, since we want to implement sections
    if (indexPath.section < self.objects.count) {
        return [self.objects objectAtIndex:indexPath.section];
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    PFObject *event = object;
    static NSString *CellIdentifier = @"Cell";
    static NSString *FooterCellIdentifier = @"FooterCell";
    
    if (indexPath.section == self.objects.count) {
        // this behavior is normally handled by PFQueryTableViewController, but we are using sections for each object and we must handle this ourselves
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    } else {
        
        NSDictionary *attributesForEvent = [[TuduCache sharedCache] attributesForEvent:event];
        
        // First cell contains event display
        if(indexPath.row == 0) {
            EventDisplayCell *cell = (EventDisplayCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Cuts off "Pacific time ...etc"
            NSString *dateString = event[kTuduEventDateKey];
            NSUInteger *ind = [dateString rangeOfString: @"M P" ].location;
            if( ind != NSNotFound)
                dateString = [dateString substringToIndex: ind];
            
            if (cell == nil) {
                cell = [[EventDisplayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                [cell.eventButton addTarget:self action:@selector(didTapOnEventAction:) forControlEvents: UIControlEventTouchUpInside];
            }
            
            cell.eventButton.tag = indexPath.section;
            cell.tag = indexPath.section;
            //cell.imageView.image = [UIImage imageNamed:@"DefaultDisplayCellBackground.jpg"];
            cell.imageView.backgroundColor = [UIColor whiteColor];
            [cell.eventTitleLabel setText:event[kTuduEventTitleKey]];
            [cell.eventDateLabel setText:dateString];
            [cell.eventLocationLabel setText:event[kTuduEventLocationKey]];
            
            if (object) {
                //cell.imageView.file = [object objectForKey:kTuduEventPictureKey];
                
                // PFQTVC will take care of asynchronously downloading files, but will only load them when the tableview is not moving. If the data is there, let's load it right away.
                //if ([cell.imageView.file isDataAvailable]) {
                //    [cell.imageView loadInBackground];
                //}
            }
            
            return cell;
        }
        
        //
        // Second cell contains footer cell
        //
        else if (indexPath.row == 1) {
            
            EventFooterCell *cell = (EventFooterCell *)[tableView dequeueReusableCellWithIdentifier:FooterCellIdentifier];
            
            if (cell == nil) {
                cell = [[EventFooterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FooterCellIdentifier buttons:EventFooterButtonsDefault];
            }
            

            cell.delegate = self;
            [cell setTheEvent:object];
            cell.tag = indexPath.section;
            
            if (attributesForEvent) {
                NSLog(@"ATTRIBUTES FOR THIS EVENT: %@", event[@"title"]);
                
                // Configure Buttons
                [cell setAttendStatus:[[TuduCache sharedCache] isEventAttendedByCurrentUser:event]];
                [cell.attendingListButton
                 setTitle:[NSString stringWithFormat:@" %@ Attending",[[[TuduCache sharedCache] attendCountForEvent:event] description]]
                 forState:UIControlStateNormal];
                [cell.commentListButton setTitle: [NSString stringWithFormat:@" %@ Comments", [[[TuduCache sharedCache] commentCountForEvent:event] description]]
                                        forState:UIControlStateNormal];
                //IMPLEMENT IN CACHE --- See below on line 430
                 //[cell.invitedListButton setTitle:[NSString stringWithFormat:@"%@ Invited",[[[TuduCache sharedCache] inviteCountForEvent:event] description]] forState:UIControlStateNormal];
                //[cell.invitedListButton setTitle: [NSString stringWithFormat:@"%lu Invited", (unsigned long)[event[kTuduEventInviteListKey] count] ] forState:UIControlStateNormal];
                
                
                if (cell.attendButton.alpha < 1.0f || cell.commentButton.alpha < 1.0f) {
                    [UIView animateWithDuration:0.200f animations:^{
                        cell.attendButton.alpha = 1.0f;
                        cell.commentButton.alpha = 1.0f;
                    }];
                }
            }
            //else {
                //NSLog(@"----NO ATTRIBUTES FOR THIS EVENT");
                cell.attendButton.alpha = 0.0f;
                cell.commentButton.alpha = 0.0f;
                
                @synchronized(self) {
                    
                    // check if we can UPDATE CACHE
                    NSNumber *outstandingSectionHeaderQueryStatus = [self.outstandingSectionHeaderQueries objectForKey:@(indexPath.section)];
                    if (!outstandingSectionHeaderQueryStatus) {
                        PFQuery *query = [Utility queryForActivitiesOnEvent:event cachePolicy:kPFCachePolicyNetworkOnly];
                        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            @synchronized(self) {
                                [self.outstandingSectionHeaderQueries removeObjectForKey:@(indexPath.section)];
                                
                                if (error) {
                                    return;
                                }
                                
                                NSMutableArray *attenders = [NSMutableArray array];
                                NSMutableArray *commenters = [NSMutableArray array];
                                NSMutableArray *invitedPeople = [NSMutableArray array];
                                
                                BOOL isattendedByCurrentUser = NO;
                                //NSLog(@"Activities count for %@ is %i", event[@"title"], [objects count]);
                                for (PFObject *activity in objects) {
                                    if ([[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeAttend]){
                                    }
                                    
                                    // Check if activity type is "attend" and the the frmUser exists
                                    if ([[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeAttend] && [activity objectForKey:kTuduActivityFromUserKey]) {
                                        [attenders addObject:[activity objectForKey:kTuduActivityFromUserKey]];
                                    }
                                    // Check if activity type is "comment" and the the frmUser exists
                                    else if ([[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeComment] && [activity objectForKey:kTuduActivityFromUserKey]) {
                                        [commenters addObject:[activity objectForKey:kTuduActivityFromUserKey]];
                                    }
                                    // Check if activity type is "invite" and the the frmUser exists
                                    else if ([[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeInvite] && [activity objectForKey:kTuduActivityFromUserKey]) {
                                        [invitedPeople addObject:[activity objectForKey:kTuduActivityFromUserKey]];
                                    }
                                    
                                    // Check is current user is attending
                                    if ([[[activity objectForKey:kTuduActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                                        if ([[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeAttend]) {
                                            isattendedByCurrentUser = YES;
                                        }
                                    }
                                }
                                
                                [[TuduCache sharedCache] setAttributesForEvent:event attenders:attenders commenters:commenters invitedPeople:invitedPeople attendedByCurrentUser:isattendedByCurrentUser];
                                
                                if (cell.tag != indexPath.section) {
                                    return;
                                }
                                
                                [cell setAttendStatus:[[TuduCache sharedCache] isEventAttendedByCurrentUser:event]];
                                
                                // Query for Attend count, Comment, Invite count
                                [cell.attendingListButton
                                 setTitle: [NSString stringWithFormat:@" %@ Attending",[[[TuduCache sharedCache] attendCountForEvent:event] description]] forState:UIControlStateNormal];
                                [cell.commentListButton
                                 setTitle: [NSString stringWithFormat:@" %@ Comments",[[[TuduCache sharedCache] commentCountForEvent:event] description]] forState:UIControlStateNormal];
                                [cell.invitedListButton
                                 setTitle:[NSString stringWithFormat:@" %@ Invited",[[[TuduCache sharedCache] inviteCountForEvent:event] description]]
                                 forState:UIControlStateNormal];
                                
                                if (cell.attendButton.alpha < 1.0f || cell.commentButton.alpha < 1.0f) {
                                    //[UIView animateWithDuration:0.200f animations:^{
                                        cell.attendButton.alpha = 1.0f;
                                        cell.commentButton.alpha = 1.0f;
                                    //}];
                                }
                            }
                        }];
                    }
                }
            //}
            
            return cell;
        }
    }
}

/* COME BACK TO THIS
- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    TuduLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[TuduLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle =UITableViewCellSelectionStyleGray;
        cell.separatorImageTop.image = [UIImage imageNamed:@"SeparatorTimelineDark.png"];
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}
 */


#pragma mark - TuduEventFeedViewController

- (EventHeaderView *)dequeueReusableSectionHeaderView {
    for (EventHeaderView *sectionHeaderView in self.reusableSectionHeaderViews) {
        if (!sectionHeaderView.superview) {
            // we found a section header that is no longer visible
            return sectionHeaderView;
        }
    }
    
    return nil;
}






/*!
 Sent to the delegate when the like event button is tapped
 @param event the PFObject for the event that is being liked or disliked
 */
-(void)eventFooterCell:(EventFooterCell *)eventFooterCell didTapAttendEventButton : (UIButton *)button event : (PFObject *)event {
    
        NSLog(@"--Tapped Attend for the event: %@", event[@"title"]);
    
    // Disable the button so users cannot send duplicate requests
    [eventFooterCell shouldEnableAttendButton:NO];
    BOOL attended = !button.selected;
    [eventFooterCell setAttendStatus:attended];
    
    NSString *originalButtonTitle = button.titleLabel.text;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    NSNumber *attendCount = [numberFormatter
                             numberFromString:[eventFooterCell.attendingListButton.titleLabel.text componentsSeparatedByString:@" "][0]];
    // Update Cache
    if (attended) {
        attendCount = [NSNumber numberWithInt:[attendCount intValue] + 1];
        [[TuduCache sharedCache] incrementAttenderCountForEvent:event];
    } else {
        if ([attendCount intValue] > 0) {
            attendCount = [NSNumber numberWithInt:[attendCount intValue] - 1];
        }
        [[TuduCache sharedCache] decrementAttenderCountForEvent:event];
    }
    
    [[TuduCache sharedCache] setEventIsAttendedByCurrentUser:event attended:attended];
    
    // Update Attending List number
    [eventFooterCell.attendingListButton setTitle:[NSString stringWithFormat:@"%@ Attending", attendCount] forState:UIControlStateNormal];
    
    // Add or Remove Attend Activity in database
    if (attended) {
        [Utility attendEventInBackground:event block:^(BOOL succeeded, NSError *error) {
            //EventFooterCell *actualFooterCell = eventFooterCell; //(EventFooterCell *)[self tableView:self.tableView viewForFooterInSection:button.tag];
            EventFooterCell *actualFooterCell = (EventFooterCell *)[self.tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:1 inSection:eventFooterCell.tag]];
            [actualFooterCell shouldEnableAttendButton:YES];
            [actualFooterCell setAttendStatus:succeeded];
            
            if (!succeeded) {
                [actualFooterCell.attendButton setTitle:originalButtonTitle forState:UIControlStateNormal];
            }
        }];
    } else {
        [Utility unattendEventInBackground:event block:^(BOOL succeeded, NSError *error) {
            //EventFooterCell *actualFooterCell = eventFooterCell; //(EventFooterCell *)[self tableView:self.tableView viewForHeaderInSection:button.tag];
            EventFooterCell *actualFooterCell = (EventFooterCell *)[self.tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:1 inSection:eventFooterCell.tag]];
            [actualFooterCell shouldEnableAttendButton:YES];
            [actualFooterCell setAttendStatus:!succeeded];
            
            if (!succeeded) {
                [actualFooterCell.attendButton setTitle:originalButtonTitle forState:UIControlStateNormal];
            }
        }];
    }
}


/*!
 Sent to the delegate when the comment on event button is tapped
 @param event the PFObject for the event that will be commented on
 */
-(void)eventFooterCell:(EventFooterCell *)eventFooterCell didTapCommentOnEventButton : (UIButton *)button event : (PFObject *)event {
    
    TuduCommentsViewController *commentsVC = [[TuduCommentsViewController alloc] initWithEvent:event];
    [self.navigationController pushViewController:commentsVC animated:YES];
    
}

/*!
 Sent to the delegate when the comment on event button is tapped
 @param event the PFObject for the event that will be commented on
 */
-(void)eventFooterCell:(EventFooterCell *)eventFooterCell didTapAttendingListButton : (UIButton *)button event : (PFObject *)event {
    TuduFollowFriendsListViewController *attendingListVC = [[TuduFollowFriendsListViewController alloc] initWithStyle:UITableViewStylePlain];
    attendingListVC.event = event;
    attendingListVC.searchType = @"attendingList";
    
    [self.navigationController pushViewController:attendingListVC animated:YES];
}


/*!
 Sent to the delegate when the comment on event button is tapped
 @param event the PFObject for the event that will be commented on
 */
-(void)eventFooterCell:(EventFooterCell *)eventFooterCell didTapInvitedListButton : (UIButton *)button event : (PFObject *)event {
    
    TuduFollowFriendsListViewController *attendingListVC = [[TuduFollowFriendsListViewController alloc] initWithStyle:UITableViewStylePlain];
    attendingListVC.event = event;
    attendingListVC.searchType = @"invitedList";
    
    [self.navigationController pushViewController:attendingListVC animated:YES];
}

/*!
 Sent to the delegate when the comment on event button is tapped
 @param event the PFObject for the event that will be commented on
 */
-(void)eventFooterCell:(EventFooterCell *)eventFooterCell didTapCommentListButton : (UIButton *)button event : (PFObject *)event {
     TuduCommentsViewController *commentsVC = [[TuduCommentsViewController alloc] initWithEvent:event];
     [self.navigationController pushViewController:commentsVC animated:YES];
}





#pragma mark - ()

- (NSIndexPath *)indexPathForObject:(PFObject *)targetObject {
    for (int i = 0; i < self.objects.count; i++) {
        PFObject *object = [self.objects objectAtIndex:i];
        if ([[object objectId] isEqualToString:[targetObject objectId]]) {
            return [NSIndexPath indexPathForRow:0 inSection:i];
        }
    }
    
    return nil;
}

- (void)userDidAttendOrUnattendEvent:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidCommentOnEvent:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}



- (void)userDidDeleteEvent:(NSNotification *)note {
    // refresh timeline after a delay
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [self loadObjects];
    });
}

- (void)userDidPublishEvent:(NSNotification *)note {
    if (self.objects.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    [self loadObjects];
}

- (void)userFollowingChanged:(NSNotification *)note {
    self.shouldReloadOnAppear = YES;
}

- (void)didTapOnEventAction:(UIButton *)sender {
    PFObject *event = [self.objects objectAtIndex:sender.tag];
    if (event) {
        // If you are viewing your own event you can edit it, otherwise you can't edit other people's events
        TuduEventDetailsViewController *eventDetailsVC;
        if([((PFUser*)event[kTuduEventUserKey]).username isEqual:[PFUser currentUser].username]) {
            eventDetailsVC = [[TuduEventDetailsViewController alloc] initWithEvent:event userCanEditEvent:YES];
        }
        else
            eventDetailsVC = [[TuduEventDetailsViewController alloc] initWithEvent:event userCanEditEvent:NO];
        
        [self.navigationController pushViewController:eventDetailsVC animated:YES];
    }
}



#pragma mark - TuduEventHeaderViewDelegate

- (void)eventHeaderView:(EventHeaderView *)eventHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    TuduProfileViewController *profileViewController = [[TuduProfileViewController alloc] initWithUser:user];
    [self.navigationController pushViewController:profileViewController animated:YES];
}


@end