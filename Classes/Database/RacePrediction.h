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
	NSString *user;
	int score;
	int position;
	bool equal;
	unsigned char gameStatus;
}

@property (readonly) int count;
@property (nonatomic, retain) NSString *user;
@property (readonly) int score;
@property (readonly) int position;
@property (readonly) bool equal;
@property (readonly) unsigned char gameStatus;

- (void) clear;
- (bool) load : (DataStream *) stream;
- (int *) prediction;

@end
