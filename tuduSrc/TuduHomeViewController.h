//
//  TuduHomeViewController.h
//  tudu
//
//  Created by Gian Costa on 9/1/14.
//
//

#import <UIKit/UIKit.h>
#import "TuduEventFeedViewController.h"

@interface TuduHomeViewController : TuduEventFeedViewController
@property (nonatomic, assign, getter = isFirstLaunch) BOOL firstLaunch;
@end
