//
//  TuduProfileImageView.h
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class PFImageView;
@interface TuduProfileImageView : UIView

@property (nonatomic, strong) UIButton *profileButton;
@property (nonatomic, strong) PFImageView *profileImageView;

- (void)setFile:(PFFile *)file;

@end
