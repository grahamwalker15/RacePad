//
//  RacePrediction.h
//  RacePad
//
//  Created by Gareth Griffith on 11/10/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataStream;

enum GameStatus {
	GS_NOT_STARTED,
	GS_PLAYING,
	GS_FINISHED,
};

@interface RacePrediction : NSObject
{
	int count;
	int prediction[8];
	int scores[8];
	NSString *user;
	int pin;
	int score;
	int position;
	bool equal;
	unsigned char gameStatus;
	int startTime;
	bool cleared;
}

@property (readonly) int count;
@property (readonly) NSString *user;
@property (readonly) int pin;
@property (readonly) int score;
@property (readonly) int position;
@property (readonly) bool equal;
@property (readonly) unsigned char gameStatus;
@property (readonly) int startTime;
@property (readonly) bool cleared;

- (void) clear;
- (bool) load : (DataStream *) stream;
- (void) loadStatus : (DataStream *) stream;
- (int *) prediction;
- (int *) scores;
- (void) setUser:(NSString *) name;
- (void) noUser;

@end
