//
//  TuduEventFeedViewController.h
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//

#import <Parse/Parse.h>
#import "EventHeaderView.h"
#import "EventFooterCell.h"

@interface TuduEventFeedViewController : PFQueryTableViewController <EventHeaderViewDelegate, EventFooterCellDelegate>

- (EventHeaderView *)dequeueReusableSectionHeaderView;

@end
