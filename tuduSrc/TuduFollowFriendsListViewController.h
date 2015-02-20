//
//  TuduFollowFriendsListViewController.h
//  tudu
//
//  Created by Gian Costa on 9/9/14.
//
//

#import "TuduFriendsListViewController.h"

@interface TuduFollowFriendsListViewController : TuduFriendsListViewController <TuduFollowCellDelegate,
UITableViewDataSource,
UITableViewDelegate>

/// The event associated with this view
@property(nonatomic, strong) PFObject *event;
@property(nonatomic, strong) PFObject *user;

@property(nonatomic, strong) NSString *searchType;

- (void)setTheEvent:(PFObject *)theEvent;
- (void)setTheUser:(PFObject *)theUser;

@end
