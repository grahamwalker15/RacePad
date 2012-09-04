#import "MidasTwitterTweet.h"

@implementation MidasTwitterTweet

+ (NSArray *)dct_uniqueKeys {
	return @[MidasTwitterTweetAttributes.tweetID];
}

+ (NSDictionary *)dct_mappingFromRemoteNamesToLocalNames {
	
	return @{ @"id_str" : MidasTwitterTweetAttributes.tweetID,
				@"text" : MidasTwitterTweetAttributes.text,
		  @"created_at" : MidasTwitterTweetAttributes.date,
				@"user" : MidasTwitterTweetRelationships.user };
}

+ (id)dct_convertValue:(id)value toCorrectTypeForKey:(NSString *)key {
	
	if (![key isEqualToString:MidasTwitterTweetAttributes.date])
		return value;
	
	static NSDateFormatter *dateFormatter = nil;
	static dispatch_once_t dateFormatterToken;
	dispatch_once(&dateFormatterToken, ^{
		dateFormatter = [NSDateFormatter new];
		[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
		// Fri Jul 16 16:58:46 +0000 2010
		[dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
	});
	
	NSDate *date = [dateFormatter dateFromString:value];
	if (date) return date;
	
	// There are two formats twitter gives out, if this fails try the other one...
	
	static NSDateFormatter *secondDateFormatter = nil;
	static dispatch_once_t secondDateFormatterToken;
	dispatch_once(&secondDateFormatterToken, ^{
		secondDateFormatter = [NSDateFormatter new];
		[secondDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
		// Thu, 06 Oct 2011 19:36:17 +0000
		[secondDateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
	});
	
	return [secondDateFormatter dateFromString:value];
}

@end
