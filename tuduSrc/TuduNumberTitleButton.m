//
//  TuduNumberTitleButton.m
//  tudu
//
//  Created by Gian Costa on 9/19/14.
//
//

#import "TuduNumberTitleButton.h"

@implementation TuduNumberTitleButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self = [UIButton buttonWithType:UIButtonTypeCustom];
        //[self.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
        //[self.layer setBorderWidth:1.0f];
        //[self setBackgroundImage:[UIImage imageNamed:@"ButtonFooterCell.png"] forState:UIControlStateNormal];
        //[self setBackgroundImage:[UIImage imageNamed:@"ButtonFooterCell.png"] forState:UIControlStateSelected];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAdjustsImageWhenHighlighted:NO];
        [self setAdjustsImageWhenDisabled:NO];
        [self setSelected:NO];


        self.buttonNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height/2)];
        self.buttonNumberLabel.text = @"-";
        [self.buttonNumberLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:12.0f]];
        self.buttonNumberLabel.textAlignment = NSTextAlignmentCenter;
        
        self.buttonTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.buttonNumberLabel.frame.origin.x + self.buttonNumberLabel.frame.size.height, self.frame.size.width, self.frame.size.height/2)];
        //[self.buttonTitleLabel setTextColor:[UIColor colorWithRed:0.369f green:0.271f blue:0.176f alpha:1.0f]];
        [self.buttonTitleLabel setShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f]];
        [self.buttonTitleLabel setFont:[UIFont fontWithName:[ThemeAndStyle buttonFont] size:12.0f]];
        self.buttonTitleLabel.textAlignment = NSTextAlignmentCenter;
        
        
        
        [self addSubview:self.buttonNumberLabel];
        [self addSubview:self.buttonTitleLabel];
    }
    return self;
}

- (void)setButtonNumberValue:(NSNumber *)value {
    NSString *numberAsString = [NSString stringWithFormat:@"%@ ",value];
    self.buttonNumberLabel.text = numberAsString;
}

- (void)setButtonTitleValue:(NSString *)value {
    self.buttonTitleLabel.text = value;
}

@end
