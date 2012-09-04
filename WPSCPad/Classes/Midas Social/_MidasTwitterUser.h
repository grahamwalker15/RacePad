// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MidasTwitterUser.h instead.

#import <CoreData/CoreData.h>


extern const struct MidasTwitterUserAttributes {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *userID;
	__unsafe_unretained NSString *username;
} MidasTwitterUserAttributes;

extern const struct MidasTwitterUserRelationships {
	__unsafe_unretained NSString *tweets;
} MidasTwitterUserRelationships;

extern const struct MidasTwitterUserFetchedProperties {
} MidasTwitterUserFetchedProperties;

@class MidasTwitterTweet;





@interface MidasTwitterUserID : NSManagedObjectID {}
@end

@interface _MidasTwitterUser : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MidasTwitterUserID*)objectID;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* userID;


//- (BOOL)validateUserID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* username;


//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet* tweets;

- (NSMutableSet*)tweetsSet;





#if TARGET_OS_IPHONE


- (NSFetchedResultsController *)newTweetsFetchedResultsControllerWithSortDescriptors:(NSArray *)sortDescriptors;


#endif

@end

@interface _MidasTwitterUser (CoreDataGeneratedAccessors)

- (void)addTweets:(NSSet*)value_;
- (void)removeTweets:(NSSet*)value_;
- (void)addTweetsObject:(MidasTwitterTweet*)value_;
- (void)removeTweetsObject:(MidasTwitterTweet*)value_;

@end

@interface _MidasTwitterUser (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveUserID;
- (void)setPrimitiveUserID:(NSString*)value;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;





- (NSMutableSet*)primitiveTweets;
- (void)setPrimitiveTweets:(NSMutableSet*)value;


@end
