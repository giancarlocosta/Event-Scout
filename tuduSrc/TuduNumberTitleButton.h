//
//  TuduNumberTitleButton.h
//  tudu
//
//  Created by Gian Costa on 9/19/14.
//
//

#import <UIKit/UIKit.h>

@interface TuduNumberTitleButton : UIButton

@property (nonatomic, strong) UILabel *buttonNumberLabel;
@property (nonatomic, strong) UILabel *buttonTitleLabel;

- (void)setButtonNumberValue:(NSNumber *)value;
- (void)setButtonTitleValue:(NSString *)value;

@end
