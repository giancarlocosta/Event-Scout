//
//  TuduNextButtonItem.m
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//

#import "TuduNextButtonItem.h"

@implementation TuduNextButtonItem

#pragma mark - Initialization

- (id)initWithTarget:(id)target action:(SEL)action {
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self = [super initWithCustomView:nextButton];
    if (self) {
        [nextButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [nextButton setTitle:@"Next" forState: UIControlStateNormal];
        [nextButton setFrame:CGRectMake(0.0f, 0.0f, 35.0f, 32.0f)];
        [nextButton setImage:[UIImage imageNamed:@"ButtonNext.png"] forState:UIControlStateNormal];
        //[nextButton setImage:[UIImage imageNamed:@"ButtonImageSettingsSelected.png"] forState:UIControlStateHighlighted];
    }
    
    return self;
}
@end
