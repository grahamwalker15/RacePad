//
//  DriverNames.h
//  RacePad
//
//  Created by Mark Riches on 11/10/2010.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataStream;

@interface DriverName : NSObject
{
	NSString *name;
	NSString *abbr;
	NSString *team;
	int number;
};

@property (retain) NSString *name;
@property (retain) NSString *abbr;
@property (retain) NSString *team;
@property int number;

- (DriverName *)initWithStream:(DataStream*)stream;

@end

@interface DriverNames : NSObject
{
	NSMutableArray *drivers;
	int count;
	int blueCar;
	int redCar;
}

- (int)count;
- (DriverName *) driver : (int) index;
- (DriverName *) driverByNumber : (int) number;
- (int) driverIndexByNumber : (int) number;
- (DriverName *) blueCar;
- (DriverName *) redCar;

- (void) loadData : (DataStream *) stream;

@end
