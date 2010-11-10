//
//  AlertData.h
//  RacePad
//
//  Created by Gareth Griffith on 11/10/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AlertDataItem : NSObject
{
	int type;
	int focus;
	int lap;
	float time_stamp;
	NSString * description;	
}

@property (nonatomic) int type;
@property (nonatomic) int focus;
@property (nonatomic) int lap;
@property (nonatomic) float timeStamp;
@property (nonatomic, retain) NSString * description;	

- (id) initWithType:(int)typeIn Lap:(int)lapIn TimeStamp:(float)timeStampIn Focus:(int)focusIn Description:(NSString *)descriptionIn;
- (id) initWithType:(int)typeIn Lap:(int)lapIn H:(float)hIn M:(float)mIn S:(float)sIn Focus:(int)focusIn Description:(NSString *)descriptionIn;

@end

@interface AlertData : NSObject
{
	NSMutableArray * alerts; 
}

- (int) itemCount;

@end
