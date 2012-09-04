// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MidasFacebookComment.h instead.

#import <CoreData/CoreData.h>


extern const struct MidasFacebookCommentAttributes {
	__unsafe_unretained NSString *commentID;
	__unsafe_unretained NSString *date;
	__unsafe_unretained NSString *likesCount;
	__unsafe_unretained NSString *read;
	__unsafe_unretained NSString *text;
	__unsafe_unretained NSString *userLiked;
} MidasFacebookCommentAttributes;

extern const struct MidasFacebookCommentRelationships {
	__unsafe_unretained NSString *user;
} MidasFacebookCommentRelationships;

extern const struct MidasFacebookCommentFetchedProperties {
} MidasFacebookCommentFetchedProperties;

@class MidasFacebookUser;








@interface MidasFacebookCommentID : NSManagedObjectID {}
@end

@interface _MidasFacebookComment : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MidasFacebookCommentID*)objectID;




@property (nonatomic, strong) NSString* commentID;


//- (BOOL)validateCommentID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate* date;


//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* likesCount;


@property int16_t likesCountValue;
- (int16_t)likesCountValue;
- (void)setLikesCountValue:(int16_t)value_;

//- (BOOL)validateLikesCount:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* read;


@property BOOL readValue;
- (BOOL)readValue;
- (void)setReadValue:(BOOL)value_;

//- (BOOL)validateRead:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* text;


//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* userLiked;


@property BOOL userLikedValue;
- (BOOL)userLikedValue;
- (void)setUserLikedValue:(BOOL)value_;

//- (BOOL)validateUserLiked:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) MidasFacebookUser* user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;





#if TARGET_OS_IPHONE



#endif

@end

@interface _MidasFacebookComment (CoreDataGeneratedAccessors)

@end

@interface _MidasFacebookComment (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCommentID;
- (void)setPrimitiveCommentID:(NSString*)value;




- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;




- (NSNumber*)primitiveLikesCount;
- (void)setPrimitiveLikesCount:(NSNumber*)value;

- (int16_t)primitiveLikesCountValue;
- (void)setPrimitiveLikesCountValue:(int16_t)value_;




- (NSNumber*)primitiveRead;
- (void)setPrimitiveRead:(NSNumber*)value;

- (BOOL)primitiveReadValue;
- (void)setPrimitiveReadValue:(BOOL)value_;




- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;




- (NSNumber*)primitiveUserLiked;
- (void)setPrimitiveUserLiked:(NSNumber*)value;

- (BOOL)primitiveUserLikedValue;
- (void)setPrimitiveUserLikedValue:(BOOL)value_;





- (MidasFacebookUser*)primitiveUser;
- (void)setPrimitiveUser:(MidasFacebookUser*)value;


@end
