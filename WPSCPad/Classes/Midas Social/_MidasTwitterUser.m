// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MidasTwitterUser.m instead.

#import "_MidasTwitterUser.h"

const struct MidasTwitterUserAttributes MidasTwitterUserAttributes = {
	.name = @"name",
	.userID = @"userID",
	.username = @"username",
};

const struct MidasTwitterUserRelationships MidasTwitterUserRelationships = {
	.tweets = @"tweets",
};

const struct MidasTwitterUserFetchedProperties MidasTwitterUserFetchedProperties = {
};

@implementation MidasTwitterUserID
@end

@implementation _MidasTwitterUser

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MidasTwitterUser" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MidasTwitterUser";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MidasTwitterUser" inManagedObjectContext:moc_];
}

- (MidasTwitterUserID*)objectID {
	return (MidasTwitterUserID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic userID;






@dynamic username;






@dynamic tweets;

	
- (NSMutableSet*)tweetsSet {
	[self willAccessValueForKey:@"tweets"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tweets"];
  
	[self didAccessValueForKey:@"tweets"];
	return result;
}
	






#if TARGET_OS_IPHONE


- (NSFetchedResultsController *)newTweetsFetchedResultsControllerWithSortDescriptors:(NSArray *)sortDescriptors {
	NSFetchRequest *fetchRequest = [NSFetchRequest new];
	
	fetchRequest.entity = [NSEntityDescription entityForName:@"MidasTwitterTweet" inManagedObjectContext:self.managedObjectContext];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user == %@", self];
	fetchRequest.sortDescriptors = sortDescriptors;
	
	return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
											   managedObjectContext:self.managedObjectContext
												 sectionNameKeyPath:nil
														  cacheName:nil];
}


#endif

@end
