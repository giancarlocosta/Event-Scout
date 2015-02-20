//
//  EventDisplayCell.m
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//

#import "EventDisplayCell.h"
#import "Utility.h"

@implementation EventDisplayCell
@synthesize eventInfoContainer;
@synthesize eventButton;
@synthesize eventTitleLabel;
@synthesize eventDateLabel;
@synthesize eventLocationLabel;
@synthesize tapForDeatilsLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        
        self.backgroundColor = [UIColor clearColor];
        
        /*
        UIView *dropshadowView = [[UIView alloc] init];
        dropshadowView.backgroundColor = [UIColor whiteColor];
        dropshadowView.frame = CGRectMake( 20.0f, -44.0f, 280.0f, 322.0f);
        [self.contentView addSubview:dropshadowView];
        
        CALayer *layer = dropshadowView.layer;
        layer.masksToBounds = NO;
        layer.shadowRadius = 3.0f;
        layer.shadowOpacity = 0.5f;
        layer.shadowOffset = CGSizeMake( 0.0f, 1.0f);
        layer.shouldRasterize = YES;
         */
        
        self.imageView.frame = CGRectMake( 0.0f, 0.0f, self.bounds.size.width, CELL_HEIGHT);
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.contentView bringSubviewToFront:self.imageView];
        
        
        //Add the event info labels
        self.eventInfoContainer = [[UIView alloc] initWithFrame:self.imageView.frame];
        
        self.eventTitleLabel = [[UILabel alloc] initWithFrame:(CGRectMake(50.0f, 10.f, self.bounds.size.width, 30.f))];
        [self.eventTitleLabel setText:@"Title of event"];
        self.eventTitleLabel.textAlignment = UITextAlignmentLeft; //UITextAlignmentCenter; //only works if UITableViewCellStyle is DEFAULT
        self.eventTitleLabel.textColor = [UIColor blackColor];
        [self.eventTitleLabel setFont:[UIFont systemFontOfSize:24]];
        
        
        self.eventLocationLabel = [[UILabel alloc] initWithFrame:(CGRectMake(50.0f, 45.0f, self.bounds.size.width, 15.f))];
        [self.eventLocationLabel setText:@"Location of event"];
        self.eventLocationLabel.textAlignment = UITextAlignmentLeft;
        self.eventLocationLabel.textColor = [ThemeAndStyle blueGrayColor];
        [self.eventLocationLabel setFont:[UIFont systemFontOfSize:12]];
        
        self.eventDateLabel = [[UILabel alloc] initWithFrame:(CGRectMake(50.0f, 60.f, self.bounds.size.width, 15.f))];
        [self.eventDateLabel setText:@"Date of event"];
        self.eventDateLabel.textAlignment = UITextAlignmentLeft;
        self.eventDateLabel.textColor = [ThemeAndStyle blueGrayColor];
        [self.eventDateLabel setFont:[UIFont systemFontOfSize:12]];
        
        /*
        self.tapForDeatilsLabel = [[UILabel alloc] initWithFrame:(CGRectMake(0.0f, self.eventInfoContainer.frame.size.height - 30, self.bounds.size.width, 20.f))];
        [self.tapForDeatilsLabel setText:@"Tap For Details"];
        self.tapForDeatilsLabel.textAlignment = UITextAlignmentCenter;
        self.tapForDeatilsLabel.textColor = [UIColor grayColor];
        [self.tapForDeatilsLabel setFont:[UIFont systemFontOfSize:10]];
         */
        
        [eventInfoContainer addSubview:eventTitleLabel];
        [eventInfoContainer addSubview:eventLocationLabel];
        [eventInfoContainer addSubview:eventDateLabel];
        [eventInfoContainer addSubview:tapForDeatilsLabel];
        
        [self.contentView addSubview:eventInfoContainer];
        
        self.eventButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.eventButton.frame = CGRectMake( 0.0f, 0.0f, self.bounds.size.width, CELL_HEIGHT);
        self.eventButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.eventButton];
        
    }
    return self;
}

+ (CGFloat)heightForDisplayCell {
    return CELL_HEIGHT;
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, CELL_HEIGHT);
    self.eventButton.frame = CGRectMake( 0.0f, 0.0f, self.bounds.size.width, CELL_HEIGHT);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
