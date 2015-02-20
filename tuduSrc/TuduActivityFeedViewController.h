//
//  TuduActivityFeedViewController.h
//  tudu
//
//  Created by Gian Costa on 9/1/14.
//
//

#import <UIKit/UIKit.h>
#import "TuduActivityCell.h"

@interface TuduActivityFeedViewController : UIViewController
<TuduActivityCellDelegate,
UISearchBarDelegate,
UITableViewDataSource,
UITableViewDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *resultsTable;
@property (nonatomic, strong) NSArray *queryObjects;

@property (nonatomic, strong) PFObject *user;
- (id)initWithUser:(PFObject *)aUser;
+ (NSString *)stringForActivityType:(NSString *)activityType;

@end
