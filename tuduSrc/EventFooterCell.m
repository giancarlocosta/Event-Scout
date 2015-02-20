//
//  EventFooterCell.m
//

#import "EventFooterCell.h"
#import "TuduProfileImageView.h"
#import "Utility.h"



@interface EventFooterCell ()
@end


@implementation EventFooterCell
@synthesize containerView;
@synthesize event;
@synthesize buttons;
@synthesize attendButton;
@synthesize commentButton;
@synthesize invitedListButton;
@synthesize attendingListButton;
@synthesize commentListButton;
@synthesize delegate;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier buttons:(EventFooterButtons)otherButtons {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [EventFooterCell validateButtons:otherButtons];
        buttons = otherButtons;
        
        // Initialization code
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        
        self.backgroundColor = [UIColor clearColor];
        
        // translucent portion
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.bounds.size.width, CELL_HEIGHT)];
        [self addSubview:self.containerView];
        //[self.containerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundComments.png"]]];
        [self.containerView setBackgroundColor:[UIColor blackColor]];
        
        if (self.buttons & EventFooterButtonsAttend) {
            // attend button
            attendButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView addSubview:self.attendButton];
            [self.attendButton setFrame:CGRectMake(50, 35, BUTTONS_WIDTH, BUTTONS_HEIGHT)];
            [self.attendButton setBackgroundColor:[UIColor clearColor]];
            [self.attendButton setTitle:@"I'm Going" forState:UIControlStateNormal];
            [self.attendButton setTitle:@"v Going" forState:UIControlStateSelected];
            [self.attendButton setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
            [self.attendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [self.attendButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f] forState:UIControlStateNormal];
            [self.attendButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.750f] forState:UIControlStateSelected];
            [self.attendButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
            [[self.attendButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
            [[self.attendButton titleLabel] setFont:[UIFont systemFontOfSize:14.0f]];
            [[self.attendButton titleLabel] setMinimumScaleFactor:0.8f];
            [[self.attendButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
            [self.attendButton setAdjustsImageWhenHighlighted:NO];
            [self.attendButton setAdjustsImageWhenDisabled:NO];
            [self.attendButton setBackgroundImage:[UIImage imageNamed:@"ButtonFooterCell.png"] forState:UIControlStateNormal];
            [self.attendButton setBackgroundImage:[UIImage imageNamed:@"ButtonFooterCellClicked.png"] forState:UIControlStateSelected];
            [self.attendButton setSelected:NO];
        }
        
        if (self.buttons & EventFooterButtonsComment) {
            // comments button
            commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView addSubview:self.commentButton];
            [self.commentButton setFrame:CGRectMake( self.attendButton.frame.origin.x + self.attendButton.frame.size.width, 35.0f, BUTTONS_WIDTH, BUTTONS_HEIGHT)];
            [self.commentButton setBackgroundColor:[UIColor clearColor]];
            [self.commentButton setTitle:@"Comment" forState:UIControlStateNormal];
            [self.commentButton setTitle:@"Comment" forState:UIControlStateSelected];
            [self.commentButton setTitleColor:[UIColor colorWithRed:0.369f green:0.271f blue:0.176f alpha:1.0f] forState:UIControlStateNormal];
            [self.commentButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f] forState:UIControlStateNormal];
            [self.commentButton setTitleEdgeInsets:UIEdgeInsetsMake( -4.0f, 0.0f, 0.0f, 0.0f)];
            [[self.commentButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
            [[self.commentButton titleLabel] setFont:[UIFont systemFontOfSize:14.0f]];
            [[self.commentButton titleLabel] setMinimumScaleFactor:0.8f];
            [[self.commentButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
            [self.commentButton setBackgroundImage:[UIImage imageNamed:@"ButtonFooterCell.png"] forState:UIControlStateNormal];
            [self.commentButton setSelected:NO];
        }
        
        // Setup the list buttons
        [self setupFooterButtons];
        

        CALayer *layer = [containerView layer];
        layer.backgroundColor = [[UIColor whiteColor] CGColor];
        layer.masksToBounds = NO;
        layer.shadowRadius = 1.0f;
        layer.shadowOffset = CGSizeMake( 0.0f, 2.0f);
        layer.shadowOpacity = 0.5f;
        layer.shouldRasterize = YES;
        layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake( 0.0f, containerView.frame.size.height - 4.0f, containerView.frame.size.width, 4.0f)].CGPath;
    }

    return self;
}


#pragma mark - EventFooterCell

+ (CGFloat)heightForFooterCell {
    return CELL_HEIGHT;
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
    /*
    if (enable) {
        [self.attendButton removeTarget:self action:@selector(didTapAttendEventButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.attendButton addTarget:self action:@selector(didTapAttendEventButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
     */
    if (enable) {
        [self.attendButton addTarget:self action:@selector(didTapAttendEventButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.attendButton removeTarget:self action:@selector(didTapAttendEventButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setTheEvent:(PFObject *)theEvent {
    self.event = theEvent;
    
    //[query includeKey:kTuduEventUserKey];
    PFUser *user = [self.event objectForKey:kTuduEventUserKey];
    
    CGFloat constrainWidth = containerView.bounds.size.width;
    
    if (self.buttons & EventFooterButtonsComment) {
        constrainWidth = self.commentButton.frame.origin.x;
        [self.commentButton addTarget:self action:@selector(didTapCommentOnEventButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & EventFooterButtonsAttend) {
        constrainWidth = self.attendButton.frame.origin.x;
        [self.attendButton addTarget:self action:@selector(didTapAttendEventButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.attendingListButton addTarget:self action:@selector(didTapAttendingListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.commentListButton addTarget:self action:@selector(didTapCommentListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.invitedListButton addTarget:self action:@selector(didTapInvitedListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setNeedsDisplay];
}



#pragma mark - ()

+ (void)validateButtons:(EventFooterButtons)buttons {
    if (buttons == EventFooterButtonsNone) {
        [NSException raise:NSInvalidArgumentException format:@"Buttons must be set before initializing PAPPhotoHeaderView."];
    }
}


- (void)didTapAttendEventButtonAction:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(eventFooterCell:didTapAttendEventButton:event:)]) {
        [delegate eventFooterCell:self didTapAttendEventButton:button event:self.event];
    }
}

- (void)didTapCommentOnEventButtonAction:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(eventFooterCell:didTapCommentOnEventButton:event:)]) {
        [delegate eventFooterCell:self didTapCommentOnEventButton:button event:self.event];
    }
}

- (void)didTapAttendingListButtonAction:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(eventFooterCell:didTapAttendingListButton:event:)]) {
        [delegate eventFooterCell:self didTapAttendingListButton:button event:self.event];
    }
}

- (void)didTapCommentListButtonAction:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(eventFooterCell:didTapCommentListButton:event:)]) {
        [delegate eventFooterCell:self didTapCommentListButton:button event:self.event];
    }
}

- (void)didTapInvitedListButtonAction:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(eventFooterCell:didTapInvitedListButton:event:)]) {
        [delegate eventFooterCell:self didTapInvitedListButton:button event:self.event];
    }
}




// PRIVATE METHODS

-(void) setupFooterButtons {
    
    // Attending List Button
    self.attendingListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [containerView addSubview:self.attendingListButton];
    [self.attendingListButton setFrame:CGRectMake(50.0f, 5.0f, BUTTONS_WIDTH, BUTTONS_HEIGHT)];
    [self.attendingListButton setBackgroundColor:[UIColor clearColor]];
    [self.attendingListButton setTitle:@"Attending" forState:UIControlStateNormal];
    [self.attendingListButton setTitleColor:[ThemeAndStyle greenColor] forState:UIControlStateNormal];
    [self.attendingListButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.attendingListButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [[self.attendingListButton titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
    [[self.attendingListButton titleLabel] setMinimumScaleFactor:0.8f];
    //[[self.attendingListButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    self.attendingListButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.attendingListButton setAdjustsImageWhenHighlighted:NO];
    [self.attendingListButton setAdjustsImageWhenDisabled:NO];
    [self.attendingListButton setSelected:NO];
    
    
    // Comment List Button
    self.commentListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [containerView addSubview:self.commentListButton];
    [self.commentListButton setFrame:CGRectMake(self.attendingListButton.frame.origin.x + self.attendingListButton.frame.size.width, 5.0f, BUTTONS_WIDTH, BUTTONS_HEIGHT)];
    [self.commentListButton setBackgroundColor:[UIColor clearColor]];
    [self.commentListButton setTitle:@"Comments" forState:UIControlStateNormal];
    [self.commentListButton setTitleColor:[ThemeAndStyle greenColor] forState:UIControlStateNormal];;
    [self.commentListButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.commentListButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [[self.commentListButton titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
    [[self.commentListButton titleLabel] setMinimumScaleFactor:0.8f];
    //[[self.commentListButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    self.commentListButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.commentListButton setAdjustsImageWhenHighlighted:NO];
    [self.commentListButton setAdjustsImageWhenDisabled:NO];
    [self.commentListButton setSelected:NO];
    
    
    // Invited List Button
    self.invitedListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [containerView addSubview:self.invitedListButton];
    [self.invitedListButton setFrame:CGRectMake(self.commentListButton.frame.origin.x + self.commentListButton.frame.size.width, 5.0f, BUTTONS_WIDTH, BUTTONS_HEIGHT)];
    [self.invitedListButton setBackgroundColor:[UIColor clearColor]];
    [self.invitedListButton setTitle:@"Invited" forState:UIControlStateNormal];
    [self.invitedListButton setTitleColor:[ThemeAndStyle greenColor] forState:UIControlStateNormal];
    [self.invitedListButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.invitedListButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [[self.invitedListButton titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
    [[self.invitedListButton titleLabel] setMinimumScaleFactor:0.8f];
    //[[self.invitedListButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    self.invitedListButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.invitedListButton setAdjustsImageWhenHighlighted:NO];
    [self.invitedListButton setAdjustsImageWhenDisabled:NO];
    [self.invitedListButton setSelected:NO];
}


@end
