// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MidasTwitterTweet.m instead.

#import "_MidasTwitterTweet.h"

const struct MidasTwitterTweetAttributes MidasTwitterTweetAttributes = {
	.date = @"date",
	.read = @"read",
	.text = @"text",
	.tweetID = @"tweetID",
	.userRetweeted = @"userRetweeted",
};

const struct MidasTwitterTweetRelationships MidasTwitterTweetRelationships = {
	.user = @"user",
};

const struct MidasTwitterTweetFetchedProperties MidasTwitterTweetFetchedProperties = {
};

@implementation MidasTwitterTweetID
@end

@implementation _MidasTwitterTweet

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MidasTwitterTweet" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MidasTwitterTweet";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MidasTwitterTweet" inManagedObjectContext:moc_];
}

- (MidasTwitterTweetID*)objectID {
	return (MidasTwitterTweetID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"readValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"read"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"userRetweetedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"userRetweeted"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic date;






@dynamic read;



- (BOOL)readValue {
	NSNumber *result = [self read];
	return [result boolValue];
}

- (void)setReadValue:(BOOL)value_ {
	[self setRead:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveReadValue {
	NSNumber *result = [self primitiveRead];
	return [result boolValue];
}

- (void)setPrimitiveReadValue:(BOOL)value_ {
	[self setPrimitiveRead:[NSNumber numberWithBool:value_]];
}





@dynamic text;






@dynamic tweetID;






@dynamic userRetweeted;



- (BOOL)userRetweetedValue {
	NSNumber *result = [self userRetweeted];
	return [result boolValue];
}

- (void)setUserRetweetedValue:(BOOL)value_ {
	[self setUserRetweeted:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveUserRetweetedValue {
	NSNumber *result = [self primitiveUserRetweeted];
	return [result boolValue];
}

- (void)setPrimitiveUserRetweetedValue:(BOOL)value_ {
	[self setPrimitiveUserRetweeted:[NSNumber numberWithBool:value_]];
}





@dynamic user;

	






#if TARGET_OS_IPHONE



#endif

@end
