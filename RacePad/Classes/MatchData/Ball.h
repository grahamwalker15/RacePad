//
//  Ball.h
//  RacePad
//
//  Created by Gareth Griffith on 5/10/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataStream;
@class BallView;

@interface BallChunk : NSObject
{
	float time;
	float position;
	bool newMove;
}

@property (nonatomic) float time;
@property (nonatomic) float position;
@property (nonatomic) bool newMove;

- (void) load : (DataStream *) stream;

@end


@interface Ball : NSObject
{
	NSMutableArray *kicks[2];
	NSMutableArray *goals[2];
	float duration[2];
}

- (void) clearData;
- (void) loadData : (DataStream *) stream;

- (void) clearStaticData;

- (void) drawInView : (BallView *)view;

@end
