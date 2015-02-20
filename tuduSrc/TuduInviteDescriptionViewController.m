//
//  TuduFriendsSearchViewController.m
//  tudu
//
//  Created by Gian Costa on 9/11/14.
//
//

#import "TuduInviteDescriptionViewController.h"
#import <Parse/Parse.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "TuduFriendSelectorCell.h"
#import "TuduFollowCell.h"
#import "TuduInviteCell.h"
#import "TuduProfileViewController.h"
#import "TuduEventCreatorViewController.h"

@interface TuduInviteDescriptionViewController ()

@end

@implementation TuduInviteDescriptionViewController
@synthesize searchBar;
@synthesize resultsTable;
@synthesize queryObjects;
@synthesize inviteList;
@synthesize inviteObjects;
@synthesize descriptionTextView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[ThemeAndStyle blueGrayColor]];
    self.inviteList = [NSMutableArray array];
    self.inviteObjects = [NSMutableArray array];
    
    // Adjust nav bar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post!" style:UIBarButtonItemStyleBordered target:self action:@selector(postButtonAction:)];
    self.navigationItem.title = @"Invite";
    
    // Removes keyboard upon touching outside of it
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    // Done button on keyboard
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(dismissKeyboard)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];

    [self setupSearchBar];
    self.searchBar.inputAccessoryView = keyboardDoneButtonView;

    [self performQuery:@""]; // Initialize table values
    [self setupResultsTable];
    
    [self setupDescriptionTextView];

    [[self view] addSubview:self.searchBar];
    [[self view] addSubview:self.resultsTable];
    [[self view] addSubview:self.descriptionTextView];
    
}


/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * Setup the initial SearchBar
 *
 */
-(void)setupSearchBar {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 280, self.view.frame.size.width, 20)];
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
                                                                      (self.searchBar.frame.origin.y + self.searchBar.frame.size.height) - self.navigationController.navigationBar.frame.size.height)];
    self.resultsTable.dataSource = self;
    self.resultsTable.delegate = self;
    self.resultsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.png"]]];
    self.resultsTable.backgroundView = texturedBackgroundView;
}


/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * Setup the initial DescriptionTextView
 *
 */
-(void)setupDescriptionTextView{
    // Set up DescriptionTextView
    self.descriptionTextView = [[UITextView alloc]
                                initWithFrame:CGRectMake(0,
                                                         ([UIApplication sharedApplication].statusBarFrame.size.height +
                                                          self.navigationController.navigationBar.frame.size.height),
                                                         self.view.frame.size.width,
                                                         self.searchBar.frame.origin.y - ([UIApplication
                                                                                           sharedApplication].
                                                                                          statusBarFrame.size.height +
                                                                                          self.navigationController.
                                                                                          navigationBar.frame.size.height
                                                                                          ) - 40)];
    self.descriptionTextView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    self.descriptionTextView.spellCheckingType = UITextSpellCheckingTypeYes;
    self.descriptionTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.descriptionTextView.delegate = self;
    self.descriptionTextView.text = @"Write a description...";
    self.descriptionTextView.textColor = [UIColor lightGrayColor];
    self.descriptionTextView.backgroundColor = [UIColor whiteColor];
}



/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * TextViewDelegate Methods
 *
 */
- (BOOL)textViewDidBeginEditing:(UITextView *)textView {
    if( [self.descriptionTextView.text isEqual:@""] || [self.descriptionTextView.text isEqual:@"Write a description..."]){
        self.descriptionTextView.text = @"";
        self.descriptionTextView.textColor = [UIColor blackColor];
    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if([self.descriptionTextView.text isEqual:@""]){
        self.descriptionTextView.text = @"Write a description...";
        self.descriptionTextView.textColor = [UIColor lightGrayColor];
    }
    NSLog(@"END TEXTVIEW");
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


// Define what cell should be
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFUser *curUser = ((PFUser *)[self.queryObjects objectAtIndex:indexPath.row]);
    static NSString *simpleTableIdentifier = @"reusableCell";
    
    TuduInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[TuduInviteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        [cell setDelegate:self];
    }
    
    cell.inviteButton.selected = NO;
    cell.tag = indexPath.row;
    [cell setUser:curUser];
    
    [cell.nameButton setTitle:curUser[kTuduUserDisplayNameKey] forState:UIControlStateNormal];
    
    NSLog(@"cellForRow:Invite list contents ( %i) :", [inviteList count]);
    for (NSString *name in self.inviteList) {
        NSLog(@"Invite list contians %@", name);
    }
    
    // If the inviteList already recorded this person as being invited, toggle the invite button to display so
    if([self.inviteList containsObject:curUser[kTuduUserDisplayNameKey]]) {
        cell.inviteButton.selected = YES;
    }
    
    return cell;
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



/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * TuduFriendSelectorCellDelegate
 *
 */
#pragma mark - TuduFriendSelectorCellDelegate

- (void)cell:(TuduFriendSelectorCell *)cellView didTapUserButton:(PFUser *)aUser {
    // Push account view controller
    TuduProfileViewController *profileViewController = [[TuduProfileViewController alloc] init];
    [profileViewController setUser:aUser];
    [self.navigationController pushViewController:profileViewController animated:YES];
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
    [self performQuery:@""]; //Show all users again
    [self.view endEditing:YES];
}


// Action when first click inside SearchBar
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"ShouldBeginEditing");
    self.searchBar.text = @"";
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    searchField.textColor = [UIColor blackColor];

    // Animate the searchbar and table moving up when the user tries to search
    [self shiftBarAndTableUp];
    self.descriptionTextView.hidden = YES;
    return YES;
}


// Action everytime a character is typed in SearchBar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self performQuery:self.searchBar.text];
}



/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * TuduInviteCellDelegate
 *
 */
#pragma mark - TuduInviteCellDelegate

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
        [self.inviteList removeObject:(NSString *)cellUser[kTuduUserDisplayNameKey]];
        [self.inviteObjects removeObject:cellUser];
        NSLog(@"Removed %@ from the inviteList", cellUser[kTuduUserDisplayNameKey]);
        
        //[Utility inviteUserEventually:cellUser];
        //[[NSNotificationCenter defaultCenter] postNotificationName:TuduUtilityUserFollowingChangedNotification object:nil];
    } else {
        // Invite
        ((TuduInviteCell *)cell).inviteButton.selected = YES;
        
        // Add user displayName inviteList
        [self.inviteList addObject:(NSString *)cellUser[kTuduUserDisplayNameKey]];
        [self.inviteObjects addObject:cellUser];
        NSLog(@"Added %@ to the inviteList", cellUser[kTuduUserDisplayNameKey]);
        NSLog(@"Invite list contents ( %lu) :", (unsigned long)[self.inviteList count]);
    }
}



/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * Shift methods to move SearchBar and Results Table to top half or bottom half os screen
 *
 */
-(void)shiftBarAndTableUp {
    // Animate the searchbar and table moving up when the user tries to search
    [UIView animateWithDuration:0.25 animations:^{
        self.navigationController.navigationBar.hidden = YES;
        
        self.resultsTable.frame = CGRectMake(self.resultsTable.frame.origin.x,
                                             ([UIApplication sharedApplication].statusBarFrame.size.height +
                                              self.searchBar.frame.size.height),
                                             self.resultsTable.frame.size.width,
                                             self.resultsTable.frame.size.height);
        self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x,
                                          [UIApplication sharedApplication].statusBarFrame.size.height,
                                          self.searchBar.frame.size.width,
                                          self.searchBar.frame.size.height);
        
    }];
}

-(void)shiftBarAndTableDown {
    // Animate the searchbar and table moving up when the user tries to search
    [UIView animateWithDuration:0.25 animations:^{
        self.navigationController.navigationBar.hidden = NO;
        
        self.searchBar.frame = CGRectMake(0, 280, self.view.frame.size.width, 20);
        self.resultsTable.frame = CGRectMake(0,
                                             self.searchBar.frame.origin.y + self.searchBar.frame.size.height,
                                             self.view.frame.size.width,
                                             (self.searchBar.frame.origin.y + self.searchBar.frame.size.height) - self.navigationController.navigationBar.frame.size.height);
        
        //Unhide the decriptionTextView
        self.descriptionTextView.hidden = NO;
    }];
    
    [self.searchBar setText:@"Search Friends"];
    [self.searchBar setTintColor:[UIColor blueColor]];
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    searchField.textColor = [UIColor lightGrayColor];
    
    [self showAllFriendsInResultsTable];
}

-(void)showAllFriendsInResultsTable {
    self.queryObjects = nil;
    [self performQuery:@""];
    [self.resultsTable reloadData];
}

-(void)dismissKeyboard {
    NSLog(@"dismissKeyboardMethod");
    [self.searchBar resignFirstResponder];
    [self.descriptionTextView resignFirstResponder];
    [self shiftBarAndTableDown];
}



/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * When POST button is pressed
 *
 */
-(void)postButtonAction:(id)sender
{
    NSLog(@"Post");
    NSArray *views = self.navigationController.viewControllers;
    TuduEventCreatorViewController *creatorScreen = (TuduEventCreatorViewController *)(views[self.navigationController.viewControllers.count - 2]);

    NSDictionary *eventDetails = @{ @"eventTitle" : creatorScreen.titleTextField.text,
                                    @"eventLocation" : creatorScreen.locationTextField.text,
                                    @"eventDate" : creatorScreen.dateTextField.text,
                                    @"eventType" : creatorScreen.eventTypeTextField.text,
                                    @"eventPrivacyType" : creatorScreen.privacyTypeTextField.text,
                                    @"eventDescription" : self.descriptionTextView.text,
                                    @"eventInviteList" : (NSArray *)self.inviteList,
                                    @"userList" : (NSArray *)self.inviteObjects,
                                    };
    
    [Utility createEventInBackground:eventDetails block:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
        } else {
        }
    }];
    
    TuduEventCreatorViewController *newRoot = [[TuduEventCreatorViewController alloc] init];
    [self.navigationController setViewControllers:@[newRoot]];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}



// Perform query on _Users given the prefix of the user display name ("userInput")
- (void) performQuery:(NSString*)userInput {
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    if( ![userInput isEqual: @""] )
        [query whereKey:@"displayName" hasPrefix:userInput];
    [query findObjectsInBackgroundWithBlock:^(NSArray *pfObjects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d users.", pfObjects.count);
            // Do something with the found objects
            self.queryObjects = nil;
            self.queryObjects = pfObjects;
            for (PFObject *object in pfObjects) {
                PFUser *user = (PFUser *)object;
                NSLog(@"%@", user[kTuduUserDisplayNameKey]);
            }
            [self.resultsTable reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
