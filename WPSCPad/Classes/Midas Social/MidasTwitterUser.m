#import "MidasTwitterUser.h"

@implementation MidasTwitterUser

+ (id)dct_objectFromDictionary:(NSDictionary *)dictionary insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
	
	NSString *username = [dictionary objectForKey:@"screen_name"];
	NSNumber *userID = [dictionary objectForKey:@"id"];
	
	MidasTwitterUser *user = nil;
	
	if (userID) {
		NSPredicate *p = [NSPredicate dct_predicateWhereProperty:MidasTwitterUserAttributes.userID equals:userID];
		user = [context dct_fetchAnyObjectForEntityName:[MidasTwitterUser entityName] predicate:p];
	}
	
	if (!user && username) {
		NSPredicate *p = [NSPredicate dct_predicateWhereProperty:MidasTwitterUserAttributes.username equals:username];
		user = [context dct_fetchAnyObjectForEntityName:[MidasTwitterUser entityName] predicate:p];
	}
	
	if (!user) user = [MidasTwitterUser insertInManagedObjectContext:context];
	
	[user dct_setupFromDictionary:dictionary];
	
	return user;
}

+ (NSArray *)dct_uniqueKeys {
	return @[MidasTwitterUserAttributes.userID];
}

+ (NSDictionary *)dct_mappingFromRemoteNamesToLocalNames {
	
	return @{ @"name" : MidasTwitterUserAttributes.name,
	   @"screen_name" : MidasTwitterUserAttributes.username,
				@"id" : MidasTwitterUserAttributes.userID,
		 @"from_user" : MidasTwitterUserAttributes.username,
  @"from_user_id_str" : MidasTwitterUserAttributes.userID,
	@"from_user_name" : MidasTwitterUserAttributes.name };
}

+ (id)dct_convertValue:(id)value toCorrectTypeForKey:(NSString *)key {

	if (![key isEqualToString:MidasTwitterUserAttributes.userID])
		return value;
	
	if ([value isKindOfClass:[NSString class]])
		return value;
	
	return [value stringValue];
}

@end
