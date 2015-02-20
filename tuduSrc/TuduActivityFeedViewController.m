//
//  TuduActivityFeedViewController.m
//  tudu
//
//  Created by Gian Costa on 9/1/14.
//
//

#import "TuduActivityFeedViewController.h"
#import "TuduProfileViewController.h"
#import "TuduEventDetailsViewController.h"

@interface TuduActivityFeedViewController ()

@end

@implementation TuduActivityFeedViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TuduAppDelegateApplicationDidReceiveRemoteNotification object:nil];
}

- (id)initWithUser:(PFObject *)aUser {
    self = [super init];
    if (self) {
        self.user = aUser;
        //self.resultsTable.pagingEnabled = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[ThemeAndStyle blueGrayColor]];
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.png"]]];
    self.resultsTable.backgroundView = texturedBackgroundView;
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    
    // Add Settings button
    //self.navigationItem.rightBarButtonItem = [[TuduSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveRemoteNotification:) name:TuduAppDelegateApplicationDidReceiveRemoteNotification object:nil];
    
    /*
    self.blankTimelineView = [[UIView alloc] initWithFrame:self.resultsTable.bounds];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"ActivityFeedBlank.png"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(24.0f, 113.0f, 271.0f, 140.0f)];
    [button addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.blankTimelineView addSubview:button];
     */
    
    //lastRefresh = [[NSUserDefaults standardUserDefaults] objectForKey:kTuduUserDefaultsActivityFeedViewControllerLastRefreshKey];
    
    // Done button on keyboard
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(dismissKeyboard)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
    [self setupSearchBar];
    self.searchBar.inputAccessoryView = keyboardDoneButtonView;
    
    [self setupResultsTable];
    
    [[self view] addSubview:self.searchBar];
    [[self view] addSubview:self.resultsTable];
    
    if(self.user)
        [self performQuery:self.user.objectId];
    else
        [self performQuery:@"allUsers"];
}

/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * Setup the initial SearchBar
 *
 */
-(void)setupSearchBar {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width, 20)];
    self.searchBar.delegate = self;
    [self.searchBar setText:@"Search Friends"];
    [self.searchBar setTintColor:[UIColor blueColor]];
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    searchField.textColor = [UIColor lightGrayColor];
    self.searchBar.backgroundColor = [UIColor lightGrayColor];
}


/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * Setup the initial ResultsTable
 *
 */
-(void)setupResultsTable {
    self.resultsTable = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                      self.searchBar.frame.origin.y + self.searchBar.frame.size.height,
                                                                      self.view.frame.size.width,
                                                                      self.view.frame.size.height -
                                                                      (self.searchBar.frame.origin.y + self.searchBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height))];
    self.resultsTable.dataSource = self;
    self.resultsTable.delegate = self;
    self.resultsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.png"]]];
    self.resultsTable.backgroundView = texturedBackgroundView;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

// Perform query on _Users given the prefix of the user display name ("userInput")
- (void) performQuery:(NSString*)userId {
    PFQuery *query = [PFQuery queryWithClassName:kTuduActivityClassKey];
    
    if([userId isEqualToString:@"allUsers"]) {
        [query includeKey:kTuduActivityFromUserKey];
        [query includeKey:kTuduActivityToUserKey];
        [query includeKey:kTuduActivityEventKey];
        [query orderByDescending:@"createdAt"];
    }
    else {
        [query whereKey:kTuduActivityFromUserKey equalTo:userId];
        [query whereKeyExists:kTuduActivityFromUserKey];
        [query includeKey:kTuduActivityToUserKey];
        [query includeKey:kTuduActivityFromUserKey];
        [query includeKey:kTuduActivityEventKey];
        [query orderByDescending:@"createdAt"];
    }
    
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.queryObjects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *pfObjects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d activities.", pfObjects.count);
            // Do something with the found objects
            self.queryObjects = nil;
            self.queryObjects = pfObjects;
            
            for (PFObject *object in pfObjects) {
                NSLog(@"%@", object[kTuduActivityContentKey]);
            }
            [self.resultsTable reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.queryObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *curActivity = ((PFUser *)[self.queryObjects objectAtIndex:indexPath.row]);
    static NSString *CellIdentifier = @"ActivityCell";
    
    TuduActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TuduActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setDelegate:self];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    cell.tag = indexPath.row;
    [cell setActivity:curActivity];
    
    /*
    if ([lastRefresh compare:[object createdAt]] == NSOrderedAscending) {
        [cell setIsNew:YES];
    } else {
        [cell setIsNew:NO];
    }
     */
    
    [cell hideSeparator:(indexPath.row == self.queryObjects.count - 1)];
    
    return cell;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    TuduLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[TuduLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
    }
    return cell;
  
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.queryObjects.count) {
        PFObject *object = [self.queryObjects objectAtIndex:indexPath.row];
        NSString *activityString = [TuduActivityFeedViewController stringForActivityType:(NSString*)[object objectForKey:kTuduActivityTypeKey]];
        
        PFUser *user = (PFUser*)[object objectForKey:kTuduActivityFromUserKey];
        NSString *nameString = NSLocalizedString(@"Someone", nil);
        if (user && [user objectForKey:kTuduUserDisplayNameKey] && [[user objectForKey:kTuduUserDisplayNameKey] length] > 0) {
            nameString = [user objectForKey:kTuduUserDisplayNameKey];
        }
        
        return [TuduActivityCell heightForCellWithName:nameString contentString:activityString];
    } else {
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.queryObjects.count) {
        PFObject *activity = [self.queryObjects objectAtIndex:indexPath.row];
        if ([activity objectForKey:kTuduActivityEventKey]) {
            PFObject *event = activity[kTuduActivityEventKey];
            TuduEventDetailsViewController *eventDetailsViewController;
            if([((PFUser*)event[kTuduEventUserKey]).username isEqual:[PFUser currentUser].username]) {
                eventDetailsViewController = [[TuduEventDetailsViewController alloc] initWithEvent:[activity objectForKey:kTuduActivityEventKey] userCanEditEvent:YES];
            } else
                eventDetailsViewController = [[TuduEventDetailsViewController alloc] initWithEvent:event userCanEditEvent:NO];
            
            [self.navigationController pushViewController:eventDetailsViewController animated:YES];
        } else if ([activity objectForKey:kTuduActivityFromUserKey]) {
            TuduProfileViewController *detailViewController = [[TuduProfileViewController alloc] init];
            [detailViewController setUser:activity[kTuduActivityFromUserKey]];
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
    } else if (/*self.paginationEnabled*/1) {
        // load more
        //[self loadNextPage];
    }
}

/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * UISearchBarDelegate
 *
 */
#pragma mark - UISearchBarDelegate

// Action when Search button on Keyboard is clicked
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self performQuery:self.searchBar.text];
}


// Action when click outside of searchbar
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self performQuery:@"allUsers"]; //Show all users again
    [self.view endEditing:YES];
}


// Action when first click inside SearchBar
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"ShouldBeginEditing");
    self.searchBar.text = @"";
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    searchField.textColor = [UIColor blackColor];
    
    return YES;
}


// Action everytime a character is typed in SearchBar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self performQuery:self.searchBar.text];
}


#pragma mark - TuduActivityCellDelegate Methods

- (void)cell:(TuduActivityCell *)cellView didTapEventButton:(PFObject *)event {
    // Get image associated with the activity
    
    TuduEventDetailsViewController *eventDetailsViewController;
    // Push single Event view controller
    if([((PFUser*)([event[kTuduEventUserKey] fetchIfNeeded])).username isEqual:[PFUser currentUser].username]) {
        eventDetailsViewController = [[TuduEventDetailsViewController alloc] initWithEvent:event userCanEditEvent:YES];
    } else
        eventDetailsViewController = [[TuduEventDetailsViewController alloc] initWithEvent:event userCanEditEvent:NO];

    [self.navigationController pushViewController:eventDetailsViewController animated:YES];
}

- (void)cell:(TuduBaseTextCell *)cellView didTapUserButton:(PFUser *)user {
    // Push account view controller
    TuduProfileViewController *profileViewController = [[TuduProfileViewController alloc] init];
    [profileViewController setUser:user];
    [self.navigationController pushViewController:profileViewController animated:YES];
}


#pragma mark - TuduActivityFeedViewController

+ (NSString *)stringForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:kTuduActivityTypeAttend]) {
        return NSLocalizedString(@"is this is a really long sentence testing to see if the box expands to fit all this text attending your Event: ", nil);
    } else if ([activityType isEqualToString:kTuduActivityTypeFollow]) {
        return NSLocalizedString(@"started following you", nil);
    } else if ([activityType isEqualToString:kTuduActivityTypeComment]) {
        return NSLocalizedString(@"commented on your Event", nil);
    } else if ([activityType isEqualToString:kTuduActivityTypeJoined]) {
        return NSLocalizedString(@"joined Tudu", nil);
    } else if ([activityType isEqualToString:kTuduActivityTypeInvite]) {
            return NSLocalizedString(@"invited you to their Event: ", nil);
    } else {
        return nil;
    }
}

+ (NSString *)stringForActivity:(PFObject *)activity {
    NSString *activityType = activity[kTuduActivityTypeKey];
    NSString *toDisplayName;
    NSString *fromDisplayName;
    NSString *eventName;
    
    if ([activityType isEqualToString:kTuduActivityTypeAttend]) {               // Attend
        toDisplayName = ((PFUser *)activity[kTuduActivityToUserKey]).username;
        fromDisplayName = ((PFUser *)activity[kTuduActivityFromUserKey]).username;
        eventName = activity[kTuduActivityEventKey];
        return NSLocalizedString(@"is going to ", nil);
    } else if ([activityType isEqualToString:kTuduActivityTypeFollow]) {        // Follow
        return NSLocalizedString(@"started following", nil);
    } else if ([activityType isEqualToString:kTuduActivityTypeComment]) {       // Comment
        return NSLocalizedString(@"commented on", nil);
    } else if ([activityType isEqualToString:kTuduActivityTypeJoined]) {        // Joined
        return NSLocalizedString(@"joined Tudu", nil);
    } else {
        return nil;
    }
}


-(void)dismissKeyboard {
    [self.searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end



