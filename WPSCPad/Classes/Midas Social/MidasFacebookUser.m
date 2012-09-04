#import "MidasFacebookUser.h"

@implementation MidasFacebookUser

+ (NSArray *)dct_uniqueKeys {
	return @[MidasFacebookUserAttributes.userID];
}

+ (NSDictionary *)dct_mappingFromRemoteNamesToLocalNames {
	return @{ @"id" : MidasFacebookUserAttributes.userID,
			@"name" : MidasFacebookUserAttributes.name };
}

@end
