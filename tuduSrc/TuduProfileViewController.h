//
//  TuduProfileViewController.h
//  tudu
//
//  Created by Gian Costa on 9/1/14.
//
//

#import <UIKit/UIKit.h>
#import "TuduEventFeedViewController.h"
#import "TuduProfileTableHeaderView.h"

@interface TuduProfileViewController : TuduEventFeedViewController <TuduProfileTableHeaderViewDelegate> //UIViewController

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) TuduProfileTableHeaderView *profileTableHeaderView;

- (id)initWithUser:(PFUser *)user;
@end
