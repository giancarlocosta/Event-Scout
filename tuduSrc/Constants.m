//
//  TuduConstants.m
//

#import "Constants.h"


NSString *const kTuduUserDefaultsActivityFeedViewControllerLastRefreshKey    = @"com.parse.tudu.userDefaults.activityFeedViewController.lastRefresh";
NSString *const kTuduUserDefaultsCacheFacebookFriendsKey                     = @"com.parse.tudu.userDefaults.cache.facebookFriends";


#pragma mark - Launch URLs

NSString *const kTuduLaunchURLHostTakePicture = @"camera";


#pragma mark - NSNotification

NSString *const TuduAppDelegateApplicationDidReceiveRemoteNotification           = @"com.parse.Anypic.appDelegate.applicationDidReceiveRemoteNotification";
NSString *const TuduUtilityUserFollowingChangedNotification                      = @"com.parse.Anypic.utility.userFollowingChanged";
NSString *const TuduUtilityUserAttendedUnattendedEventCallbackFinishedNotification     = @"com.parse.Anypic.utility.userAttendedUnattendedEventCallbackFinished";
NSString *const TuduUtilityDidFinishProcessingProfilePictureNotification         = @"com.parse.Anypic.utility.didFinishProcessingProfilePictureNotification";
NSString *const TuduTabBarControllerDidFinishEditingEventNotification            = @"com.parse.Anypic.tabBarController.didFinishEditingEvent";
NSString *const TuduTabBarControllerDidFinishImageFileUploadNotification         = @"com.parse.Anypic.tabBarController.didFinishImageFileUploadNotification";
NSString *const TuduEventDetailsViewControllerUserDeletedEventNotification       = @"com.parse.Anypic.photoDetailsViewController.userDeletedEvent";
NSString *const TuduEventDetailsViewControllerUserAttendedUnattendedEventNotification  = @"com.parse.Anypic.photoDetailsViewController.userAttendedUnattendedEventInDetailsViewNotification";
NSString *const TuduEventDetailsViewControllerUserCommentedOnEventNotification   = @"com.parse.Anypic.photoDetailsViewController.userCommentedOnEventInDetailsViewNotification";


#pragma mark - User Info Keys
NSString *const TuduEventDetailsViewControllerUserAttendedUnattendedEventNotificationUserInfoAttendedKey = @"attended";
NSString *const kTuduEditEventViewControllerUserInfoCommentKey = @"comment";

#pragma mark - Installation Class

// Field keys
NSString *const kTuduInstallationUserKey = @"user";

#pragma mark - Activity Class
// Class key
NSString *const kTuduActivityClassKey = @"Activity";

// Field keys
NSString *const kTuduActivityTypeKey        = @"type";
NSString *const kTuduActivityFromUserKey    = @"fromUser";
NSString *const kTuduActivityToUserKey      = @"toUser";
NSString *const kTuduActivityContentKey     = @"content";
NSString *const kTuduActivityEventKey       = @"event";

// Type values
NSString *const kTuduActivityTypeFollow     = @"follow";
NSString *const kTuduActivityTypeComment    = @"comment";
NSString *const kTuduActivityTypeJoined     = @"joined";
NSString *const kTuduActivityTypeAttend    = @"attend";
NSString *const kTuduActivityTypeInvite    = @"invite";

#pragma mark - User Class
// Field keys
NSString *const kTuduUserDisplayNameKey                          = @"displayName";
NSString *const kTuduUserFacebookIDKey                           = @"facebookId";
NSString *const kTuduUserPhotoIDKey                              = @"photoId";
NSString *const kTuduUserProfilePicSmallKey                      = @"profilePictureSmall";
NSString *const kTuduUserProfilePicMediumKey                     = @"profilePictureMedium";
NSString *const kTuduUserFacebookFriendsKey                      = @"facebookFriends";
NSString *const kTuduUserAlreadyAutoFollowedFacebookFriendsKey   = @"userAlreadyAutoFollowedFacebookFriends";

#pragma mark - Event Class
//Class key
NSString *const kTuduEventClassKey = @"Event";

//Field Keys
NSString *const kTuduEventPrivacyTypeKey        = @"privacyType";		// string
NSString *const kTuduEventUserKey               = @"user";       		// User
NSString *const kTuduEventTypeKey               = @"eventType";  		// string
NSString *const kTuduEventTitleKey              = @"title";      		// string
NSString *const kTuduEventDescriptionKey        = @"description";      	// string
NSString *const kTuduEventDateKey               = @"date";      		// string
NSString *const kTuduEventLocationKey           = @"location";      	// string
NSString *const kTuduEventInviteListKey         = @"inviteList"; 		// array<usernames>

// Type Values
NSString *const kTuduEventPrivacyTypePublic     = @"Public";
NSString *const kTuduEventPrivacyTypeHostInvite = @"Host-Only Invites";
NSString *const kTuduEventPrivacyTypeHostGuestInvite = @"Host & Guest Invites";
NSString *const kTuduEventTypeParty				= @"Party";
NSString *const kTuduEventTypeKickBack			= @"Hangout & KickBack";
NSString *const kTuduEventTypeOutdoor			= @"Outdoor";
NSString *const kTuduEventTypeDine				= @"Eat";
NSString *const kTuduEventTypeProfessional		= @"Networking/Job Fair";
NSString *const kTuduEventTypePickup			= @"Pickup Game";


#pragma mark - Cached Event Attributes
// keys
NSString *const kTuduEventAttributesIsAttendedByCurrentUserKey = @"isAttendedByCurrentUser";
NSString *const kTuduEventAttributesAttendCountKey            = @"attendCount";
NSString *const kTuduEventAttributesAttendersKey               = @"attenders";
NSString *const kTuduEventAttributesCommentCountKey         = @"commentCount";
NSString *const kTuduEventAttributesCommentersKey           = @"commenters";
NSString *const kTuduEventAttributesInvitedPeopleKey        = @"invitedPeople";
NSString *const kTuduEventAttributesInviteCountKey          = @"inviteCount";



#pragma mark - Cached User Attributes
// keys
NSString *const kTuduUserAttributesEventCountKey                 = @"photoCount";
NSString *const kTuduUserAttributesIsFollowedByCurrentUserKey    = @"isFollowedByCurrentUser";


#pragma mark - Push Notification Payload Keys

NSString *const kAPNSAlertKey = @"alert";
NSString *const kAPNSBadgeKey = @"badge";
NSString *const kAPNSSoundKey = @"sound";

// the following keys are intentionally kept short, APNS has a maximum payload limit
NSString *const kTuduPushPayloadPayloadTypeKey          = @"p";
NSString *const kTuduPushPayloadPayloadTypeActivityKey  = @"a";

NSString *const kTuduPushPayloadActivityTypeKey     = @"t";
NSString *const kTuduPushPayloadActivityLikeKey     = @"l";
NSString *const kTuduPushPayloadActivityCommentKey  = @"c";
NSString *const kTuduPushPayloadActivityFollowKey   = @"f";

NSString *const kTuduPushPayloadFromUserObjectIdKey = @"fu";
NSString *const kTuduPushPayloadToUserObjectIdKey   = @"tu";
NSString *const kTuduPushPayloadPhotoObjectIdKey    = @"pid";

// the following keys are intentionally kept short, APNS has a maximum payload limit
/*
 NSString *const kTuduPushPayloadPayloadTypeKey          = @"p";
 NSString *const kTuduPushPayloadPayloadTypeActivityKey  = @"a";
 
 NSString *const kTuduPushPayloadActivityTypeKey     = @"t";
 NSString *const kTuduPushPayloadActivityLikeKey     = @"l";
 NSString *const kTuduPushPayloadActivityCommentKey  = @"c";
 NSString *const kTuduPushPayloadActivityFollowKey   = @"f";
 
 NSString *const kTuduPushPayloadFromUserObjectIdKey = @"fu";
 NSString *const kTuduPushPayloadToUserObjectIdKey   = @"tu";
 NSString *const kTuduPushPayloadPhotoObjectIdKey    = @"pid";
 */


////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
#pragma mark - Photo Class
// Class key
NSString *const kTuduPhotoClassKey = @"Photo";

// Field keys
NSString *const kTuduPhotoPictureKey         = @"image";
NSString *const kTuduPhotoThumbnailKey       = @"thumbnail";
NSString *const kTuduPhotoUserKey            = @"user";
NSString *const kTuduPhotoOpenGraphIDKey    = @"fbOpenGraphID";

#pragma mark - Cached Photo Attributes
// keys
NSString *const kTuduPhotoAttributesIsLikedByCurrentUserKey = @"isLikedByCurrentUser";
NSString *const kTuduPhotoAttributesLikeCountKey            = @"likeCount";
NSString *const kTuduPhotoAttributesLikersKey               = @"likers";
NSString *const kTuduPhotoAttributesCommentCountKey         = @"commentCount";
NSString *const kTuduPhotoAttributesCommentersKey           = @"commenters";


#pragma mark - Cached User Attributes
// keys
NSString *const kTuduUserAttributesPhotoCountKey                 = @"photoCount";
NSString *const kTuduUserAttributesIsFollowedByCurrentUserKey    = @"isFollowedByCurrentUser";


#pragma mark - Push Notification Payload Keys

NSString *const kAPNSAlertKey = @"alert";
NSString *const kAPNSBadgeKey = @"badge";
NSString *const kAPNSSoundKey = @"sound";
*/
