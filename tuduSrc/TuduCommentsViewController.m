//
//  TuduFriendsSearchViewController.m
//  tudu
//
//  Created by Gian Costa on 9/11/14.
//
//

#import "TuduCommentsViewController.h"
#import <Parse/Parse.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "TuduFriendSelectorCell.h"
#import "TuduProfileViewController.h"
#import "MBProgressHUD.h"


@interface TuduCommentsViewController ()

@end

@implementation TuduCommentsViewController
@synthesize tableView;
@synthesize queryObjects;
@synthesize commentTextField;
@synthesize event;
@synthesize commentButton;
@synthesize commentPanel;

- (id)initWithEvent:(PFObject *)aEvent {
    self = [super init];
    if (self) {
        self.event = aEvent;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[ThemeAndStyle blueGrayColor]];
    
    // Adjust nav bar
    self.navigationItem.rightBarButtonItem = nil; //[[UIBarButtonItem alloc] initWithTitle:@"Post!" style:UIBarButtonItemStyleBordered target:self action:@selector(postButtonAction:)];
    self.navigationItem.title = @"Comments";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [self setupCommentPanel];
    
    [self performQuery:@""]; // Initialize table values
    [self setupTableView];
    
    [[self view] addSubview:self.commentPanel];
    [[self view] addSubview:self.tableView];
    
    //***** touchesBegan takes care of this (for now)
     UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(dismissKeyboard)];
     [self.view addGestureRecognizer:tap];
}


/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * Setup the initial CommentPanel
 *
 */
-(void)setupCommentPanel {
    self.commentPanel = [[UIView alloc] initWithFrame:CGRectMake(0, self.tabBarController.tabBar.frame.origin.y - 50, self.view.frame.size.width, 50)];
    self.commentPanel.backgroundColor = [ThemeAndStyle blueGrayColor];
    
    
    // SEND COMMENT BUTTON
    self.commentButton = [[UIButton alloc]
                          initWithFrame:CGRectMake(self.view.frame.size.width - 45, 5, 40, 40)];
    self.commentButton.layer.cornerRadius = 10.0f;
    self.commentButton.layer.borderColor = [ThemeAndStyle blueGrayColor].CGColor;
    self.commentButton.layer.borderWidth = 3.0f;
    self.commentButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    self.commentButton.titleEdgeInsets = UIEdgeInsetsMake( 0.0f, 10.0f, 0.0f, 0.0f);
    [self.commentButton setBackgroundColor:[ThemeAndStyle lightTurquoiseColor]];

    [self.commentButton setTitle:NSLocalizedString(@"->  ", @"Follow string, with spaces added for centering")
                       forState:UIControlStateNormal];
    [self.commentButton setTitleShadowColor:[UIColor colorWithRed:232.0f/255.0f green:203.0f/255.0f blue:168.0f/255.0f alpha:1.0f]
                                  forState:UIControlStateNormal];
    [self.commentButton setTitleShadowColor:[UIColor blackColor]
                                  forState:UIControlStateSelected];
    self.commentButton.titleLabel.shadowOffset = CGSizeMake( 0.0f, -1.0f);
    [self.commentButton addTarget:self action:@selector(didTapCommentButton:)
                forControlEvents:UIControlEventTouchUpInside];
    
    
    // TEXT-FIELD
    self.commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, self.view.frame.size.width - 15 - self.commentButton.frame.size.width, 40)];
    self.commentTextField.layer.cornerRadius = 10.0f;
    self.commentTextField.layer.borderColor = [ThemeAndStyle lightTurquoiseColor].CGColor;
    self.commentButton.layer.borderWidth = 3.0f;
    self.commentTextField.spellCheckingType = UITextSpellCheckingTypeYes;
    self.commentTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.commentTextField.delegate = self;
    self.commentTextField.text = @"Comment...";
    self.commentTextField.textColor = [UIColor lightGrayColor];
    self.commentTextField.backgroundColor = [UIColor whiteColor];
    
    [self.commentPanel addSubview:self.commentButton];
    [self.commentPanel addSubview:self.commentTextField];
}


/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * Setup the initial TableView
 *
 */
-(void)setupTableView{
    self.tableView = [[UITableView alloc]
                      initWithFrame:CGRectMake(0,
                                               self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height,
                                               self.view.frame.size.width,
                                               self.commentPanel.frame.origin.y -
                                               (self.navigationController.navigationBar.frame.size.height +
                                                [UIApplication sharedApplication].statusBarFrame.size.height))];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    /*
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.png"]]];
    self.tableView.backgroundView = texturedBackgroundView;
     */
}



/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * TextFieldDelegate Methods
 *
 */
- (BOOL)textFieldDidBeginEditing:(UITextField *)textField {
    if( [textField.text isEqual:@""] || [textField.text isEqual:@"Comment..."]){
        textField.text = @"";
        textField.textColor = [UIColor blackColor];
    }
    //[self shiftCommentPanelUp];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if([textField.text isEqual:@""]){
        textField.text = @"Comment...";
        textField.textColor = [UIColor lightGrayColor];
    }
    else
       textField.textColor = [UIColor blackColor];
    return YES;
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
    PFObject *activity = [self.queryObjects objectAtIndex:indexPath.row];
    PFUser *curUser = activity[kTuduActivityFromUserKey];
    static NSString *simpleTableIdentifier = @"reusableCell";
    
    TuduBaseTextCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[TuduBaseTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        [cell setDelegate:self];
    }
    
    cell.tag = indexPath.row;
    [cell setUser:curUser];
    [cell setDate:activity.createdAt];
    [cell setContentText:activity[kTuduActivityContentKey]];
    
    NSLog(@"User: %@", curUser);
    [cell.nameButton setTitle:curUser[kTuduUserDisplayNameKey] forState:UIControlStateNormal];
    
    return cell;
}


// Action when row is clicked
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.queryObjects.count) {
        PFObject *activity = [self.queryObjects objectAtIndex:indexPath.row];
        
        PFUser *user = (PFUser*)[activity objectForKey:kTuduActivityFromUserKey];
        NSString *nameString = NSLocalizedString(@"Someone", nil);
        if (user && [user objectForKey:kTuduUserDisplayNameKey] && [[user objectForKey:kTuduUserDisplayNameKey] length] > 0) {
            nameString = [user objectForKey:kTuduUserDisplayNameKey];
        }
        
        return [TuduBaseTextCell heightForCellWithName:nameString contentString:activity[kTuduActivityContentKey]];
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
    TuduProfileViewController *profileViewController = [[TuduProfileViewController alloc] initWithUser:aUser];
    [self.navigationController pushViewController:profileViewController animated:YES];
}



/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * Shift methods to move SearchBar and Results Table to top half or bottom half os screen
 *
 */

-(void)shiftCommentPanelUp {
    // Animate the searchbar and table moving up when the user tries to search
    [UIView animateWithDuration:0.25 animations:^{
        [self.view bringSubviewToFront:commentPanel];
        self.commentPanel.frame = CGRectMake(0, commentPanel.frame.origin.y - 160, self.view.frame.size.width, 50);
    }];
}

-(void)shiftCommentPanelDown {
    // Animate the searchbar and table moving up when the user tries to search
    [UIView animateWithDuration:0.25 animations:^{
        [self.view bringSubviewToFront:commentPanel];
        self.commentPanel.frame = CGRectMake(0, self.tabBarController.tabBar.frame.origin.y - 50, self.view.frame.size.width, 50);
    }];
}



- (void)keyboardWasShown:(NSNotification *)notification
{
    
    float keyboardOriginY = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y;
    float keyboardHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    NSLog(@"Y-COORD of keryboardOrigin = %f", keyboardOriginY);
    NSLog(@"Keyboardheight = %f", keyboardHeight);
    
    [UIView animateWithDuration:0.1 animations:^{
        [self.view bringSubviewToFront:commentPanel];
        self.commentPanel.frame = CGRectMake(0, keyboardOriginY - keyboardHeight - 50, self.view.frame.size.width, 50);
    }];
}



/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * When POST button is pressed
 *
 */
-(void)didTapCommentButton:(id)sender
{
    // Trim the comment text
    NSString *trimmedComment = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (trimmedComment.length != 0 && [self.event objectForKey:kTuduEventUserKey]) {
        // Create the comment activity object
        PFObject *comment = [PFObject objectWithClassName:kTuduActivityClassKey];
        [comment setValue:trimmedComment forKey:kTuduActivityContentKey]; // Set comment text
        [comment setValue:[self.event objectForKey:kTuduEventUserKey] forKey:kTuduActivityToUserKey]; // Set toUser
        [comment setValue:[PFUser currentUser] forKey:kTuduActivityFromUserKey]; // Set fromUser
        [comment setValue:kTuduActivityTypeComment forKey:kTuduActivityTypeKey];
        [comment setValue:self.event forKey:kTuduActivityEventKey];
        
        // Set the proper ACLs
        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        comment.ACL = ACL;
        
        // Assume the save will work and increment the comment count cache
        [[TuduCache sharedCache] incrementCommentCountForEvent:self.event];
        
        // Show HUD view
        [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        
        // If more than 5 seconds pass since we post a comment,
        // stop waiting for the server to respond
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                          target:self
                                                        selector:@selector(handleCommentTimeout:)
                                                        userInfo:[NSDictionary
                                                                  dictionaryWithObject:comment
                                                                  forKey:@"comment"] repeats:NO];
        [comment saveEventually:^(BOOL succeeded, NSError *error) {
            [timer invalidate]; // Stop the timer if it's still running
            
            // Check if the event was deleted
            if (error && [error code] == kPFErrorObjectNotFound) {
                // Undo cache update and alert user
                [[TuduCache sharedCache] decrementCommentCountForEvent:self.event];
                [[[UIAlertView alloc] initWithTitle:@"Could not post comment"
                                            message:@"This photo was deleted by its owner"
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil] show];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TuduEventDetailsViewControllerUserCommentedOnEventNotification object:self.event userInfo:@{@"comments": @(self.queryObjects.count + 1)}];
            
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            
            [self performQuery:@""]; // This will update the tableView (add you comment as well)
        }];
    }
    
    [self.commentTextField setText:@""];
    [self dismissKeyboard]; // Moves TextField back down too
    return;
}



// Perform query on _Users given the prefix of the user display name ("userInput")
- (void) performQuery:(NSString*)userInput {
    
    PFQuery *query = [PFQuery queryWithClassName:kTuduActivityClassKey];
    [query whereKey:kTuduActivityEventKey equalTo:self.event];
    [query whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeComment];
    [query includeKey:kTuduActivityFromUserKey];
    [query orderByAscending:@"createdAt"];
    
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    /*
    if (self.queryObjects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
     */
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d activities.", activities.count);
            // Do something with the found objects
            self.queryObjects = nil;
            self.queryObjects = activities;
            for (PFObject *activity in activities) {
                NSLog(@"%@ commented on this event", ((PFUser *)activity[kTuduActivityFromUserKey])[kTuduUserDisplayNameKey]);
            }
            [self.tableView reloadData];
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


//***** touchesBegan takes care of this (for now)

-(void)dismissKeyboard {
    NSLog(@"dismissKeyboardMethod");
    [self.commentTextField resignFirstResponder];
    [self shiftCommentPanelDown];
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touches began");
    [self.commentTextField resignFirstResponder];
}

@end