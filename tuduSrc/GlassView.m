//
//  GlassView.m
//  tudu
//
//  Created by Gian Costa on 9/15/14.
//
//

#import "GlassView.h"
#import "UIImage+ImageEffects.h"

@implementation GlassView
@synthesize backgroundImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview == nil) {
        return;
    }
    UIGraphicsBeginImageContextWithOptions(newSuperview.bounds.size, YES, 0.0);
    [newSuperview drawViewHierarchyInRect:newSuperview.bounds afterScreenUpdates:YES];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *croppedImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(img.CGImage, self.frame)];
    UIGraphicsEndImageContext();
    
    self.backgroundImage = [croppedImage applyBlurWithRadius:11
                                                   tintColor:[UIColor colorWithWhite:1 alpha:0.3]
                                       saturationDeltaFactor:1.8
                                                   maskImage:nil];
}

@end
