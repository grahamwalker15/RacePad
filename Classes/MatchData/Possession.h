//
//  Possession.h
//  RacePad
//
//  Created by Gareth Griffith on 5/10/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataStream;
@class PossessionView;

@interface Possession : NSObject
{
	NSMutableArray *data[2];
	NSMutableArray *goals[2];
}

- (void) clearData;
- (void) loadData : (DataStream *) stream;

- (void) clearStaticData;

- (void) drawInView : (PossessionView *)view;

@end
