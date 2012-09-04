#import "MidasFacebookComment.h"
#import "ISO8601DateFormatter.h"

@implementation MidasFacebookComment

+ (NSArray *)dct_uniqueKeys {
	return @[MidasFacebookCommentAttributes.commentID];
}

+ (NSDictionary *)dct_mappingFromRemoteNamesToLocalNames {
	return @{ @"id" : MidasFacebookCommentAttributes.commentID,
		 @"message" : MidasFacebookCommentAttributes.text,
	@"created_time" : MidasFacebookCommentAttributes.date,
	   @"like_count": MidasFacebookCommentAttributes.likesCount,
			@"from" : MidasFacebookCommentRelationships.user };
}

+ (id)dct_convertValue:(id)value toCorrectTypeForKey:(NSString *)key {
	
	if ([key isEqualToString:MidasFacebookCommentAttributes.commentID]
		&& ![value isKindOfClass:[NSString class]])
		return [value description];
	
	
	if (![key isEqualToString:MidasFacebookCommentAttributes.date])
		return value;
	
	static ISO8601DateFormatter *dateFormatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		dateFormatter = [ISO8601DateFormatter new];
	});
	
	return [dateFormatter dateFromString:value];
}

@end
