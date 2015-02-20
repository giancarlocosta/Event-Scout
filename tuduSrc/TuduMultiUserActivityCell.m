//
//  TuduMultiUserActivityCell.m
//  Tudu
//

#import "TuduMultiUserActivityCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "TuduProfileImageView.h"
#import "TuduActivityFeedViewController.h"

static TTTTimeIntervalFormatter *timeFormatter;

@interface TuduMultiUserActivityCell ()

@end

@implementation TuduMultiUserActivityCell


#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        horizontalTextSpace = [TuduMultiUserActivityCell horizontalTextSpaceForInsetWidth:0];
        
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }
        
        // Create subviews and set cell properties
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        self.hasEvent = NO; //No until one is set
        
        self.toUserButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.toUserButton setBackgroundColor:[UIColor clearColor]];
        [self.toUserButton addTarget:self action:@selector(didTapToUserButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:self.toUserButton];
        
        self.eventButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.eventButton setBackgroundColor:[UIColor clearColor]];
        [self.eventButton addTarget:self action:@selector(didTapEventButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:self.eventButton];
    }
    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Layout the activity image and show it if it is not nil (no image for the follow activity).
    // Note that the image view is still allocated and ready to be dispalyed since these cells
    // will be reused for all types of activity.
    [self.eventButton setFrame:CGRectMake( [UIScreen mainScreen].bounds.size.width - 46.0f, 8.0f, 33.0f, 33.0f)];
    
    // Add activity image if one was set
    if (self.hasEvent) {
        [self.eventButton setHidden:NO];
    } else {
        [self.eventButton setHidden:YES];
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
    self.activity = activity;
    
    // Event Button should not show (nil) is Activity type is follow or join
    if ([[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeFollow] || [[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeJoined]) {
        [self setActivityEvent:nil];
    } else {
        [self setActivityEvent:activity[kTuduActivityEventKey]];
    }
    
    self.user = activity[kTuduActivityFromUserKey];
    
    if(self.user.objectId == [PFUser currentUser].objectId){
        
    }
    
    NSString *activityString;
    
    if([self.activity[kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeFollow]) {
        activityString = @"is following ";
        [self.toUserButton setTitle:activity[kTuduActivityToUserKey] forState:UIControlStateNormal];
    } else if ([self.activity[kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeAttend]) {
        activityString = @"is going to ";
        [self.toUserButton setTitle:[NSString stringWithFormat:@"%@'s", activity[kTuduActivityToUserKey]] forState:UIControlStateNormal];
        [self.eventButton setTitle:[NSString stringWithFormat:@"event: %@", (activity[kTuduActivityEventKey])[kTuduEventTitleKey]] forState:UIControlStateNormal];
    }
    
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
    horizontalTextSpace = [TuduMultiUserActivityCell horizontalTextSpaceForInsetWidth:insetWidth];
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
    CGFloat horizontalTextSpace = [TuduMultiUserActivityCell horizontalTextSpaceForInsetWidth:cellInset];
    
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

- (void)setActivityEvent:(PFObject *)event{
    if (event) {
        [self.eventButton setTitle:event[kTuduEventTitleKey] forState:UIControlStateNormal];
        [self setHasEvent:YES];
    } else {
        [self setHasEvent:NO];
    }
}
         
         
- (void)didTapEventButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapEventButton:)]) {
        [self.delegate cell:self didTapEventButton:self.activity[kTuduActivityEventKey]];
    }
}
- (void)didTapToUserButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapToUserButton:)]) {
        [self.delegate cell:self didTapToUserButton:self.activity[kTuduActivityToUserKey]];
    }
}

@end