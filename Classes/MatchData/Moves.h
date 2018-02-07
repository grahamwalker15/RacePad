//
//  Moves.h
//  RacePad
//
//  Created by Gareth Griffith on 5/10/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataStream;
@class MoveView;

@interface MoveChunk : NSObject
{
	float startTime;
	float duration;
	int passes;
}

@property (nonatomic) float startTime;
@property (nonatomic) float duration;
@property (nonatomic) int passes;

- (void) load : (DataStream *) stream;

@end


@interface Moves : NSObject
{
	NSMutableArray *moves[2];
	NSMutableArray *goals[2];
	float duration[2];
	int maxPasses;
}

- (void) clearData;
- (void) loadData : (DataStream *) stream;

- (void) clearStaticData;

- (void) drawInView : (MoveView *)view;

@end
