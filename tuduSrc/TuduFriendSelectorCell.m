//
//  TuduFriendSelectorCell.m
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//

#import "TuduFriendSelectorCell.h"
#import "TuduFriendSelectorCell.h"
#import "TuduProfileImageView.h"

@interface TuduFriendSelectorCell ()
/*! The cell's views. These shouldn't be modified but need to be exposed for the subclass */
//@property (nonatomic, strong) UIButton *nameButton;
@property (nonatomic, strong) UIButton *avatarImageButton;
@property (nonatomic, strong) TuduProfileImageView *avatarImageView;

@end


@implementation TuduFriendSelectorCell
@synthesize mainView;
@synthesize delegate;
@synthesize user;
@synthesize avatarImageView;
@synthesize avatarImageButton;
@synthesize nameButton;
@synthesize eventLabel;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        mainView = [[UIView alloc] initWithFrame:self.contentView.frame];
        
        //self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundFindFriendsCell.png"]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.avatarImageView = [[TuduProfileImageView alloc] init];
        self.avatarImageView.frame = CGRectMake( 10.0f, 14.0f, 40.0f, 40.0f);
        [self.mainView addSubview:self.avatarImageView];
        
        self.avatarImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.avatarImageButton.backgroundColor = [UIColor clearColor];
        self.avatarImageButton.frame = CGRectMake( 10.0f, 14.0f, 40.0f, 40.0f);
        [self.avatarImageButton addTarget:self action:@selector(didTapUserButtonAction:)
                         forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:self.avatarImageButton];
        
        self.nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.nameButton.backgroundColor = [UIColor clearColor];
        self.nameButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        self.nameButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.nameButton setTitleColor:[UIColor colorWithRed:87.0f/255.0f green:72.0f/255.0f blue:49.0f/255.0f alpha:1.0f]
                              forState:UIControlStateNormal];
        [self.nameButton setTitleColor:[UIColor colorWithRed:134.0f/255.0f green:100.0f/255.0f blue:65.0f/255.0f alpha:1.0f]
                              forState:UIControlStateHighlighted];
        [self.nameButton setTitleShadowColor:[UIColor whiteColor]
                                    forState:UIControlStateNormal];
        [self.nameButton setTitleShadowColor:[UIColor whiteColor]
                                    forState:UIControlStateSelected];
        [self.nameButton.titleLabel setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
        [self.nameButton addTarget:self action:@selector(didTapUserButtonAction:)
                  forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:self.nameButton];
        
        self.eventLabel = [[UILabel alloc] init];
        self.eventLabel.font = [UIFont systemFontOfSize:11.0f];
        self.eventLabel.textColor = [UIColor grayColor];
        self.eventLabel.backgroundColor = [UIColor clearColor];
        self.eventLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.7f];
        self.eventLabel.shadowOffset = CGSizeMake( 0.0f, 1.0f);
        [self.mainView addSubview:self.eventLabel];
        
        //Add mainView to ContentView of this cell (everything is put in the mainView)
        [self.contentView addSubview:mainView];
    }
    return self;
}



#pragma mark - TuduFriendSelectorCell

- (void)setUser:(PFUser *)aUser {
    user = aUser;
    
    // Configure the cell
    //[avatarImageView setFile:[self.user objectForKey:kTuduUserProfilePicSmallKey]];
    
    // Set name
    NSString *nameString = [self.user objectForKey:kTuduUserDisplayNameKey];
    CGSize nameSize = [nameString boundingRectWithSize:CGSizeMake(144.0f, CGFLOAT_MAX)
                                               options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f]}
                                               context:nil].size;
    [nameButton setTitle:[self.user objectForKey:kTuduUserDisplayNameKey] forState:UIControlStateNormal];
    [nameButton setTitle:[self.user objectForKey:kTuduUserDisplayNameKey] forState:UIControlStateHighlighted];
    
    [nameButton setFrame:CGRectMake( 60.0f, 17.0f, nameSize.width, nameSize.height)];
    
    // Set event number label
    CGSize eventLabelSize = [@"events" boundingRectWithSize:CGSizeMake(144.0f, CGFLOAT_MAX)
                                                    options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0f]}
                                                    context:nil].size;
    [eventLabel setFrame:CGRectMake( 60.0f, 17.0f + nameSize.height, 140.0f, eventLabelSize.height)];
    
}

#pragma mark - ()

+ (CGFloat)heightForCell {
    return 67.0f;
}

/* Inform delegate that a user image or name was tapped */
- (void)didTapUserButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapUserButton:)]) {
        [self.delegate cell:self didTapUserButton:self.user];
    }
}

@end

