//
//  TuduEventDetailsViewController
//  tudu
//
//  Created by Gian Costa on 9/10/14.
//
//

#import "TuduEventDetailsViewController.h"
#import "EventDisplayCell.h"
#import "TuduNumberTitleButton.h"
#import "TuduFollowFriendsListViewController.h"
#import "TuduInviteFriendsListViewController.h"
#import "TuduEventEditorViewController.h"
#import "TuduCommentsViewController.h"

@interface TuduEventDetailsViewController ()

@end

@implementation TuduEventDetailsViewController
@synthesize presentTextViewFirst;
@synthesize event;

- (id)initWithEvent:(PFObject *)aEvent userCanEditEvent:(BOOL)canEdit {
    self = [super init];
    if (self) {
        self.event = aEvent;
        self.userCanEditEvent = canEdit;
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        scrollView.contentOffset = CGPointMake(0, 0);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[ThemeAndStyle blueGrayColor]];
    self.scroll.delegate = self;
    self.scroll = [[UIScrollView alloc]
                   initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scroll.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height * 2);
    [self.scroll setBackgroundColor:[UIColor clearColor]];
    
    /*
    UIView *dropshadowView = [[UIView alloc] init];
    dropshadowView.backgroundColor = [UIColor whiteColor];
    dropshadowView.frame = CGRectMake( 20.0f, -44.0f, 280.0f, 322.0f);
    [scroll addSubview:dropshadowView];
     
    
    CALayer *layer = dropshadowView.layer;
    layer.masksToBounds = NO;
    layer.shadowRadius = 3.0f;
    layer.shadowOpacity = 0.5f;
    layer.shadowOffset = CGSizeMake( 0.0f, 1.0f);
    layer.shouldRasterize = YES;
     */
    
    /*
     * Setup the header section
     *
     */
    self.headerView = [[EventHeaderView alloc]
                                   initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f) buttons:EventHeaderButtonsDefault];
    self.headerView.containerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 44.0f);
    self.headerView.delegate = self;
    self.headerView.avatarImageView.profileImageView.image = [UIImage imageNamed:@"AvatarPlaceholder.png"];
    [self.headerView setBackgroundColor:[UIColor clearColor]];
    [self.headerView setTheEvent:self.event];
    
    /*
     * Setup the Event Details/picture section
     *
     */
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 200.0f)];
    self.imageView.frame = CGRectMake( 0.0f,
                                      self.headerView.frame.origin.x + self.headerView.frame.size.height,
                                      self.view.frame.size.width,
                                      150.0f);
    self.imageView.backgroundColor = [UIColor clearColor];
    //[self.imageView setImage:[UIImage imageNamed:@"Basketball.jpg" ]];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //[scroll bringSubviewToFront:self.imageView];
    
    //Add the event info labels
    self.detailsContainer = [[UIView alloc] initWithFrame:self.imageView.frame];
    self.detailsContainer.backgroundColor = [ThemeAndStyle lightTurquoiseColor];
    
    self.eventTitleLabel = [[UILabel alloc] initWithFrame:(CGRectMake(0.0f, 0.0f,
                                                                      self.imageView.frame.size.width, 40.f))];
    [self.eventTitleLabel setText:event[kTuduEventTitleKey]];
    self.eventTitleLabel.textAlignment = UITextAlignmentCenter; //only works if UITableViewCellStyle is DEFAULT
    self.eventTitleLabel.textColor = [UIColor blackColor];
    [self.eventTitleLabel setFont:[UIFont systemFontOfSize:30]];
    
    
    self.eventLocationLabel = [[UILabel alloc] initWithFrame:(CGRectMake(0.0f, 70.f,
                                                                         self.imageView.frame.size.width, 20.f))];
    [self.eventLocationLabel setText:event[kTuduEventLocationKey]];
    self.eventLocationLabel.textAlignment = UITextAlignmentCenter;
    self.eventLocationLabel.textColor = [UIColor blackColor];
    [self.eventLocationLabel setFont:[UIFont systemFontOfSize:20]];
    
    self.eventDateLabel = [[UILabel alloc] initWithFrame:(CGRectMake(0.0f, 100.f,
                                                                     self.imageView.frame.size.width, 20.f))];
    [self.eventDateLabel setText:event[kTuduEventDateKey]];
    self.eventDateLabel.textAlignment = UITextAlignmentCenter;
    self.eventDateLabel.textColor = [UIColor blackColor];
    [self.eventDateLabel setFont:[UIFont systemFontOfSize:10]];
    
    [self.detailsContainer addSubview:self.self.imageView];
    [self.detailsContainer addSubview:self.eventTitleLabel];
    [self.detailsContainer addSubview:self.eventLocationLabel];
    [self.detailsContainer addSubview:self.eventDateLabel];
 
    
    /*
     * Setup the Buttons sections
     *
     */
    
    self.listButtonsContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                         self.detailsContainer.frame.origin.y + self.detailsContainer.frame.size.height,
                                                                         self.imageView.frame.size.width, LIST_CONTAINER_HEIGHT)];
    self.listButtonsContainer.backgroundColor = [UIColor whiteColor];
    self.actionsButtonsContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                            self.listButtonsContainer.frame.origin.y + self.listButtonsContainer.frame.size.height,
                                                                            self.imageView.frame.size.width,
                                                                            LIST_CONTAINER_HEIGHT)];
    self.actionsButtonsContainer.backgroundColor = [UIColor whiteColor];
    //[self.actionsButtonsContainer.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    //[self.actionsButtonsContainer.layer setBorderWidth:1.0];
    
    [self setupListButtons];
    [self setupActionsButtons];
  
    
    /*
     * Setup the Description sections
     *
     */
    
    self.descriptionContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                            self.actionsButtonsContainer.frame.origin.y + self.actionsButtonsContainer.frame.size.height,
                                                                            self.imageView.frame.size.width,
                                                                            60.f)];
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.imageView.frame.size.width, 20)];
    self.descriptionLabel.text = @"Description";
    self.descriptionLabel.textColor = [ThemeAndStyle lightTurquoiseColor];
    self.descriptionContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, self.imageView.frame.size.width - 2 * 10, 400)];
    self.descriptionContentLabel.text = event[kTuduEventDescriptionKey];
    [self.descriptionContentLabel setFont:[UIFont fontWithName:@"Arial" size:14.0f]];
    [self.descriptionContentLabel setBackgroundColor:[UIColor colorWithRed:0.41 green:0.49f blue:0.59f alpha:1.0f]];
    [self.descriptionContentLabel setLineBreakMode:UILineBreakModeWordWrap];
    self.descriptionContentLabel.numberOfLines = 0;
    
    //[self resizeLabel:self.descriptionContentLabel];
    
    [self.descriptionContainer addSubview:self.descriptionLabel];
    [self.descriptionContainer addSubview:self.descriptionContentLabel];
    
    [self.scroll addSubview:self.headerView];
    [self.scroll addSubview:self.detailsContainer];
    [self.scroll addSubview:self.listButtonsContainer];
    [self.scroll addSubview:self.actionsButtonsContainer];
    [self.scroll addSubview:self.descriptionContainer];
    
    // Readjust scroll view size
    //self.scroll.contentSize = CGSizeMake(self.view.frame.size.width, self.descriptionContainer.frame.origin.y + self.descriptionContainer.frame.size.height);

    [self.view addSubview:self.scroll];
    
    //scroll.pagingEnabled = YES; // Stops the scroll on a WHOLE page. Can't stop at random spot
    //[scroll release];
}





-(void) setupListButtons {
    
    // Attending List Button
    self.attendingListButton = [[TuduNumberTitleButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                                       0.0f,
                                                                                       self.view.frame.size.width/3,
                                                                                       LIST_CONTAINER_HEIGHT)];
    [self.attendingListButton.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [self.attendingListButton.layer setBorderWidth:1.0f];
    [self.attendingListButton setSelected:NO];
    [self.attendingListButton setButtonTitleValue:@"ATTENDING"];
    [self.attendingListButton setButtonNumberValue:[[TuduCache sharedCache] attendCountForEvent:self.event]];
    
    // Invited List Button
    self.invitedListButton = [[TuduNumberTitleButton alloc] initWithFrame:CGRectMake(self.attendingListButton.frame.size.width,
                                                                                     0.0f,
                                                                                     self.view.frame.size.width/3,
                                                                                     LIST_CONTAINER_HEIGHT)];
    [self.invitedListButton.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [self.invitedListButton.layer setBorderWidth:1.0f];
    [self.invitedListButton setSelected:NO];
    [self.invitedListButton setButtonTitleValue:@"INVITED"];
    [self.invitedListButton setButtonNumberValue:[[TuduCache sharedCache] inviteCountForEvent:self.event]];
    
    // Comment List Button
    self.commentListButton = [[TuduNumberTitleButton alloc] initWithFrame:CGRectMake(self.invitedListButton.frame.origin.x +
                                                                                     self.invitedListButton.frame.size.width,
                                                                                     0.0f,
                                                                                     self.view.frame.size.width/3,
                                                                                     LIST_CONTAINER_HEIGHT)];
    [self.commentListButton.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [self.commentListButton.layer setBorderWidth:1.0f];
    [self.commentListButton setSelected:NO];
    [self.commentListButton setButtonTitleValue:@"COMMENTS"];
    [self.commentListButton setButtonNumberValue:[[TuduCache sharedCache] commentCountForEvent:self.event]];
    
    [self.listButtonsContainer addSubview:self.attendingListButton];
    [self.listButtonsContainer addSubview:self.invitedListButton];
    [self.listButtonsContainer addSubview:self.commentListButton];
    
    // Add Action listeners
    [self.attendingListButton addTarget:self action:@selector(didTapAttendingListButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.commentListButton addTarget:self action:@selector(didTapCommentListButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.invitedListButton addTarget:self action:@selector(didTapInvitedListButton:) forControlEvents:UIControlEventTouchUpInside];
}


- (void) setupActionsButtons {
    // attend button
    self.attendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.attendButton setFrame:CGRectMake(0, 5, self.view.frame.size.width/3, BUTTONS_HEIGHT)];
    [self.attendButton setBackgroundColor:[UIColor clearColor]];
    [self.attendButton setTitle:@"I'm Going" forState:UIControlStateNormal];
    [self.attendButton setTitle:@"v Going" forState:UIControlStateSelected];
    [self.attendButton setTitleColor:[UIColor colorWithRed:0.369f green:0.271f blue:0.176f alpha:1.0f] forState:UIControlStateNormal];
    [self.attendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.attendButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f] forState:UIControlStateNormal];
    [self.attendButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.750f] forState:UIControlStateSelected];
    [self.attendButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [[self.attendButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    [[self.attendButton titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
    [[self.attendButton titleLabel] setMinimumScaleFactor:0.8f];
    [[self.attendButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    [self.attendButton setAdjustsImageWhenHighlighted:NO];
    [self.attendButton setAdjustsImageWhenDisabled:NO];
    [self.attendButton setBackgroundImage:[UIImage imageNamed:@"ButtonFooterCell.png"] forState:UIControlStateNormal];
    [self.attendButton setBackgroundImage:[UIImage imageNamed:@"ButtonFooterCellClicked.png"] forState:UIControlStateSelected];
    [self.attendButton setSelected:NO];
    [self setAttendStatus:[[TuduCache sharedCache] isEventAttendedByCurrentUser:event]];
    
    // invite button
    self.inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.inviteButton setFrame:CGRectMake(self.view.frame.size.width/3, 5, self.view.frame.size.width/3, BUTTONS_HEIGHT)];
    [self.inviteButton setBackgroundColor:[UIColor clearColor]];
    [self.inviteButton setTitle:@"Invite" forState:UIControlStateNormal];
    [self.inviteButton setTitle:@"Invite" forState:UIControlStateSelected];
    [self.inviteButton setTitleColor:[UIColor colorWithRed:0.369f green:0.271f blue:0.176f alpha:1.0f] forState:UIControlStateNormal];
    [self.inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.inviteButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f] forState:UIControlStateNormal];
    [self.inviteButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.750f] forState:UIControlStateSelected];
    [self.inviteButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [[self.inviteButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    [[self.inviteButton titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
    [[self.inviteButton titleLabel] setMinimumScaleFactor:0.8f];
    [[self.inviteButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    [self.inviteButton setAdjustsImageWhenHighlighted:NO];
    [self.inviteButton setAdjustsImageWhenDisabled:NO];
    [self.inviteButton setBackgroundImage:[UIImage imageNamed:@"ButtonFooterCell.png"] forState:UIControlStateNormal];
    [self.inviteButton setBackgroundImage:[UIImage imageNamed:@"ButtonFooterCellClicked.png"] forState:UIControlStateSelected];
    [self.inviteButton setSelected:NO];
    if([self.event[kTuduEventPrivacyTypeKey] isEqualToString:kTuduEventPrivacyTypeHostInvite])
        self.inviteButton.hidden = YES;
    
    // comments button
    self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.commentButton setFrame:CGRectMake( (self.view.frame.size.width/3) * 2, 5.0f, self.view.frame.size.width/3, BUTTONS_HEIGHT)];
    [self.commentButton setBackgroundColor:[UIColor clearColor]];
    [self.commentButton setTitle:@"Comment" forState:UIControlStateNormal];
    [self.commentButton setTitle:@"Comment" forState:UIControlStateSelected];
    [self.commentButton setTitleColor:[UIColor colorWithRed:0.369f green:0.271f blue:0.176f alpha:1.0f] forState:UIControlStateNormal];
    [self.commentButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f] forState:UIControlStateNormal];
    [self.commentButton setTitleEdgeInsets:UIEdgeInsetsMake( -4.0f, 0.0f, 0.0f, 0.0f)];
    [[self.commentButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
    [[self.commentButton titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
    [[self.commentButton titleLabel] setMinimumScaleFactor:0.8f];
    [[self.commentButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    [self.commentButton setBackgroundImage:[UIImage imageNamed:@"ButtonFooterCell.png"] forState:UIControlStateNormal];
    [self.commentButton setSelected:NO];
    
    // Edit button
    self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.detailsContainer addSubview:self.editButton];
    [self.editButton setFrame:CGRectMake( self.detailsContainer.frame.size.width - 21, 0, 20, 20)];
    [self.editButton setBackgroundColor:[UIColor clearColor]];
    [self.editButton setTitle:@"+" forState:UIControlStateNormal];
    [self.editButton setTitle:@"+" forState:UIControlStateSelected];
    [self.editButton setTitleColor:[ThemeAndStyle salmonColor] forState:UIControlStateNormal];
    [self.editButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f] forState:UIControlStateNormal];
    [self.editButton setTitleEdgeInsets:UIEdgeInsetsMake( -4.0f, 0.0f, 0.0f, 0.0f)];
    [[self.editButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
    [[self.editButton titleLabel] setFont:[UIFont systemFontOfSize:26.0f]];
    [[self.editButton titleLabel] setMinimumScaleFactor:0.8f];
    [[self.editButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    //[self.editButton setBackgroundImage:[UIImage imageNamed:@"ButtonFooterCell.png"] forState:UIControlStateNormal];
    [self.editButton setSelected:NO];
    if(!self.userCanEditEvent)
        self.editButton.hidden = YES;
    
    
    // Add selectors
    [self.attendButton addTarget:self action:@selector(didTapAttendEventButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.inviteButton addTarget:self action:@selector(didTapInviteToEventButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.commentButton addTarget:self action:@selector(didTapCommentOnEventButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.editButton addTarget:self action:@selector(didTapEditEventButton:) forControlEvents:UIControlEventTouchUpInside];
    

    
    [self.actionsButtonsContainer addSubview:self.attendButton];
    [self.actionsButtonsContainer addSubview:self.inviteButton];
    [self.actionsButtonsContainer addSubview:self.commentButton];
    
}


- (void)setAttendStatus:(BOOL)attending {
    [self.attendButton setSelected:attending];
    
    if (attending) {
        [self.attendButton setTitleEdgeInsets:UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0f)];
        [[self.attendButton titleLabel] setShadowOffset:CGSizeMake(0.0f, -1.0f)];
    } else {
        [self.attendButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [[self.attendButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    }
}

- (void)shouldEnableAttendButton:(BOOL)enable {
    if (enable) {
        [self.attendButton addTarget:self action:@selector(didTapAttendEventButton:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.attendButton removeTarget:self action:@selector(didTapAttendEventButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}


/*!
 Sent to the delegate when the like event button is tapped
 @param photo the PFObject for the photo that is being liked or disliked
 */
-(void)didTapAttendEventButton:(id)sender {
    
    NSLog(@"--Tapped Attend for the event: %@", self.event[@"title"]);
    
    // Disable the button so users cannot send duplicate requests
    [self shouldEnableAttendButton:NO];
    BOOL attended = !self.attendButton.selected;
    [self setAttendStatus:attended];
    
    NSString *originalButtonTitle = self.attendButton.titleLabel.text;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    NSNumber *attendCount = [numberFormatter
                             numberFromString:self.attendingListButton.buttonNumberLabel.text];
    // Update Cache
    if (attended) {
        attendCount = [NSNumber numberWithInt:[attendCount intValue] + 1];
        [[TuduCache sharedCache] incrementAttenderCountForEvent:self.event];
    } else {
        if ([attendCount intValue] > 0) {
            attendCount = [NSNumber numberWithInt:[attendCount intValue] - 1];
        }
        [[TuduCache sharedCache] decrementAttenderCountForEvent:self.event];
    }
    
    [[TuduCache sharedCache] setEventIsAttendedByCurrentUser:self.event attended:attended];
    
    // Update Attending List number
    [self.attendingListButton setButtonNumberValue:attendCount];
    
    // Add or Remove Attend Activity in database
    if (attended) {
        [Utility attendEventInBackground:self.event block:^(BOOL succeeded, NSError *error) {
            [self shouldEnableAttendButton:YES];
            [self setAttendStatus:succeeded];
            
            if (!succeeded) {
                [self.attendButton setTitle:originalButtonTitle forState:UIControlStateNormal];
            }
        }];
    } else {
        [Utility unattendEventInBackground:self.event block:^(BOOL succeeded, NSError *error) {
            [self shouldEnableAttendButton:YES];
            [self setAttendStatus:!succeeded];
            if (!succeeded) {
                [self.attendButton setTitle:originalButtonTitle forState:UIControlStateNormal];
            }
        }];
    }
}


/*!
 Sent to the delegate when the comment on event button is tapped
 @param photo the PFObject for the photo that will be commented on
 */
-(void)didTapCommentOnEventButton : (id) sender {
    NSLog(@"INSIDE");
    TuduCommentsViewController *commentsVC = [[TuduCommentsViewController alloc] initWithEvent:self.event];
    [self.navigationController pushViewController:commentsVC animated:YES];
}

/*!
 Sent to the delegate when the comment on event button is tapped
 @param photo the PFObject for the photo that will be commented on
 */
-(void)didTapAttendingListButton : (id)sender {
    TuduFollowFriendsListViewController *attendingListVC = [[TuduFollowFriendsListViewController alloc] initWithStyle:UITableViewStylePlain];
    attendingListVC.event = event;
    attendingListVC.searchType = @"attendingList";
    
    [self.navigationController pushViewController:attendingListVC animated:YES];
}


/*!
 Sent to the delegate when the comment on event button is tapped
 @param photo the PFObject for the photo that will be commented on
 */
-(void)didTapInvitedListButton : (id)sender {
    
    TuduFollowFriendsListViewController *attendingListVC = [[TuduFollowFriendsListViewController alloc] initWithStyle:UITableViewStylePlain];
    attendingListVC.event = event;
    attendingListVC.searchType = @"invitedList";
    
    [self.navigationController pushViewController:attendingListVC animated:YES];
}

/*!
 Sent to the delegate when the comment on event button is tapped
 @param photo the PFObject for the photo that will be commented on
 */
-(void)didTapCommentListButton : (id)sender {
    
    TuduCommentsViewController *commentsVC = [[TuduCommentsViewController alloc] initWithEvent:self.event];
    [self.navigationController pushViewController:commentsVC animated:YES];
}

-(void)didTapEditEventButton : (id)sender {
    TuduEventEditorViewController *editEventVC = [[TuduEventEditorViewController alloc] initWithEvent:self.event];
    [self.navigationController pushViewController:editEventVC animated:YES];
}

-(void)didTapInviteToEventButton : (id)sender {
    TuduInviteFriendsListViewController *inviteList = [[TuduInviteFriendsListViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:inviteList animated:YES];
}


- (CGFloat) resizeLabel:(UILabel *)theLabel shrinkViewIfLabelShrinks:(BOOL)canShrink {
    CGRect frame = [theLabel frame];
    CGSize size = [theLabel.text sizeWithFont:theLabel.font
                            constrainedToSize:CGSizeMake(frame.size.width, 9999)
                                lineBreakMode:UILineBreakModeWordWrap];
    CGFloat delta = size.height - frame.size.height;
    frame.size.height = size.height;
    [theLabel setFrame:frame];
    
    CGRect contentFrame = self.descriptionContainer.frame;
    contentFrame.size.height = contentFrame.size.height + delta;
    if(canShrink || delta > 0) {
        [self.descriptionContainer setFrame:contentFrame];
    }
    return delta;
}

- (CGFloat) resizeLabel:(UILabel *)theLabel {
    return [self resizeLabel:theLabel shrinkViewIfLabelShrinks:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
