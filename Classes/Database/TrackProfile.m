//
//  TrackProfile.m
//  RacePad
//
//  Created by Mark Riches on 12/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TrackProfile.h"
#import "DataStream.h"
#import "TrackMapView.h"
#import "MathOdds.h"
#import "TrackProfileView.h"
#import "ImageListStore.h"
#import "RacePadDatabase.h"

@implementation TrackProfileCar

@synthesize name;
@synthesize lapProgress;

static UIColor *blueBG = nil;
static UIColor *blueMargin = nil;
static UIColor *blueSC = nil;
static UIColor *axisColor = nil;
static UIImage *kerbImage = nil;
static UIImage *trackImage = nil;
static UIImage *grassImage = nil;

- (id) init
{
	pointColour = nil;
	fillColour = nil;
	lineColour = nil;
	textColour = nil;
	
	name = nil;
	
	return [super init];
}

- (void) dealloc
{
	[pointColour release];
	[fillColour release];
	[lineColour release];
	[textColour release];
	[name release];
	
	[super dealloc];
}

- (UIColor *) loadColour: (DataStream *)stream Colours: (UIColor **)colours ColoursCount:(int)coloursCount
{
	unsigned char index = [stream PopUnsignedChar];
	if ( index < coloursCount )
		return [colours[index] retain];
	
	return nil;
}

- (void) load:(DataStream *)stream Colours: (UIColor **)colours ColoursCount:(int)coloursCount
{
	[pointColour release];
	[fillColour release];
	[lineColour release];
	[textColour release];
	[name release];

	pointColour = nil;
	fillColour = nil;
	lineColour = nil;
	textColour = nil;
	name = nil;


	pointColour = [self loadColour:stream Colours:colours ColoursCount:coloursCount];
	lapProgress = [stream PopFloat];
	moving = [stream PopBool];
	
	if ( moving )
	{
		fillColour = [self loadColour:stream Colours:colours ColoursCount:coloursCount];
		lineColour = [self loadColour:stream Colours:colours ColoursCount:coloursCount];
		textColour = [self loadColour:stream Colours:colours ColoursCount:coloursCount];
		
		name = [[stream PopString] retain];
	}
}

- (void) draw:(TrackProfileView *)view OnMap:(TrackProfile *)trackProfile Offset:(float) offset ImageList:(ImageList *)imageList
{
	bool isFollowCar = ([[view carToFollow] isEqualToString:name]);
	
	CGSize size = [view bounds].size;
	
	float boxWidth = 48;
	float boxHeight = 22;
	
	float ox = (lapProgress - offset);
	if ( ox < 0 )
		ox += 1;
	if ( ox > 1 )
		ox -= 1;
	float tx = [view transformX:ox];
	
	float px = tx * size.width;
	float py = size.height / 2;
	
	// Draw car
	if(imageList)
	{
		UIImage *image = [imageList findItem:name];
		[view DrawImage:image AtX:px Y:py - 40];
	}

	int dotSize = 4;
	[view SetBGColour:pointColour];
	[view FillRectangleX0:px-dotSize Y0:py-dotSize X1:px+dotSize Y1:py+dotSize];
	
	if ( moving )
	{
		float x0 = px + 5;
		float y0 = py + 2;
		float x1 = x0 + boxWidth;
		float y1 = y0 - boxHeight;
		
		// Shadow
		[view SetBGToShadowColour];		
		[view FillRectangleX0:x0+5 Y0:y0+5 X1:x1+5 Y1:y1+5];

		// Box
		if(isFollowCar)
			[view SetBGColour:[view dark_magenta_]];
		else
			[view SetBGColour:fillColour];
		
		[view FillRectangleX0:x0 Y0:y0 X1:x1 Y1:y1];
		
		[view SetLineWidth:2];
		if(isFollowCar)
			[view SetFGColour:[view white_]];
		else
			[view SetFGColour:lineColour];
		
		[view LineRectangleX0:x0 Y0:y0 X1:x1 Y1:y1];
		
		if ( name != nil )
		{
			if(isFollowCar)
				[view SetFGColour:[view white_]];
			else
				[view SetFGColour:textColour];

			[view DrawString:name AtX:px + 7 Y:py - 20];
		}
	}
}

@end

@implementation TrackTurn

@synthesize distance;
@synthesize name;

- (id) init
{
	if(self = [super init])
	{
	}
	
	return self;
}

- (void) clear
{
	[name release];
}

- (void) dealloc
{
	[self clear];
	
	[super dealloc];
}

-(void) load:(DataStream *)stream
{
	distance = [stream PopFloat];
	name = [[stream PopString] retain];
}

@end

@implementation TrackProfile

@synthesize trackLength;
@synthesize s1Length;
@synthesize s2Length;
@synthesize sc1Length;
@synthesize sc2Length;

- (id) init
{
	if(self = [super init])
	{
		cars = [[NSMutableArray alloc] init];
		turns = [[NSMutableArray alloc] init];
		
		for ( int i = 0; i < 30; i++ )
		{
			TrackProfileCar *car = [[TrackProfileCar alloc]  init];
			[cars addObject:car];
			[car release];
		}
		
		carCount = 0;

		if ( blueBG == nil )
		{
			blueBG = [[UIColor alloc] initWithRed:(CGFloat)125/255.0 green:(CGFloat)125/255.0 blue:(CGFloat)200/255.0 alpha:1.0];
			blueMargin = [[UIColor alloc] initWithRed:(CGFloat)175/255.0 green:(CGFloat)175/255.0 blue:(CGFloat)250/255.0 alpha:1.0];
			blueSC = [[UIColor alloc] initWithRed:(CGFloat)165/255.0 green:(CGFloat)165/255.0 blue:(CGFloat)200/255.0 alpha:1.0];
			axisColor = [[UIColor alloc] initWithRed:(CGFloat)50/255.0 green:(CGFloat)50/255.0 blue:(CGFloat)50/255.0 alpha:1.0];
		}
	}
	
	return self;
}

- (void) dealloc
{
	[cars release];
	[turns release];

	int c;
	if ( colours )
	{
		for ( c = 0; c < coloursCount; c++ )
			[colours[c] release];
		free ( colours );
	}
	
	[super dealloc];
}

- (void) loadTrack : (DataStream *) stream
{
	trackLength = 0;
	s1Length = 0;
	s2Length = 0;
	sc1Length = 0;
	sc2Length = 0;
	pitStopLoss = 0;
	pitStopLossMargin = 0;
	pitStopLossSC = 0;

	[turns removeAllObjects];

	int c;
	if ( colours )
	{
		for ( c = 0; c < coloursCount; c++ )
			[colours[c] release];
		free ( colours );
	}
	
	coloursCount = [stream PopInt];
	colours = malloc ( sizeof (UIColor *) * coloursCount );
	
	for ( c = 0; c < coloursCount; c++ )
		colours[c] = NULL;
	
	for ( c = 0; c < coloursCount; c++ )
	{
		unsigned char index = [stream PopUnsignedChar];
		UIColor *colour = [[stream PopRGBA] retain];
		if ( index < coloursCount )
			colours[index] = colour;
		else
			[colour release];
	}
	
	trackLength = [stream PopFloat];
	s1Length = [stream PopFloat];
	s2Length = [stream PopFloat];
	sc1Length = [stream PopFloat];
	sc2Length = [stream PopFloat];
	pitStopLoss = [stream PopFloat];
	pitStopLossMargin = [stream PopFloat];
	pitStopLossSC = [stream PopFloat];
	
	int count = [stream PopInt];
	for ( int i = 0; i < count; i++ )
	{
		TrackTurn *turn = [[TrackTurn alloc] init];
		[turn load:stream];
		[turns addObject:turn];
		[turn release];
	}
}

- (void) updateCars : (DataStream *) stream
{
	carCount = 0;
	
	while (true)
	{
		int carNum = [stream PopInt];
		if ( carNum < 0 )
			break;
		
		[[cars objectAtIndex:carCount] load:stream Colours:colours ColoursCount:coloursCount];
		carCount++;
	}
}

-(void) drawTrackLine: (TrackProfileView *)view Distance:(float)distance Name:(NSString *)name Offset:(float)offset Y0:(int)y0 Y1:(int)y1
{
	CGSize size = [view bounds].size;
	
	float ox = (distance - offset);
	if ( ox < 0 )
		ox += 1;
	if ( ox > 1 )
		ox -= 1;
	float tx = [view transformX:ox];
	
	float px = tx * size.width;
	
	[view SetFGColour:[view dark_red_]];		
	[view LineX0:px Y0:y0 X1:px Y1:y1];
	[view SetFGColour:[view white_]];		
	[view DrawString:name AtX:px + 3 Y:y0];
}

-(void) drawTurn: (TrackProfileView *)view Distance:(float)distance Name:(NSString *)name Offset:(float)offset Y0:(int)y0 Y1:(int)y1
{
	CGSize size = [view bounds].size;
	
	float ox = (distance - offset);
	if ( ox < 0 )
		ox += 1;
	if ( ox > 1 )
		ox -= 1;
	float tx = [view transformX:ox];
	
	float px = tx * size.width;
	
	[view SetFGColour:[view cyan_]];		
	[view LineX0:px Y0:y0 X1:px Y1:y1];
	[view SetFGColour:[view cyan_]];		
	[view DrawString:name AtX:px + 3 Y:y0];
}

- (void) drawTrack : (TrackProfileView *) view Offset:(float)offset
{
	if ( kerbImage == nil )
	{
		grassImage = [[UIImage imageNamed:@"Grass.png"] retain];
		kerbImage = [[UIImage imageNamed:@"Kerbs.png"] retain];
		trackImage = [[UIImage imageNamed:@"Metal.png"] retain];
	}

	[view SaveGraphicsState];

	CGSize size = [view InqSize];
	
	float axisSpace = size.height > 250 ? 30 : 25;
	float graphicHeight = (size.height - axisSpace) / 2;
	int y_base = size.height - axisSpace;
	int x_axis = y_base;
	int y1 = y_base - graphicHeight;
	
	int x_pit_0 = [view transformX:(0.5-pitStopLoss)] * size.width;
	int x_pit_1 = [view transformX:pitStopLoss+0.5] * size.width;
	int x_margin_0 = [view transformX:(0.5-pitStopLossMargin)] * size.width;
	int x_margin_1 = [view transformX:pitStopLossMargin+0.5] * size.width;
	int x_sc_0 = [view transformX:(0.5-pitStopLossSC)] * size.width;
	int x_sc_1 = [view transformX:pitStopLossSC+0.5] * size.width;
	
	// Draw background and track
	[view FillPatternRectangle:grassImage X0:0 Y0:0 X1:size.width - 1 Y1:size.height - 1];
	
	// Draw track
	[view FillPatternRectangle:trackImage X0:0 Y0:y1 X1:size.width Y1:x_axis];
	
	UIColor * col = [blueBG colorWithAlphaComponent:0.4];
	[view SetBGColour: col];
	
	[view FillRectangleX0:x_pit_0 Y0:x_axis X1:x_pit_1 Y1:y1];
	
	col = [blueMargin colorWithAlphaComponent:0.4];
	[view SetBGColour: col];
	
	[view FillRectangleX0:x_margin_0 Y0:x_axis X1:x_pit_0 Y1:y1];
	[view FillRectangleX0:x_pit_1 Y0:x_axis X1:x_margin_1 Y1:y1];
	
	col = [blueSC colorWithAlphaComponent:0.4];
	[view SetBGColour: col];

	[view FillRectangleX0:x_sc_0 - 2 Y0:x_axis X1:x_sc_0 + 2 Y1:y1];
	[view FillRectangleX0:x_sc_1 - 2 Y0:x_axis X1:x_sc_1 + 2 Y1:y1];
	
	// Draw pit loss figure
	NSString * pLossString = [NSString stringWithFormat:@"%ds", (int)(roundf(pitStopLoss * trackLength))];
	float pw, ph;
	[view UseBigFont];
	[view GetStringBox:pLossString WidthReturn:&pw HeightReturn:&ph];
	[view SetFGColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.4]];
	[view DrawString:pLossString AtX:x_pit_0 - pw - 20 Y:y1 + 8];
	[view DrawString:pLossString AtX:x_pit_1 + 20 Y:y1 + 8];
	
	float yMid = y1 + 8 + ph / 2;
	[view LineX0:x_pit_0 - 20 Y0:yMid X1:x_pit_0 Y1:yMid];
	[view LineX0:x_pit_1 + 20 Y0:yMid X1:x_pit_1 Y1:yMid];
	
	// Draw kerbs
	[view FillPatternRectangle:kerbImage X0:0 Y0:x_axis-4 X1:size.width Y1:x_axis];
	[view FillPatternRectangle:kerbImage X0:0 Y0:y1 X1:size.width Y1:y1+4];
	
	// Draw Axes
	[view SetFGColour:[view white_]];
	[view SetBGColour:[view white_]];
	int cx = [view transformX:0.5] * size.width;
	
	// Draw centre line
	[view LineRectangleX0:cx Y0:x_axis + 20 X1:cx Y1:y1];
	
	// X Axis
	[view FillRectangleX0:0 Y0:x_axis X1:size.width Y1:x_axis+2];
		
	[view UseMediumBoldFont];
	[self drawTrackLine:view Distance:1 Name:@"Fin" Offset:offset Y0:x_axis Y1:y1];
	[self drawTrackLine:view Distance:s1Length Name:@"S1" Offset:offset Y0:x_axis Y1:y1];
	[self drawTrackLine:view Distance:s2Length Name:@"S2" Offset:offset Y0:x_axis Y1:y1];
	[self drawTrackLine:view Distance:sc1Length Name:@"SC1" Offset:offset Y0:x_axis Y1:y1];
	[self drawTrackLine:view Distance:sc2Length Name:@"SC2" Offset:offset Y0:x_axis Y1:y1];
	
	int turnCount = [turns count];
	for ( int i = 0; i < turnCount; i++ )
	{
		TrackTurn *turn = [turns objectAtIndex:i];
		[self drawTurn:view Distance:[turn distance] Name:[turn name] Offset:offset Y0:x_axis Y1:y1];
	}

	[view RestoreFont];
	
	[view RestoreGraphicsState];
}

- (void) drawInView:(TrackProfileView *)view
{	
	double offset = 0;
	
	RacePadDatabase *database = [RacePadDatabase Instance];
	ImageListStore * image_store = [database imageListStore];
	
	ImageList *image_list = image_store ? [image_store findList:@"MiniCars"] : nil;
	
	int i;
	for ( i = 0; i < carCount; i++ )
		if ( [[[cars objectAtIndex:i] name] isEqualToString:[view carToFollow]] )
		{
			offset = [[cars objectAtIndex:i] lapProgress] - 0.5;
			break;
		}

	[self drawTrack:view Offset:offset];
	
	[view UseRegularFont];
	
	for ( i = 0; i < carCount; i++ )
		[[cars objectAtIndex:i] draw:view OnMap:self Offset:offset ImageList:image_list];
	
	[view UseRegularFont];
	
}

@end

