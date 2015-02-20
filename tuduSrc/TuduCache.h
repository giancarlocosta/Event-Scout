//
//  TuduCache.h
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//

#import <Foundation/Foundation.h>

@interface TuduCache : NSObject

+ (id)sharedCache;

- (void)clear;

// Set and get based on Event
- (void)setAttributesForEvent:(PFObject *)event
                    attenders:(NSArray *)attenders
                   commenters:(NSArray *)commenters
                invitedPeople:(NSArray *)invitedPeople
        attendedByCurrentUser:(BOOL)attendedByCurrentUser;
- (NSDictionary *)attributesForEvent:(PFObject *)event;

- (NSNumber *)attendCountForEvent:(PFObject *)event;
- (NSNumber *)commentCountForEvent:(PFObject *)event;
- (NSArray *)attendersForEvent:(PFObject *)event;
- (NSArray *)commentersForEvent:(PFObject *)event;


- (void)setEventIsAttendedByCurrentUser:(PFObject *)event attended:(BOOL)attended;
- (BOOL)isEventAttendedByCurrentUser:(PFObject *)event;

- (void)incrementAttenderCountForEvent:(PFObject *)event;
- (void)decrementAttenderCountForEvent:(PFObject *)event;
- (void)incrementCommentCountForEvent:(PFObject *)event;
- (void)decrementCommentCountForEvent:(PFObject *)event;

- (void)incrementInviteCountForEvent:(PFObject *)event;
- (NSArray *)invitedPeopleForEvent:(PFObject *)event;
- (NSNumber *)inviteCountForEvent:(PFObject *)event;


// Set and get based on PFUser
- (NSDictionary *)attributesForUser:(PFUser *)user;
- (NSNumber *)eventCountForUser:(PFUser *)user;
- (BOOL)followStatusForUser:(PFUser *)user;
- (void)setEventCount:(NSNumber *)count user:(PFUser *)user;
- (void)setFollowStatus:(BOOL)following user:(PFUser *)user;

- (void)setFacebookFriends:(NSArray *)friends;
- (NSArray *)facebookFriends;
@end
