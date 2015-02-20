//
//  Utility.h
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Utility : NSObject

+ (void)createEventInBackground:(NSDictionary *)details block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)updateEventInBackground:(NSDictionary *)details event:(PFObject *)event block:(void (^)(BOOL succeeded, NSError *error))completionBlock;

+ (void)attendEventInBackground:(id)event block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unattendEventInBackground:(id)event block:(void (^)(BOOL succeeded, NSError *error))completionBlock;

+ (void)inviteToEventInBackground:(id)event invitedUser:(PFObject *)invitedUser block:(void (^)(BOOL succeeded, NSError *error))completionBlock;

+ (void)processFacebookProfilePictureData:(NSData *)data;

+ (BOOL)userHasValidFacebookData:(PFUser *)user;
+ (BOOL)userHasProfilePictures:(PFUser *)user;

+ (NSString *)firstNameForDisplayName:(NSString *)displayName;

+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unfollowUserEventually:(PFUser *)user;
+ (void)unfollowUsersEventually:(NSArray *)users;

+ (void)drawSideDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;
+ (void)drawSideAndBottomDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;
+ (void)drawSideAndTopDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;
+ (void)addBottomDropShadowToNavigationBarForNavigationController:(UINavigationController *)navigationController;

+ (PFQuery *)queryForActivitiesOnEvent:(PFObject *)event cachePolicy:(PFCachePolicy)cachePolicy;
@end
