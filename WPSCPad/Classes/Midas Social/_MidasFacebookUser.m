// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MidasFacebookUser.m instead.

#import "_MidasFacebookUser.h"

const struct MidasFacebookUserAttributes MidasFacebookUserAttributes = {
	.name = @"name",
	.userID = @"userID",
};

const struct MidasFacebookUserRelationships MidasFacebookUserRelationships = {
	.comments = @"comments",
};

const struct MidasFacebookUserFetchedProperties MidasFacebookUserFetchedProperties = {
};

@implementation MidasFacebookUserID
@end

@implementation _MidasFacebookUser

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MidasFacebookUser" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MidasFacebookUser";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MidasFacebookUser" inManagedObjectContext:moc_];
}

- (MidasFacebookUserID*)objectID {
	return (MidasFacebookUserID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic userID;






@dynamic comments;

	
- (NSMutableSet*)commentsSet {
	[self willAccessValueForKey:@"comments"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"comments"];
  
	[self didAccessValueForKey:@"comments"];
	return result;
}
	






#if TARGET_OS_IPHONE


- (NSFetchedResultsController *)newCommentsFetchedResultsControllerWithSortDescriptors:(NSArray *)sortDescriptors {
	NSFetchRequest *fetchRequest = [NSFetchRequest new];
	
	fetchRequest.entity = [NSEntityDescription entityForName:@"MidasFacebookComment" inManagedObjectContext:self.managedObjectContext];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user == %@", self];
	fetchRequest.sortDescriptors = sortDescriptors;
	
	return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
											   managedObjectContext:self.managedObjectContext
												 sectionNameKeyPath:nil
														  cacheName:nil];
}


#endif

@end
