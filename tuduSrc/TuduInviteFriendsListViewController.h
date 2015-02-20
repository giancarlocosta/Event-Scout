//
//  TuduInviteFriendsListViewController.h
//  tudu
//
//  Created by Gian Costa on 9/9/14.
//
//

#import "TuduFriendsListViewController.h"

@interface TuduInviteFriendsListViewController : TuduFriendsListViewController <TuduInviteCellDelegate>

@property (nonatomic, strong) NSMutableArray *inviteList;

@end
