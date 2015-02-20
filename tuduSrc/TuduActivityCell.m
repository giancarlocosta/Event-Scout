//
//  TuduActivityCell.m
//

#import "TuduActivityCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "TuduProfileImageView.h"
#import "TuduActivityFeedViewController.h"

static TTTTimeIntervalFormatter *timeFormatter;

@interface TuduActivityCell ()

/*! Private view components */
@property (nonatomic, strong) TuduProfileImageView *activityImageView;
@property (nonatomic, strong) UIButton *activityEventButton;

/*! Flag to remove the right-hand side image if not necessary */
@property (nonatomic) BOOL hasActivityEvent;

/*! Private setter for the right-hand side image */
- (void)setActivityEvent:(PFObject *)event;

/*! Button touch handler for activity image button overlay */
- (void)didTapEventButton:(id)sender;

/*! Static helper method to calculate the space available for text given images and insets */
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth;

@end

@implementation TuduActivityCell


#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        horizontalTextSpace = [TuduActivityCell horizontalTextSpaceForInsetWidth:0];
        
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }
        
        // Create subviews and set cell properties
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.hasActivityEvent = NO; //No until one is set
        
        self.activityEventButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.activityEventButton setBackgroundColor:[UIColor clearColor]];
        [self.activityEventButton addTarget:self action:@selector(didTapEventButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:self.activityEventButton];
    }
    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Layout the activity image and show it if it is not nil (no image for the follow activity).
    // Note that the image view is still allocated and ready to be dispalyed since these cells
    // will be reused for all types of activity.
    
    //[self.activityEventButton setFrame:CGRectMake( [UIScreen mainScreen].bounds.size.width - 46.0f, 8.0f, 33.0f, 33.0f)];
    [self.activityEventButton setFrame:CGRectMake( self.mainView.frame.size.width - 200.0f, self.mainView.frame.size.height - 20, 200.0f, 20.0f)];
    
    // Add activity image if one was set
    if (self.hasActivityEvent) {
        [self.activityEventButton setHidden:NO];
    } else {
        [self.activityEventButton setHidden:YES];
    }
    
    // Change frame of the content text so it doesn't go through the right-hand side picture
    CGSize contentSize = [self.contentLabel.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 72.0f - 46.0f, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin // wordwrap?
                                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}
                                                              context:nil].size;
    [self.contentLabel setFrame:CGRectMake( 46.0f, 10.0f, contentSize.width, contentSize.height)];
    
    // Layout the timestamp label given new vertical
    CGSize timeSize = [self.timeLabel.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 72.0f - 46.0f, CGFLOAT_MAX)
                                                        options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0f]}
                                                        context:nil].size;
    [self.timeLabel setFrame:CGRectMake( 46.0f, self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height + 2.0f, timeSize.width, timeSize.height)];
}


#pragma mark - TuduActivityCell

- (void)setIsNew:(BOOL)isNew {
    if (isNew) {
        [self.mainView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundNewActivity.png"]]];
    } else {
        [self.mainView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundComments.png"]]];
    }
}


- (void)setActivity:(PFObject *)activity {
    // Set the activity property
    _activity = activity;
    if ([[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeFollow] || [[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeJoined]) {
        [self setActivityEvent:nil];
    } else {
        [self setActivityEvent:activity[kTuduActivityEventKey]];
    }
    
    NSString *activityString = [TuduActivityFeedViewController stringForActivityType:(NSString*)[activity objectForKey:kTuduActivityTypeKey]];
    self.user = [activity objectForKey:kTuduActivityFromUserKey];
    
    // Set name button properties and avatar image
    [self.avatarImageView setFile:[self.user objectForKey:kTuduUserProfilePicSmallKey]];
    
    NSString *nameString = NSLocalizedString(@"Someone", @"Text when the user's name is unknown");
    if (self.user && [self.user objectForKey:kTuduUserDisplayNameKey] && [[self.user objectForKey:kTuduUserDisplayNameKey] length] > 0) {
        nameString = [self.user objectForKey:kTuduUserDisplayNameKey];
    }
    
    [self.nameButton setTitle:nameString forState:UIControlStateNormal];
    [self.nameButton setTitle:nameString forState:UIControlStateHighlighted];
    
    // If user is set after the contentText, we reset the content to include padding
    if (self.contentLabel.text) {
        [self setContentText:self.contentLabel.text];
    }
    
    if (self.user) {
        CGSize nameSize = [self.nameButton.titleLabel.text boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX)
                                                                        options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                                     attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]}
                                                                        context:nil].size;
        NSString *paddedString = [TuduBaseTextCell padString:activityString withFont:[UIFont systemFontOfSize:13.0f] toWidth:nameSize.width];
        [self.contentLabel setText:paddedString];
    } else { // Otherwise we ignore the padding and we'll add it after we set the user
        [self.contentLabel setText:activityString];
    }
    
    [self.timeLabel setText:[timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:[activity createdAt]]];
    
    [self setNeedsDisplay];
}

- (void)setCellInsetWidth:(CGFloat)insetWidth {
    [super setCellInsetWidth:insetWidth];
    horizontalTextSpace = [TuduActivityCell horizontalTextSpaceForInsetWidth:insetWidth];
}

// Since we remove the compile-time check for the delegate conforming to the protocol
// in order to allow inheritance, we add run-time checks.
- (id<TuduActivityCellDelegate>)delegate {
    return (id<TuduActivityCellDelegate>)_delegate;
}

- (void)setDelegate:(id<TuduActivityCellDelegate>)delegate {
    if(_delegate != delegate) {
        _delegate = delegate;
    }
}


#pragma mark - ()

+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth {
    return ([UIScreen mainScreen].bounds.size.width - (insetWidth * 2.0f)) - 72.0f - 46.0f;
}

+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content {
    return [self heightForCellWithName:name contentString:content cellInsetWidth:0.0f];
}

+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset {
    CGSize nameSize = [name boundingRectWithSize:CGSizeMake(200.0f, CGFLOAT_MAX)
                                         options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]}
                                         context:nil].size;
    NSString *paddedString = [TuduBaseTextCell padString:content withFont:[UIFont systemFontOfSize:13.0f] toWidth:nameSize.width];
    CGFloat horizontalTextSpace = [TuduActivityCell horizontalTextSpaceForInsetWidth:cellInset];
    
    CGSize contentSize = [paddedString boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin // wordwrap?
                                                 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}
                                                    context:nil].size;
    
    CGFloat singleLineHeight = [@"Test" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}
                                                     context:nil].size.height;
    
    // Calculate the added height necessary for multiline text. Ensure value is not below 0.
    CGFloat multilineHeightAddition = contentSize.height - singleLineHeight;
    
    return 48.0f + fmax(0.0f, multilineHeightAddition);
}

- (void)setActivityEvent:(PFObject *)event {
    if (event) {
        [self.activityEventButton setTitle:event[kTuduEventTitleKey] forState:UIControlStateNormal];
        [self.activityEventButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setHasActivityEvent:YES];
    } else {
        [self setHasActivityEvent:NO];
    }
}

- (void)didTapEventButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapEventButton:)]) {
        PFObject *event = self.activity[kTuduActivityEventKey];
        [self.delegate cell:self didTapEventButton:event];
    }    
}

@end
