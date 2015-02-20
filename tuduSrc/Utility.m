//
//  Utility.m
//  tudu
//
//  Created by Gian Costa on 9/2/14.
//
//

#import <Parse/Parse.h>
#import "Utility.h"
#import "UIImage+ResizeAdditions.h"
#import "Constants.h"

@implementation Utility


#pragma mark - TuduUtility
#pragma mark Like Events

+ (void)createEventInBackground:(NSDictionary *)details block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFObject *newEvent = [PFObject objectWithClassName:kTuduEventClassKey];
    /*
    [newEvent setObject:details[@"eventTitle"] forKey:kTuduEventTitleKey];
    [newEvent setObject:details[@"eventLocation"] forKey:kTuduEventLocationKey];
    [newEvent setObject:details[@"eventType"] forKey:kTuduEventTypeKey];
    [newEvent setObject:details[@"eventPrivacyType"] forKey:kTuduEventPrivacyTypeKey];
    [newEvent setObject:details[@"eventDate"] forKey:kTuduEventDateKey];
    [newEvent setObject:details[@"eventDescription"] forKey:kTuduEventDescriptionKey];
    [newEvent setObject:details[@"eventInviteList"] forKey:kTuduEventInviteListKey];
    [newEvent setObject:[PFUser currentUser] forKey:kTuduEventUserKey];
     */
    newEvent[kTuduEventTitleKey] = details[@"eventTitle"];
    newEvent[kTuduEventLocationKey] = details[@"eventLocation"];
    newEvent[kTuduEventTypeKey] = details[@"eventType"];
    newEvent[kTuduEventPrivacyTypeKey] = details[@"eventPrivacyType"];
    newEvent[kTuduEventDateKey] = details[@"eventDate"];
    newEvent[kTuduEventDescriptionKey] = details[@"eventDescription"];
    newEvent[kTuduEventInviteListKey] = details[@"eventInviteList"];
    newEvent[kTuduEventUserKey] = [PFUser currentUser];
    
    PFACL *eventACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [eventACL setPublicReadAccess:YES];
    [eventACL setWriteAccess:YES forUser:[PFUser currentUser]];
    newEvent.ACL = eventACL;
    
    // Saves this activity (which is you attending something) to the Activity Table
    [newEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded,error);
        }
        
        // Create INVITE activities for everyon on the list (UPDATING CACHE included in the invite method call)
        for (PFObject *invitedUser in details[@"userList"]) {
            [Utility inviteToEventInBackground:newEvent invitedUser:invitedUser block:^(BOOL succeeded, NSError *error) {
            }];
        }
    }];
}

+ (void)updateEventInBackground:(NSDictionary *)details event:(PFObject *)event block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *query = [PFQuery queryWithClassName:kTuduEventClassKey];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:event.objectId block:^(PFObject *eventToEdit, NSError *error) {
        
        eventToEdit[kTuduEventTitleKey] = details[@"eventTitle"];
        eventToEdit[kTuduEventLocationKey] = details[@"eventLocation"];
        eventToEdit[kTuduEventTypeKey] = details[@"eventType"];
        eventToEdit[kTuduEventPrivacyTypeKey] = details[@"eventPrivacyType"];
        eventToEdit[kTuduEventDateKey] = details[@"eventDate"];
        eventToEdit[kTuduEventDescriptionKey] = details[@"eventDescription"];
        //eventToEdit[kTuduEventInviteListKey] = details[@"eventInviteList"];
        
        [eventToEdit saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (completionBlock) {
                completionBlock(succeeded,error);
            }
            
            /*
            // Create INVITE activities for everyon on the list (UPDATING CACHE included in the invite method call)
            for (PFObject *invitedUser in details[@"userList"]) {
                [Utility inviteToEventInBackground:event invitedUser:invitedUser block:^(BOOL succeeded, NSError *error) {
                }];
            }*/
        }];
    }];
}



+ (void)inviteToEventInBackground:(id)event invitedUser:(PFObject *)invitedUser block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    
    // proceed to creating new attend
    PFObject *inviteActivity = [PFObject objectWithClassName:kTuduActivityClassKey];
    [inviteActivity setObject:kTuduActivityTypeInvite forKey:kTuduActivityTypeKey];
    [inviteActivity setObject:[PFUser currentUser] forKey:kTuduActivityFromUserKey];
    [inviteActivity setObject:invitedUser forKey:kTuduActivityToUserKey];
    [inviteActivity setObject:event forKey:kTuduActivityEventKey];
    
    PFACL *inviteACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [inviteACL setPublicReadAccess:YES];
    [inviteACL setWriteAccess:YES forUser:[event objectForKey:kTuduEventUserKey]];
    inviteActivity.ACL = inviteACL;
    
    // Saves this activity (which is you attending something) to the Activity Table
    [inviteActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded,error);
        }
        
        // refresh cache
        PFQuery *query = [Utility queryForActivitiesOnEvent:event cachePolicy:kPFCachePolicyNetworkOnly];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                
                NSMutableArray *attenders = [NSMutableArray array];
                NSMutableArray *commenters = [NSMutableArray array];
                NSMutableArray *invitedPeople = [NSMutableArray array];
                
                BOOL isAttendedByCurrentUser = NO;
                
                for (PFObject *activity in objects) {
                    if ([[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeAttend] && [activity objectForKey:kTuduActivityFromUserKey]) {
                        [attenders addObject:[activity objectForKey:kTuduActivityFromUserKey]];
                    } else if ([[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeComment] && [activity objectForKey:kTuduActivityFromUserKey]) {
                        [commenters addObject:[activity objectForKey:kTuduActivityFromUserKey]];
                    } else if ([[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeInvite] && [activity objectForKey:kTuduActivityFromUserKey]) {
                        [invitedPeople addObject:[activity objectForKey:kTuduActivityFromUserKey]];
                    }
                    
                    if ([[[activity objectForKey:kTuduActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                        if ([[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeAttend]) {
                            isAttendedByCurrentUser = YES;
                        }
                    }
                }
                
                // Updates the cache for this event
                [[TuduCache sharedCache] setAttributesForEvent:event attenders:attenders commenters:commenters invitedPeople:invitedPeople attendedByCurrentUser:isAttendedByCurrentUser];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TuduUtilityUserAttendedUnattendedEventCallbackFinishedNotification object:event userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:succeeded] forKey:TuduEventDetailsViewControllerUserAttendedUnattendedEventNotificationUserInfoAttendedKey]];
        }];
        
    }];
    
    return;
}

+ (void)attendEventInBackground:(id)event block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingAttends = [PFQuery queryWithClassName:kTuduActivityClassKey];
    [queryExistingAttends whereKey:kTuduActivityEventKey equalTo:event];
    [queryExistingAttends whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeAttend];
    [queryExistingAttends whereKey:kTuduActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingAttends setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingAttends findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
        }
        
        // proceed to creating new attend
        PFObject *attendActivity = [PFObject objectWithClassName:kTuduActivityClassKey];
        [attendActivity setObject:kTuduActivityTypeAttend forKey:kTuduActivityTypeKey];
        [attendActivity setObject:[PFUser currentUser] forKey:kTuduActivityFromUserKey];
        [attendActivity setObject:[event objectForKey:kTuduEventUserKey] forKey:kTuduActivityToUserKey];
        [attendActivity setObject:event forKey:kTuduActivityEventKey];
        
        PFACL *attendACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [attendACL setPublicReadAccess:YES];
        [attendACL setWriteAccess:YES forUser:[event objectForKey:kTuduEventUserKey]];
        attendActivity.ACL = attendACL;
        
        // Saves this activity (which is you attending something) to the Activity Table
        [attendActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (completionBlock) {
                completionBlock(succeeded,error);
            }
            
            // refresh cache
            PFQuery *query = [Utility queryForActivitiesOnEvent:event cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *attenders = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    NSMutableArray *invitedPeople = [NSMutableArray array];
                    
                    BOOL isAttendedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeAttend] && [activity objectForKey:kTuduActivityFromUserKey]) {
                            [attenders addObject:[activity objectForKey:kTuduActivityFromUserKey]];
                        } else if ([[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeComment] && [activity objectForKey:kTuduActivityFromUserKey]) {
                            [commenters addObject:[activity objectForKey:kTuduActivityFromUserKey]];
                        } else if ([[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeInvite] && [activity objectForKey:kTuduActivityFromUserKey]) {
                            [invitedPeople addObject:[activity objectForKey:kTuduActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kTuduActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeAttend]) {
                                isAttendedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    // Updates the cache for this event
                    [[TuduCache sharedCache] setAttributesForEvent:event attenders:attenders commenters:commenters invitedPeople:invitedPeople attendedByCurrentUser:isAttendedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:TuduUtilityUserAttendedUnattendedEventCallbackFinishedNotification object:event userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:succeeded] forKey:TuduEventDetailsViewControllerUserAttendedUnattendedEventNotificationUserInfoAttendedKey]];
            }];
            
        }];
    }];
    
}

+ (void)unattendEventInBackground:(id)event block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingAttends = [PFQuery queryWithClassName:kTuduActivityClassKey];
    [queryExistingAttends whereKey:kTuduActivityEventKey equalTo:event];
    [queryExistingAttends whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeAttend];
    [queryExistingAttends whereKey:kTuduActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingAttends setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingAttends findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
            
            if (completionBlock) {
                completionBlock(YES,nil);
            }
            
            // refresh cache
            PFQuery *query = [Utility queryForActivitiesOnEvent:event cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *attenders = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    NSMutableArray *invitedPeople = [NSMutableArray array];
                    
                    BOOL isAttendedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeAttend]) {
                            [attenders addObject:[activity objectForKey:kTuduActivityFromUserKey]];
                        } else if ([[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeComment]) {
                            [commenters addObject:[activity objectForKey:kTuduActivityFromUserKey]];
                        } else if ([[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeInvite] && [activity objectForKey:kTuduActivityFromUserKey]) {
                            [invitedPeople addObject:[activity objectForKey:kTuduActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kTuduActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kTuduActivityTypeKey] isEqualToString:kTuduActivityTypeAttend]) {
                                isAttendedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[TuduCache sharedCache] setAttributesForEvent:event attenders:attenders commenters:commenters invitedPeople:invitedPeople attendedByCurrentUser:isAttendedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:TuduUtilityUserAttendedUnattendedEventCallbackFinishedNotification object:event userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:TuduEventDetailsViewControllerUserAttendedUnattendedEventNotificationUserInfoAttendedKey]];
            }];
            
        } else {
            if (completionBlock) {
                completionBlock(NO,error);
            }
        }
    }];
}


#pragma mark Facebook

+ (void)processFacebookProfilePictureData:(NSData *)newProfilePictureData {
    if (newProfilePictureData.length == 0) {
        return;
    }
    
    // The user's Facebook profile picture is cached to disk. Check if the cached profile picture data matches the incoming profile picture. If it does, avoid uploading this data to Parse.
    
    NSURL *cachesDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject]; // iOS Caches directory
    
    NSURL *profilePictureCacheURL = [cachesDirectoryURL URLByAppendingPathComponent:@"FacebookProfilePicture.jpg"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[profilePictureCacheURL path]]) {
        // We have a cached Facebook profile picture
        
        NSData *oldProfilePictureData = [NSData dataWithContentsOfFile:[profilePictureCacheURL path]];
        
        if ([oldProfilePictureData isEqualToData:newProfilePictureData]) {
            return;
        }
    }
    
    UIImage *image = [UIImage imageWithData:newProfilePictureData];
    
    UIImage *mediumImage = [image thumbnailImage:280 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    UIImage *smallRoundedImage = [image thumbnailImage:64 transparentBorder:0 cornerRadius:9 interpolationQuality:kCGInterpolationLow];
    
    NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 0.5); // using JPEG for larger pictures
    NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);
    
    if (mediumImageData.length > 0) {
        PFFile *fileMediumImage = [PFFile fileWithData:mediumImageData];
        [fileMediumImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileMediumImage forKey:kTuduUserProfilePicMediumKey];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
    
    if (smallRoundedImageData.length > 0) {
        PFFile *fileSmallRoundedImage = [PFFile fileWithData:smallRoundedImageData];
        [fileSmallRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileSmallRoundedImage forKey:kTuduUserProfilePicSmallKey];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
}

+ (BOOL)userHasValidFacebookData:(PFUser *)user {
    NSString *facebookId = [user objectForKey:kTuduUserFacebookIDKey];
    return (facebookId && facebookId.length > 0);
}

+ (BOOL)userHasProfilePictures:(PFUser *)user {
    PFFile *profilePictureMedium = [user objectForKey:kTuduUserProfilePicMediumKey];
    PFFile *profilePictureSmall = [user objectForKey:kTuduUserProfilePicSmallKey];
    
    return (profilePictureMedium && profilePictureSmall);
}


#pragma mark Display Name

+ (NSString *)firstNameForDisplayName:(NSString *)displayName {
    if (!displayName || displayName.length == 0) {
        return @"Someone";
    }
    
    NSArray *displayNameComponents = [displayName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *firstName = [displayNameComponents objectAtIndex:0];
    if (firstName.length > 100) {
        // truncate to 100 so that it fits in a Push payload
        firstName = [firstName substringToIndex:100];
    }
    return firstName;
}


#pragma mark User Following

+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kTuduActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:kTuduActivityFromUserKey];
    [followActivity setObject:user forKey:kTuduActivityToUserKey];
    [followActivity setObject:kTuduActivityTypeFollow forKey:kTuduActivityTypeKey];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded, error);
        }
    }];
    [[TuduCache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kTuduActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:kTuduActivityFromUserKey];
    [followActivity setObject:user forKey:kTuduActivityToUserKey];
    [followActivity setObject:kTuduActivityTypeFollow forKey:kTuduActivityTypeKey];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveEventually:completionBlock];
    [[TuduCache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    for (PFUser *user in users) {
        [Utility followUserEventually:user block:completionBlock];
        [[TuduCache sharedCache] setFollowStatus:YES user:user];
    }
}

+ (void)unfollowUserEventually:(PFUser *)user {
    PFQuery *query = [PFQuery queryWithClassName:kTuduActivityClassKey];
    [query whereKey:kTuduActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kTuduActivityToUserKey equalTo:user];
    [query whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        // While normally there should only be one follow activity returned, we can't guarantee that.
        
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                [followActivity deleteEventually];
            }
        }
    }];
    [[TuduCache sharedCache] setFollowStatus:NO user:user];
}

+ (void)unfollowUsersEventually:(NSArray *)users {
    PFQuery *query = [PFQuery queryWithClassName:kTuduActivityClassKey];
    [query whereKey:kTuduActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kTuduActivityToUserKey containedIn:users];
    [query whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        for (PFObject *activity in activities) {
            [activity deleteEventually];
        }
    }];
    for (PFUser *user in users) {
        [[TuduCache sharedCache] setFollowStatus:NO user:user];
    }
}


#pragma mark Activities

+ (PFQuery *)queryForActivitiesOnEvent:(PFObject *)event cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryAttends = [PFQuery queryWithClassName:kTuduActivityClassKey];
    [queryAttends whereKey:kTuduActivityEventKey equalTo:event];
    [queryAttends whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeAttend];
    
    PFQuery *queryComments = [PFQuery queryWithClassName:kTuduActivityClassKey];
    [queryComments whereKey:kTuduActivityEventKey equalTo:event];
    [queryComments whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeComment];
    
    PFQuery *queryInvites = [PFQuery queryWithClassName:kTuduActivityClassKey];
    [queryInvites whereKey:kTuduActivityEventKey equalTo:event];
    [queryInvites whereKey:kTuduActivityTypeKey equalTo:kTuduActivityTypeInvite];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryAttends,queryComments, queryInvites, nil]];
    [query setCachePolicy:cachePolicy];
    [query includeKey:kTuduActivityFromUserKey];
    [query includeKey:kTuduActivityEventKey];
    
    return query;
}


#pragma mark Shadow Rendering

+ (void)drawSideAndBottomDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height + 10.0f));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y - 5.0f,
                                          rect.size.width,
                                          rect.size.height + 5.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)drawSideAndTopDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y - 10.0f, rect.size.width + 20.0f, rect.size.height + 10.0f));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y,
                                          rect.size.width,
                                          rect.size.height + 10.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)drawSideDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y - 5.0f,
                                          rect.size.width,
                                          rect.size.height + 10.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)addBottomDropShadowToNavigationBarForNavigationController:(UINavigationController *)navigationController {
    UIView *gradientView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, navigationController.navigationBar.frame.size.height, navigationController.navigationBar.frame.size.width, 3.0f)];
    [gradientView setBackgroundColor:[UIColor clearColor]];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = gradientView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    [gradientView.layer insertSublayer:gradient atIndex:0];
    navigationController.navigationBar.clipsToBounds = NO;
    [navigationController.navigationBar addSubview:gradientView];
}

@end

