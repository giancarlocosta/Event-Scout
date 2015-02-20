//
//  TuduCache.m
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//

#import "TuduCache.h"
#import "Constants.h"

@interface TuduCache()

@property (nonatomic, strong) NSCache *cache;
- (void)setAttributes:(NSDictionary *)attributes forEvent:(PFObject *)event;
@end

@implementation TuduCache
@synthesize cache;

#pragma mark - Initialization

+ (id)sharedCache {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - TuduCache

- (void)clear {
    [self.cache removeAllObjects];
}

/*!
 *
 * Set and get based on Event
 *
 */
- (void)setAttributesForEvent:(PFObject *)event
                    attenders:(NSArray *)attenders
                   commenters:(NSArray *)commenters
                invitedPeople:(NSArray *)invitedPeople
        attendedByCurrentUser:(BOOL)attendedByCurrentUser {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:attendedByCurrentUser],kTuduEventAttributesIsAttendedByCurrentUserKey,
                                @([attenders count]),kTuduEventAttributesAttendCountKey,
                                attenders,kTuduEventAttributesAttendersKey,
                                @([commenters count]),kTuduEventAttributesCommentCountKey,
                                commenters,kTuduEventAttributesCommentersKey,
                                @([invitedPeople count]),kTuduEventAttributesInviteCountKey,
                                invitedPeople,kTuduEventAttributesInvitedPeopleKey,
                                nil];
    [self setAttributes:attributes forEvent:event];
}

- (NSDictionary *)attributesForEvent:(PFObject *)event {
    NSString *key = [self keyForEvent:event];
    return [self.cache objectForKey:key];
    //return [[NSDictionary alloc] init];
}

- (NSNumber *)attendCountForEvent:(PFObject *)event {
    NSDictionary *attributes = [self attributesForEvent:event];
    if (attributes) {
        return [attributes objectForKey:kTuduEventAttributesAttendCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSNumber *)commentCountForEvent:(PFObject *)event {
    NSDictionary *attributes = [self attributesForEvent:event];
    if (attributes) {
        return [attributes objectForKey:kTuduEventAttributesCommentCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSArray *)attendersForEvent:(PFObject *)event {
    NSDictionary *attributes = [self attributesForEvent:event];
    if (attributes) {
        return [attributes objectForKey:kTuduEventAttributesAttendersKey];
    }
    
    return [NSArray array];
}

- (NSArray *)commentersForEvent:(PFObject *)event {
    NSDictionary *attributes = [self attributesForEvent:event];
    if (attributes) {
        return [attributes objectForKey:kTuduEventAttributesCommentersKey];
    }
    
    return [NSArray array];
}

- (void)setEventIsAttendedByCurrentUser:(PFObject *)event attended:(BOOL)attended {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForEvent:event]];
    [attributes setObject:[NSNumber numberWithBool:attended] forKey:kTuduEventAttributesIsAttendedByCurrentUserKey];
    [self setAttributes:attributes forEvent:event];
}

- (BOOL)isEventAttendedByCurrentUser:(PFObject *)event {
    NSDictionary *attributes = [self attributesForEvent:event];
    if (attributes) {
        return [[attributes objectForKey:kTuduEventAttributesIsAttendedByCurrentUserKey] boolValue];
    }
    
    return NO;
}

- (void)incrementAttenderCountForEvent:(PFObject *)event {
    NSNumber *attenderCount = [NSNumber numberWithInt:[[self attendCountForEvent:event] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForEvent:event]];
    [attributes setObject:attenderCount forKey:kTuduEventAttributesAttendCountKey];
    [self setAttributes:attributes forEvent:event];
}

- (void)decrementAttenderCountForEvent:(PFObject *)event {
    NSNumber *attenderCount = [NSNumber numberWithInt:[[self attendCountForEvent:event] intValue] - 1];
    if ([attenderCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForEvent:event]];
    [attributes setObject:attenderCount forKey:kTuduEventAttributesAttendCountKey];
    [self setAttributes:attributes forEvent:event];
}

- (void)incrementCommentCountForEvent:(PFObject *)event {
    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForEvent:event] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForEvent:event]];
    [attributes setObject:commentCount forKey:kTuduEventAttributesCommentCountKey];
    [self setAttributes:attributes forEvent:event];
}

- (void)decrementCommentCountForEvent:(PFObject *)event {
    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForEvent:event] intValue] - 1];
    if ([commentCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForEvent:event]];
    [attributes setObject:commentCount forKey:kTuduEventAttributesCommentCountKey];
    [self setAttributes:attributes forEvent:event];
}

- (void)incrementInviteCountForEvent:(PFObject *)event {
    NSNumber *inviteCount = [NSNumber numberWithInt:[[self inviteCountForEvent:event] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForEvent:event]];
    [attributes setObject:inviteCount forKey:kTuduEventAttributesInviteCountKey];
    [self setAttributes:attributes forEvent:event];
}

- (NSArray *)invitedPeopleForEvent:(PFObject *)event {
    NSDictionary *attributes = [self attributesForEvent:event];
    if (attributes) {
        return [attributes objectForKey:kTuduEventAttributesInvitedPeopleKey];
    }
    
    return [NSArray array];
}

- (NSNumber *)inviteCountForEvent:(PFObject *)event {
    NSDictionary *attributes = [self attributesForEvent:event];
    if (attributes) {
        return [attributes objectForKey:kTuduEventAttributesInviteCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}



/*!
 *
 * Set and get based on PFUser
 *
 */

- (void)setAttributesForUser:(PFUser *)user eventCount:(NSNumber *)count followedByCurrentUser:(BOOL)following {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                count,kTuduUserAttributesEventCountKey,
                                [NSNumber numberWithBool:following],kTuduUserAttributesIsFollowedByCurrentUserKey,
                                nil];
    [self setAttributes:attributes forUser:user];
}


- (NSDictionary *)attributesForUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    return [self.cache objectForKey:key];
}

- (NSNumber *)eventCountForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *eventCount = [attributes objectForKey:kTuduUserAttributesEventCountKey];
        if (eventCount) {
            return eventCount;
        }
    }
    
    return [NSNumber numberWithInt:0];
}

- (BOOL)followStatusForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *followStatus = [attributes objectForKey:kTuduUserAttributesIsFollowedByCurrentUserKey];
        if (followStatus) {
            return [followStatus boolValue];
        }
    }
    
    return NO;
}

- (void)seteventCount:(NSNumber *)count user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:count forKey:kTuduUserAttributesEventCountKey];
    [self setAttributes:attributes forUser:user];
}

- (void)setFollowStatus:(BOOL)following user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:[NSNumber numberWithBool:following] forKey:kTuduUserAttributesIsFollowedByCurrentUserKey];
    [self setAttributes:attributes forUser:user];
}

- (void)setFacebookFriends:(NSArray *)friends {
    NSString *key = kTuduUserDefaultsCacheFacebookFriendsKey;
    [self.cache setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)facebookFriends {
    NSString *key = kTuduUserDefaultsCacheFacebookFriendsKey;
    if ([self.cache objectForKey:key]) {
        return [self.cache objectForKey:key];
    }
    
    NSArray *friends = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (friends) {
        [self.cache setObject:friends forKey:key];
    }
    
    return friends;
}

// Cache is basically a Map of PFObjects (PFUser and PFObject(events)) to their attributes
// The objects are represented by their objectId so Cache is a Map attend so ( PFobjectID -> NSDictionary)
#pragma mark - ()

- (void)setAttributes:(NSDictionary *)attributes forEvent:(PFObject *)event {
    NSString *key = [self keyForEvent:event];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    [self.cache setObject:attributes forKey:key];
}

- (NSString *)keyForEvent:(PFObject *)event {
    return [NSString stringWithFormat:@"event_%@", [event objectId]];
}

- (NSString *)keyForUser:(PFUser *)user {
    return [NSString stringWithFormat:@"user_%@", [user objectId]];
}

@end

