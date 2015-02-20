//
//  TuduConstants.h
//

typedef enum {
	TuduCreateEventTabBarItemIndex = 0,
	TuduSearchTabBarItemIndex = 1,
	TuduHomeTabBarItemIndex = 2,
	TuduActivityFeedTabBarItemIndex = 3,
	TuduProfileTabBarItemIndex = 4
} TuduTabBarControllerViewControllerIndex;

#define kTuduParseEmployeeAccounts [NSArray arrayWithObjects:@"400680", @"403902", @"702499", @"1225726", @"4806789", @"6409809", @"12800553", @"121800083", @"500011038", @"558159381", @"721873341", @"723748661", @"865225242", nil]

#pragma mark - NSUserDefaults
extern NSString *const kTuduUserDefaultsActivityFeedViewControllerLastRefreshKey;
extern NSString *const kTuduUserDefaultsCacheFacebookFriendsKey;

#pragma mark - Launch URLs

extern NSString *const kTuduLaunchURLHostTakePicture;


#pragma mark - NSNotification
extern NSString *const TuduAppDelegateApplicationDidReceiveRemoteNotification;
extern NSString *const TuduUtilityUserFollowingChangedNotification;
extern NSString *const TuduUtilityUserAttendedUnattendedEventCallbackFinishedNotification;
extern NSString *const TuduUtilityDidFinishProcessingProfilePictureNotification;
extern NSString *const TuduTabBarControllerDidFinishEditingEventNotification;
extern NSString *const TuduTabBarControllerDidFinishImageFileUploadNotification;
extern NSString *const TuduEventDetailsViewControllerUserDeletedEventNotification;
extern NSString *const TuduEventDetailsViewControllerUserAttendedUnattendedEventNotification;
extern NSString *const TuduEventDetailsViewControllerUserCommentedOnEventNotification;


#pragma mark - User Info Keys
extern NSString *const TuduEventDetailsViewControllerUserAttendedUnattendedEventNotificationUserInfoAttendedKey;
extern NSString *const kTuduEditEventViewControllerUserInfoCommentKey;


#pragma mark - Installation Class

// Field keys
extern NSString *const kTuduInstallationUserKey;


#pragma mark - PFObject Activity Class
// Class key
extern NSString *const kTuduActivityClassKey;

// Field keys
extern NSString *const kTuduActivityTypeKey;
extern NSString *const kTuduActivityFromUserKey;
extern NSString *const kTuduActivityToUserKey;
extern NSString *const kTuduActivityContentKey;
extern NSString *const kTuduActivityPhotoKey;
extern NSString *const kTuduActivityEventKey;

// Type values
extern NSString *const kTuduActivityTypeLike;
extern NSString *const kTuduActivityTypeFollow;
extern NSString *const kTuduActivityTypeComment;
extern NSString *const kTuduActivityTypeJoined;
extern NSString *const kTuduActivityTypeAttend;
extern NSString *const kTuduActivityTypeInvite;
extern int *statusBarHeight;// = [UIApplication sharedApplication].statusBarFrame.size.height;


#pragma mark - PFObject User Class
// Field keys
extern NSString *const kTuduUserDisplayNameKey;
extern NSString *const kTuduUserFacebookIDKey;
extern NSString *const kTuduUserPhotoIDKey;
extern NSString *const kTuduUserProfilePicSmallKey;
extern NSString *const kTuduUserProfilePicMediumKey;
extern NSString *const kTuduUserFacebookFriendsKey;
extern NSString *const kTuduUserAlreadyAutoFollowedFacebookFriendsKey;


#pragma mark - Event Class
//Class key
extern NSString *const kTuduEventClassKey;

//Field Keys
extern NSString *const kTuduEventPrivacyTypeKey;	// string
extern NSString *const kTuduEventUserKey;       	// User
extern NSString *const kTuduEventTypeKey;  			// string
extern NSString *const kTuduEventTitleKey;      		// string
extern NSString *const kTuduEventDescriptionKey;      	// string
extern NSString *const kTuduEventDateKey;      		// string
extern NSString *const kTuduEventLocationKey;      	// string
extern NSString *const kTuduEventInviteListKey; 		// array<usernames>

// Type Values
extern NSString *const kTuduEventPrivacyTypePublic;
extern NSString *const kTuduEventPrivacyTypeHostInvite;
extern NSString *const kTuduEventPrivacyTypeHostGuestInvite;
extern NSString *const kTuduEventTypeParty;
extern NSString *const kTuduEventTypeKickBack;
extern NSString *const kTuduEventTypeOutdoor;
extern NSString *const kTuduEventTypeDine;
extern NSString *const kTuduEventTypeProfessional;
extern NSString *const kTuduEventTypePickup;


#pragma mark - Cached Event Attributes
// keys
extern NSString *const kTuduEventAttributesIsAttendedByCurrentUserKey;
extern NSString *const kTuduEventAttributesAttendCountKey;
extern NSString *const kTuduEventAttributesAttendersKey;
extern NSString *const kTuduEventAttributesCommentCountKey;
extern NSString *const kTuduEventAttributesCommentersKey;
extern NSString *const kTuduEventAttributesInvitedPeopleKey;
extern NSString *const kTuduEventAttributesInviteCountKey;


#pragma mark - Cached User Attributes
// keys
extern NSString *const kTuduUserAttributesEventCountKey;
extern NSString *const kTuduUserAttributesIsFollowedByCurrentUserKey;


#pragma mark - PFPush Notification Payload Keys

extern NSString *const kAPNSAlertKey;
extern NSString *const kAPNSBadgeKey;
extern NSString *const kAPNSSoundKey;

extern NSString *const kTuduPushPayloadPayloadTypeKey;
extern NSString *const kTuduPushPayloadPayloadTypeActivityKey;

extern NSString *const kTuduPushPayloadActivityTypeKey;
extern NSString *const kTuduPushPayloadActivityLikeKey;
extern NSString *const kTuduPushPayloadActivityCommentKey;
extern NSString *const kTuduPushPayloadActivityFollowKey;

extern NSString *const kTuduPushPayloadFromUserObjectIdKey;
extern NSString *const kTuduPushPayloadToUserObjectIdKey;
extern NSString *const kTuduPushPayloadPhotoObjectIdKey;

///////////////////////////////////////////////////////////////////////////////////////////////


#pragma mark - PFObject Photo Class
// Class key
extern NSString *const kTuduPhotoClassKey;

// Field keys
extern NSString *const kTuduPhotoPictureKey;
extern NSString *const kTuduPhotoThumbnailKey;
extern NSString *const kTuduPhotoUserKey;
extern NSString *const kTuduPhotoOpenGraphIDKey;

#pragma mark - Cached Photo Attributes
// keys
extern NSString *const kTuduPhotoAttributesIsLikedByCurrentUserKey;
extern NSString *const kTuduPhotoAttributesLikeCountKey;
extern NSString *const kTuduPhotoAttributesLikersKey;
extern NSString *const kTuduPhotoAttributesCommentCountKey;
extern NSString *const kTuduPhotoAttributesCommentersKey;


#pragma mark - Cached User Attributes
// keys
extern NSString *const kTuduUserAttributesPhotoCountKey;
extern NSString *const kTuduUserAttributesIsFollowedByCurrentUserKey;


#pragma mark - PFPush Notification Payload Keys

extern NSString *const kAPNSAlertKey;
extern NSString *const kAPNSBadgeKey;
extern NSString *const kAPNSSoundKey;

extern NSString *const kTuduPushPayloadPayloadTypeKey;
extern NSString *const kTuduPushPayloadPayloadTypeActivityKey;

extern NSString *const kTuduPushPayloadActivityTypeKey;
extern NSString *const kTuduPushPayloadActivityLikeKey;
extern NSString *const kTuduPushPayloadActivityCommentKey;
extern NSString *const kTuduPushPayloadActivityFollowKey;

extern NSString *const kTuduPushPayloadFromUserObjectIdKey;
extern NSString *const kTuduPushPayloadToUserObjectIdKey;
extern NSString *const kTuduPushPayloadPhotoObjectIdKey;