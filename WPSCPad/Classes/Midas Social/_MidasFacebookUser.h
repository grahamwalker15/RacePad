// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MidasFacebookUser.h instead.

#import <CoreData/CoreData.h>


extern const struct MidasFacebookUserAttributes {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *userID;
} MidasFacebookUserAttributes;

extern const struct MidasFacebookUserRelationships {
	__unsafe_unretained NSString *comments;
} MidasFacebookUserRelationships;

extern const struct MidasFacebookUserFetchedProperties {
} MidasFacebookUserFetchedProperties;

@class MidasFacebookComment;




@interface MidasFacebookUserID : NSManagedObjectID {}
@end

@interface _MidasFacebookUser : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MidasFacebookUserID*)objectID;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* userID;


//- (BOOL)validateUserID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet* comments;

- (NSMutableSet*)commentsSet;





#if TARGET_OS_IPHONE


- (NSFetchedResultsController *)newCommentsFetchedResultsControllerWithSortDescriptors:(NSArray *)sortDescriptors;


#endif

@end

@interface _MidasFacebookUser (CoreDataGeneratedAccessors)

- (void)addComments:(NSSet*)value_;
- (void)removeComments:(NSSet*)value_;
- (void)addCommentsObject:(MidasFacebookComment*)value_;
- (void)removeCommentsObject:(MidasFacebookComment*)value_;

@end

@interface _MidasFacebookUser (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveUserID;
- (void)setPrimitiveUserID:(NSString*)value;





- (NSMutableSet*)primitiveComments;
- (void)setPrimitiveComments:(NSMutableSet*)value;


@end
