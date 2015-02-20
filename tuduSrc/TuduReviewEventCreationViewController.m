//
//  TuduReviewEventCreationViewController.m
//  tudu
//
//  Created by Gian Costa on 9/10/14.
//
//

#import "TuduReviewEventCreationViewController.h"
#import "TuduInviteFriendsListViewController.h"
#import "TuduInviteCell.h"

@interface TuduReviewEventCreationViewController ()

@end

@implementation TuduReviewEventCreationViewController
@synthesize inviteList;
@synthesize detailsLabel;
@synthesize descriptionTextView;
@synthesize tView;
@synthesize containerView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Adjust nav bar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post!" style:UIBarButtonItemStyleBordered target:self action:@selector(postButtonAction:)];
    self.navigationItem.title = @"Review";
    
    // Place all controls in a container view
    self.containerView = [[UIView alloc]
                          initWithFrame:CGRectMake(0,
                                                   64, // StatusBar height + 44 of the navbar height?
                                                   self.view.frame.size.width,
                                                   self.view.frame.size.height
                                                   - (self.tabBarController.tabBar.frame.size.height
                                                      + 64))];
    self.containerView.backgroundColor = [UIColor clearColor];
    [[self view] addSubview:self.containerView];
    
    self.detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 60)];
    [self.detailsLabel setText:[NSString stringWithFormat:@"%i", [self.inviteList count]]];
    [[self containerView] addSubview:self.detailsLabel];
    
    if(inviteList) {
        //self.tView = [[UITableView alloc] initWithFrame:CGRectMake(10, 200, 300, 200) style:UITableViewStylePlain];
        self.tView = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 200) style:UITableViewStylePlain];
        self.tView.frame = self.view.frame;
        
        self.tView.delegate = self;
        self.tView.dataSource = self;
        [[self view] addSubview:self.tView];
    }
}



/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * TableView Delegate Methods
 *
 */
#pragma - markup TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    NSLog([NSString stringWithFormat:@"%i", [self.inviteList count]]);
    NSLog(@"%f", self.view.window.bounds.size.width);
    return [inviteList count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    static NSString *simpleTableIdentifier = @"reusableCell";
    
    TuduInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        cell = [[TuduInviteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

    cell.inviteButton.selected = NO;
    cell.tag = indexPath.row;
    //[cell setUser:curUser];
    
    //cell.textLabel.text = [self.inviteList objectAtIndex:indexPath.row];
    [cell.nameButton setTitle:((NSString *)[self.inviteList objectAtIndex:indexPath.row]) forState:UIControlStateNormal];
    //cell.imageView.image = [UIImage imageNamed:@"geekPic.jpg"];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //return 20.0f;
    return [TuduFriendSelectorCell heightForCell];
    //return 70.0f;
}


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
        [self.inviteList removeObject:cellUser[kTuduUserDisplayNameKey]];
        
        //[Utility unfollowUserEventually:cellUser];
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
 * When POST button is pressed
 *
 */
-(void)postButtonAction:(id)sender
{
    NSLog(@"Post");
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
