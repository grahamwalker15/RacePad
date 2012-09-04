// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MidasFacebookComment.m instead.

#import "_MidasFacebookComment.h"

const struct MidasFacebookCommentAttributes MidasFacebookCommentAttributes = {
	.commentID = @"commentID",
	.date = @"date",
	.likesCount = @"likesCount",
	.read = @"read",
	.text = @"text",
	.userLiked = @"userLiked",
};

const struct MidasFacebookCommentRelationships MidasFacebookCommentRelationships = {
	.user = @"user",
};

const struct MidasFacebookCommentFetchedProperties MidasFacebookCommentFetchedProperties = {
};

@implementation MidasFacebookCommentID
@end

@implementation _MidasFacebookComment

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MidasFacebookComment" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MidasFacebookComment";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MidasFacebookComment" inManagedObjectContext:moc_];
}

- (MidasFacebookCommentID*)objectID {
	return (MidasFacebookCommentID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"likesCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"likesCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"readValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"read"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"userLikedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"userLiked"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic commentID;






@dynamic date;






@dynamic likesCount;



- (int16_t)likesCountValue {
	NSNumber *result = [self likesCount];
	return [result shortValue];
}

- (void)setLikesCountValue:(int16_t)value_ {
	[self setLikesCount:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveLikesCountValue {
	NSNumber *result = [self primitiveLikesCount];
	return [result shortValue];
}

- (void)setPrimitiveLikesCountValue:(int16_t)value_ {
	[self setPrimitiveLikesCount:[NSNumber numberWithShort:value_]];
}





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






@dynamic userLiked;



- (BOOL)userLikedValue {
	NSNumber *result = [self userLiked];
	return [result boolValue];
}

- (void)setUserLikedValue:(BOOL)value_ {
	[self setUserLiked:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveUserLikedValue {
	NSNumber *result = [self primitiveUserLiked];
	return [result boolValue];
}

- (void)setPrimitiveUserLikedValue:(BOOL)value_ {
	[self setPrimitiveUserLiked:[NSNumber numberWithBool:value_]];
}





@dynamic user;

	






#if TARGET_OS_IPHONE



#endif

@end
