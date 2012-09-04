// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MidasTwitterTweet.h instead.

#import <CoreData/CoreData.h>


extern const struct MidasTwitterTweetAttributes {
	__unsafe_unretained NSString *date;
	__unsafe_unretained NSString *read;
	__unsafe_unretained NSString *text;
	__unsafe_unretained NSString *tweetID;
	__unsafe_unretained NSString *userRetweeted;
} MidasTwitterTweetAttributes;

extern const struct MidasTwitterTweetRelationships {
	__unsafe_unretained NSString *user;
} MidasTwitterTweetRelationships;

extern const struct MidasTwitterTweetFetchedProperties {
} MidasTwitterTweetFetchedProperties;

@class MidasTwitterUser;







@interface MidasTwitterTweetID : NSManagedObjectID {}
@end

@interface _MidasTwitterTweet : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MidasTwitterTweetID*)objectID;




@property (nonatomic, strong) NSDate* date;


//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* read;


@property BOOL readValue;
- (BOOL)readValue;
- (void)setReadValue:(BOOL)value_;

//- (BOOL)validateRead:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* text;


//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* tweetID;


//- (BOOL)validateTweetID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* userRetweeted;


@property BOOL userRetweetedValue;
- (BOOL)userRetweetedValue;
- (void)setUserRetweetedValue:(BOOL)value_;

//- (BOOL)validateUserRetweeted:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) MidasTwitterUser* user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;





#if TARGET_OS_IPHONE



#endif

@end

@interface _MidasTwitterTweet (CoreDataGeneratedAccessors)

@end

@interface _MidasTwitterTweet (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;




- (NSNumber*)primitiveRead;
- (void)setPrimitiveRead:(NSNumber*)value;

- (BOOL)primitiveReadValue;
- (void)setPrimitiveReadValue:(BOOL)value_;




- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;




- (NSString*)primitiveTweetID;
- (void)setPrimitiveTweetID:(NSString*)value;




- (NSNumber*)primitiveUserRetweeted;
- (void)setPrimitiveUserRetweeted:(NSNumber*)value;

- (BOOL)primitiveUserRetweetedValue;
- (void)setPrimitiveUserRetweetedValue:(BOOL)value_;





- (MidasTwitterUser*)primitiveUser;
- (void)setPrimitiveUser:(MidasTwitterUser*)value;


@end
