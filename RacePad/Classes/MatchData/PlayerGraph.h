//
//  PlayerGraph.h
//  MatchPad
//
//  Created by Mark Riches on 12/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataStream;
@class PlayerGraphView;
@class PlayerGraph;
@class ImageList;

enum GraphType {
	PGV_EFFECTIVENESS,
	PGV_PASSES
};

@interface PlayerGraphLine : NSObject
{
	UIColor *colour;
	float x0, y0, x1, y1;
}

@property (readonly) CGMutablePathRef path;
@property (readonly) UIColor *colour;
@property (readonly) float x0;
@property (readonly) float y0;
@property (readonly) float x1;
@property (readonly) float y1;

- (void) loadShape : (DataStream *) stream Count: (int) count Colours: (UIColor **)colours ColoursCount:(int)coloursCount;

@end

@interface PlayerGraph : NSObject
{
	
	float xCentre;
	float yCentre;
	
	float width;
	float height;
	
	NSMutableArray *lines;
	UIColor **colours;
	int coloursCount;

	int requestedPlayer;
	unsigned char graph_type;
	
	NSString *playerName;
	int nextPlayer;
	int prevPlayer;
}

@property (nonatomic) int requestedPlayer;
@property (nonatomic) unsigned char graphType;
@property (nonatomic, retain) NSString * playerName;
@property (nonatomic) int nextPlayer;
@property (nonatomic) int prevPlayer;

- (void) loadGraph : (DataStream *) stream;

- (void) drawInView:(PlayerGraphView *)view;

@end
