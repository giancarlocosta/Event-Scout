//
//  EventDisplayCell.h
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//

#import <UIKit/UIKit.h>
#define CELL_HEIGHT 100

@class PFImageView;
@interface EventDisplayCell : PFTableViewCell

@property (nonatomic, strong) UIView *eventInfoContainer;
@property (nonatomic, strong) UIButton *eventButton;
@property (nonatomic, strong) UILabel *eventTitleLabel;
@property (nonatomic, strong) UILabel *eventDateLabel;
@property (nonatomic, strong) UILabel *eventLocationLabel;
@property (nonatomic, strong) UILabel *tapForDeatilsLabel;

+ (CGFloat)heightForDisplayCell;

@end
