//
//  TrackMap.m
//  RacePad
//
//  Created by Mark Riches on 12/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TrackMap.h"
#import "DataStream.h"
#import "FileDataStream.h"
#import "BufferedDataStream.h"
#import "TrackMapView.h"
#import "TrackProfileView.h"
#import "MathOdds.h"
#import "ElapsedTime.h"

// #import "ImageListStore.h"
#import "RacePadDatabase.h"

static UIColor *blueBG = nil;
static UIColor *blueMargin = nil;
static UIColor *blueSC = nil;
static UIColor *axisColor = nil;
static UIImage *kerbImage = nil;
static UIImage *trackImage = nil;
static UIImage *grassImage = nil;

@implementation TrackCar

@synthesize name;
@synthesize team;
@synthesize x;
@synthesize y;
@synthesize lapProgress;
@synthesize moving;
@synthesize pitted;
@synthesize stopped;
@synthesize number;
@synthesize lastUpdate;
@synthesize row;

- (id) init
{
    if(self = [super init])
    {
        pointColour = nil;
        fillColour = nil;
        lineColour = nil;
        textColour = nil;
	
        name = nil;
        team = nil;
	
        row = 0;
		number = -1;
	
        moving = false;
        pitted = false;
        stopped= false;
		
		lastUpdate = 0;
    }
	
	return self;
}

- (void) dealloc
{
	[pointColour release];
	[fillColour release];
	[lineColour release];
	[textColour release];
	[name release];
	[team release];
	
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
	[team release];
	
	pointColour = nil;
	fillColour = nil;
	lineColour = nil;
	textColour = nil;
	name = nil;
	team = nil;
	
	pointColour = [self loadColour:stream Colours:colours ColoursCount:coloursCount];
	x = [stream PopFloat];
	y = -[stream PopFloat];
	lapProgress = [stream PopFloat];
	dotSize = [stream PopInt];
	pitted = [stream PopBool];
	stopped = [stream PopBool];
	moving = [stream PopBool];
	
	if ( moving )
	{
		fillColour = [self loadColour:stream Colours:colours ColoursCount:coloursCount];
		lineColour = [self loadColour:stream Colours:colours ColoursCount:coloursCount];
		textColour = [self loadColour:stream Colours:colours ColoursCount:coloursCount];
		
		name = [[stream PopString] retain];
		team = [[stream PopString] retain];
	}
	
	lastUpdate = [ElapsedTime LocalTimeOfDay];
}

- (void) updateCar:(int)car X:(double)x_in Y:(double)y_in Progress:(double)progress_in Pit:(bool)pit Type:(int)type
{
	[pointColour release];
	[fillColour release];
	[lineColour release];
	[textColour release];
	[name release];
	[team release];
	
	pointColour = nil;
	fillColour = nil;
	lineColour = nil;
	textColour = nil;
	name = nil;
	team = nil;
	
	number = car;
	
	x = x_in;
	y = y_in;
	lapProgress = progress_in;
	dotSize = 3;
	pitted = pit;
	stopped = false;
	moving = true;
	
	if(type == 4)	// Safety car
	{
		pointColour = [[UIColor colorWithRed:0.1 green:1.0 blue:1.0 alpha:1.0] retain];
		fillColour = [[UIColor colorWithRed:0.1 green:1.0 blue:1.0 alpha:1.0] retain];
		lineColour = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] retain];
		textColour = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] retain];

		name = @"SC";
	}
	else if(type == 5)	// Medical car
	{
		pointColour = [[UIColor colorWithRed:0.1 green:1.0 blue:1.0 alpha:1.0] retain];
		fillColour = [[UIColor colorWithRed:0.1 green:1.0 blue:1.0 alpha:1.0] retain];
		lineColour = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] retain];
		textColour = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] retain];
		
		name = @"MC";
	}
	else if(pit)
	{
		pointColour = [[UIColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0] retain];
		fillColour = [[UIColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0] retain];
		lineColour = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] retain];
		textColour = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] retain];
		
		name = [[NSString stringWithFormat:@"%d", car] retain];
	}
	else if(type == 1)	// Leader
	{
		pointColour = [[UIColor colorWithRed:1.0 green:0.1 blue:0.8 alpha:1.0] retain];
		fillColour = [[UIColor colorWithRed:1.0 green:0.1 blue:0.8 alpha:1.0] retain];
		lineColour = [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] retain];
		textColour = [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] retain];
		
		name = [[NSString stringWithFormat:@"%d", car] retain];
	}
	else
	{
		pointColour = [[UIColor colorWithRed:0.1 green:0.6 blue:0.1 alpha:1.0] retain];
		fillColour = [[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] retain];
		lineColour = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] retain];
		textColour = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] retain];
		
		name = [[NSString stringWithFormat:@"%d", car] retain];
	}

	lastUpdate = [ElapsedTime LocalTimeOfDay];
}

- (void) draw:(TrackMapView *)view OnMap:(TrackMap *)trackMap Scale:(float)scale
{
	bool isFollowCar = ([[view carToFollow] isEqualToString:name]);
	
	CGSize size = [view bounds].size;
	
	float boxWidth = 48;
	float boxHeight = 22;
	
	if ( [view smallSized] )
	{
		boxWidth = 30;
		boxHeight = 15;
	}
	
	CGPoint p = CGPointMake(x, y);
	CGPoint tp = [view TransformPoint:p];
	
	float px = tp.x;
	float py = size.height - tp.y;
	
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
			
			if ( [view smallSized] )
				[view DrawString:name AtX:px + 6 Y:py - 13];
			else
				[view DrawString:name AtX:px + 7 Y:py - 20];
		}
	}
}

- (void) drawProfile:(TrackProfileView *)view Offset:(float) offset ImageList:(ImageList *)imageList
{
	bool isFollowCar = ([[view carToFollow] isEqualToString:name]);
	
	CGSize size = [view bounds].size;
	
	float boxWidth = 30;
	float boxHeight = 15;
	
	float ox = (lapProgress - offset);
	if ( ox < 0 )
		ox += 1;
	if ( ox > 1 )
		ox -= 1;
	
	float tx = [view transformX:ox];
	
	float px = tx * size.width;
	float py = size.height / 2 + 65 - row * 25;
	
	// Draw car
	float imageW = 0.0;
	float imageH = 0.0;
	if(imageList)
	{
		UIImage *image = [imageList findItem:team];
		
		CGSize imageSize = [image size];
		imageW = imageSize.width;
		imageH = imageSize.height;
		
		[view DrawImage:image AtX:px - imageW  Y:py - imageH];
	}
	
	if ( moving )
	{
		float x0 = px - imageW - 5;
		float y0 = py - 15;
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
			
			[view DrawString:name AtX:x0 + 1 Y:y1];
		}
	}
}

@end

@implementation TrackAccident

@synthesize carNumber;
@synthesize severity;
@synthesize sector;
@synthesize timeOfDay;

- (id) init
{
    if(self = [super init])
    {
		carNumber = 0;
		severity = 0;
		sector = 0;
		
		timeOfDay = 0;
    }
	
	return self;
}

@end


@implementation TrackShape

@synthesize width;
@synthesize height;
@synthesize min_x;
@synthesize max_x;
@synthesize min_y;
@synthesize max_y;
@synthesize path;
@synthesize segmentCount;
@synthesize segmentPaths;
@synthesize length;

- (id) init
{
	if(self = [super init])
	{
		path = nil;
		x = NULL;
		y = NULL;
		d = NULL;
		
		min_x = 0.0;
		max_x = 0.0;
		min_y = 0.0;
		max_y = 0.0;
		
		width = 0.0;
		height = 0.0;
	}
	
	return self;
}

- (void) clear
{
	CGPathRelease(path);
	path = NULL;
	if ( x )
		free(x);
	x = NULL;
	if ( y )
		free(y);
	y = NULL;
	if ( d )
		free(d);
	d = NULL;
	
	int i;
	if ( segmentPaths )
	{
		for ( i = 0; i < segmentCount; i++ )
			CGPathRelease(segmentPaths[i]);
		free (segmentPaths);
	}
	
	segmentCount = 0;
	segmentPaths = NULL;
	
}

- (void) dealloc
{
	[self clear];
	
	[super dealloc];
}

-(void) loadShape:(DataStream *)stream
{
	// Assume we've been cleared
	
	count = [stream PopInt];
	x = malloc(sizeof(float) * count);
	y = malloc(sizeof(float) * count);
	d = malloc(sizeof(float) * count);
	
	min_x = 1.0;
	max_x = 0.0;
	min_y = 1.0;
	max_y = 0.0;
	
	width = 0.0;
	height = 0.0;
	
	int i;
	for ( i = 0; i < count; i++ )
	{
		x[i] = [stream PopFloat];
		y[i] = -[stream PopFloat];
		
		if(x[i] > max_x)
			max_x = x[i];
		
		if(x[i] < min_x)
			min_x = x[i];
		
		if(-y[i] > max_y)
			max_y = -y[i];
		
		if(-y[i] < min_y)
			min_y = -y[i];
		
	}
	
	width = max_x - min_x;
	height = max_y - min_y;
	
	d[0] = 0.0;
	double last_d = 0.0;
	double last_x = x[0];
	double last_y = y[0];
	
	for ( i = 1; i < count; i++ )
	{
		double dd = sqrt(pow(x[i] - last_x, 2) + pow(y[i] - last_y, 2));
		d[i] = last_d + dd;
		last_d = d[i];
		last_x = x[i];
		last_y = y[i];
	}

	path = [DrawingView CreatePathPoints:count XCoords:x YCoords:y];
	
	segmentCount = [stream PopInt];
	
	if ( segmentCount )
	{
		int *segments = malloc ( segmentCount * sizeof ( int ) );
		for ( i = 0; i < segmentCount; i++ )
			segments[i] = [stream PopInt];
		
		segmentPaths = malloc ( sizeof (CGMutablePathRef) * segmentCount );
		for ( i = 0; i < segmentCount; i++ )
		{
			int p0 = segments[i];
			int p1;
			if ( i < segmentCount - 1 )
				p1 = segments[i+1];
			else
				p1 = segments[0];
			
			segmentPaths[i] = [DrawingView CreatePathPoints:p0 P1:p1 XCoords:x YCoords:y Count:count];
		}
		
		free ( segments );
	}
}

- (float) directionAtPoint: (float)xp Y:(float)yp
{
	float bestD2;
	bool gotD2 = false;
	int bestSeg;
	for ( int i = 1; i < count; i++ )
	{
		float tx = xp - x[i-1];
		float ty = yp - y[i-1];
		float dx = x[i] - x[i-1];
		float dy = y[i] - y[i-1];
		float l = (tx * dx + ty * dy) / (dx * dx + dy * dy);
		l = (l<0) ? 0 : ((l > 1) ? 1 : l);
		dx = tx - l * dx;
		dy = ty - l * dy;
		float d2 = dx * dx + dy * dy;
		if ( !gotD2 || d2 < bestD2 )
		{
			gotD2 = true;
			bestD2 = d2;
			bestSeg = i;
		}
	}
	
	if ( gotD2 )
	{
		return RadiansToDegrees ( atan2 (y[bestSeg] - y[bestSeg-1], x[bestSeg] - x[bestSeg-1] ) );
	}
	
	return 0;
}

- (void) scaleDistances : (double) track_length
{
	if(count > 0)
	{
		double old_distance = d[count - 1];
		if(old_distance > 0.0)
		{
			for ( int i = 0; i < count; i++ )
			{
				d[i] = d[i] * track_length / old_distance;
			}
		}
	}
}

- (void) getPointAtDistance : (double)distance X:(double *)xp Y:(double *)yp
{
	*xp = 0.0;
	*yp = 0.0;
	
	if(count <= 0)		
		return;
	
	if(distance < 0.0)
		distance += d[count - 1];
	
	int index = 0 ;
	
	if(distance <= d[0])
		index = 0 ;
	else if(distance > d[count - 1])
		index = count - 1 ;	
	else
	{
		// Do binary search		
		int bound1 = 0;		
		int bound2 = count - 1;
		
		do			
		{
			int check = (bound1 + bound2) / 2;
			
			if(distance > d[check])
				bound1 = check;			
			else if(distance < d[check])
				bound2 = check;
			else
				bound1 = bound2 = check;
		} while ((bound2 - bound1) > 1);
	
		index = bound1;		
	}
	
	*xp = x[index];
	*yp = y[index];
}
					 
@end

@implementation TrackLine

@synthesize path;
@synthesize colour;
@synthesize lineType;

- (id) init
{
	if(self = [super init])
	{
		path = nil;
		colour = nil;
		
		x = nil;
		y = nil;
		d = nil;
	}
	
	return self;
}

- (void) clear
{
	if(x)
		free(x);
	
	if(y)
		free(y);
	
	if(d)
		free(d);
	
	CGPathRelease(path);
	[colour release];
	path = NULL;
}

- (void) dealloc
{
	[self clear];
	
	[super dealloc];
}

-(void) loadShape:(DataStream *)stream Count:(int)pointCount
{
	count = pointCount;
	x = malloc(sizeof(float) * count);
	y = malloc(sizeof(float) * count);
	d = malloc(sizeof(float) * count);
	
	int i;
	for ( i = 0; i < count; i++ )
	{
		x[i] = [stream PopFloat];
		y[i] = -[stream PopFloat];
		d[i] = 0.0;
	}
	
	d[0] = 0.0;
	double last_d = 0.0;
	double last_x = x[0];
	double last_y = y[0];
	
	for ( i = 1; i < count; i++ )
	{
		double dd = sqrt(pow(x[i] - last_x, 2) + pow(y[i] - last_y, 2));
		d[i] = last_d + dd;
		last_d = d[i];
		last_x = x[i];
		last_y = y[i];
	}

	path = [DrawingView CreatePathPoints:count XCoords:x YCoords:y];
		
	colour = [[stream PopRGB]retain];
	lineType = [stream PopUnsignedChar];
}

- (void) getPointAtDistance : (double)distance X:(double *)xp Y:(double *)yp
{
	*xp = 0.0;
	*yp = 0.0;
	
	if(count <= 0)		
		return;
	
	if(distance < 0.0)
		distance += d[count - 1];
	
	int index = 0 ;
	
	if(distance <= d[0])
		index = 0 ;
	else if(distance > d[count - 1])
		index = count - 1 ;	
	else
	{
		// Do binary search		
		int bound1 = 0;		
		int bound2 = count - 1;
		
		do			
		{
			int check = (bound1 + bound2) / 2;
			
			if(distance > d[check])
				bound1 = check;			
			else if(distance < d[check])
				bound2 = check;
			else
				bound1 = bound2 = check;
		} while ((bound2 - bound1) > 1);
		
		index = bound1;		
	}
	
	*xp = x[index];
	*yp = y[index];
}

- (void) scaleDistances : (double) track_length
{
	if(count > 0)
	{
		double old_distance = d[count - 1];
		if(old_distance > 0.0)
		{
			for ( int i = 0; i < count; i++ )
			{
				d[i] = d[i] * track_length / old_distance;
			}
		}
	}
}

@end

@implementation TrackLabel

@synthesize path;
@synthesize colour;
@synthesize lineType;
@synthesize label;

- (id) init
{
	if(self = [super init])
	{
		path = nil;
		colour = nil;
	}
	
	return self;
}

- (void) clear
{
	CGPathRelease(path);
	[colour release];
	[label release];
	path = NULL;
}

- (void) dealloc
{
	[self clear];
	
	[super dealloc];
}

-(void) loadShape:(DataStream *)stream Count:(int)count
{
	assert ( count == 2 );
	
	float *x = malloc(sizeof(float) * count);
	float *y = malloc(sizeof(float) * count);
	
	int i;
	for ( i = 0; i < count; i++ )
	{
		x[i] = [stream PopFloat];
		y[i] = -[stream PopFloat];
	}
	
	path = [DrawingView CreatePathPoints:count XCoords:x YCoords:y];
	
	x0 = x[0];
	y0 = y[0];
	x1 = x[1];
	y1 = y[1];
	
	free ( x );
	free ( y );
	
	colour = [[stream PopRGB]retain];
	lineType = [stream PopUnsignedChar];
	label = [[stream PopString] retain];
}

-(void) getLabelPoint: (TrackMapView *)view Scale: (float) scale X:(float *)x Y:(float *)y;
{
	float w, h;
	[view GetStringBox:label WidthReturn: &w HeightReturn: &h];
	double a_rad = atan2 ( y0 - y1, x0 - x1 );
	double a = a_rad *  180 / M_PI;
	if ( a < 0 )
		a += 360;
	double x_off, y_off;
	double dsr2 = 1.0 / sqrt(2);
	if ( a < 45 || a > 315 )
	{
		x_off = 0;
		y_off = sin(a_rad) * h * dsr2 - h * 0.5;
	}
	else if ( a > 45 && a <= 135 )
	{
		x_off = cos(a_rad) * w * dsr2 - w * 0.5;
		y_off = 0;
	}
	else if ( a > 135 && a <= 255 )
	{
		x_off = -w;
		y_off = sin(a_rad) * h * dsr2 - h * 0.5;
	}
	else // ( a >= 135 && a < 315 )
	{
		x_off = cos (a_rad) * w * dsr2 - w * 0.5;
		y_off = -h;
	}
	*x = x0 + x_off / scale;
	*y = y0 + y_off / scale;
}

@end

@implementation SegmentState

@synthesize index;
@synthesize state;

- (id) init: (int) inIndex State: (unsigned char)inState
{
	if ( self = [super init] )
	{
		index = inIndex;
		state = inState;
	}
	
	return self;
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

@implementation TrackMap

@synthesize trackLength;
@synthesize s1Length;
@synthesize s2Length;
@synthesize sc1Length;
@synthesize sc2Length;

@synthesize trackProfileLength;
@synthesize s1ProfileLength;
@synthesize s2ProfileLength;
@synthesize sc1ProfileLength;
@synthesize sc2ProfileLength;

- (id) init
{
	if(self = [super init])
	{
		inner = [[TrackShape alloc] init];
		outer = [[TrackShape alloc] init];
		cars = [[NSMutableArray alloc] init];
		lines = [[NSMutableArray alloc] init];
		labels = [[NSMutableArray alloc] init];
		turns = [[NSMutableArray alloc] init];
		accidents = [[NSMutableArray alloc] init];
		
		for ( int i = 0; i < 100; i++ )
		{
			TrackCar *car = [[TrackCar alloc]  init];
			[cars addObject:car];
			[car release];
		}
		
		carCount = 0;
		
		for ( int i = 0 ; i < 32 ; i++ )
			frnLookup[i] = 0;
		
		segmentStates = [[NSMutableArray arrayWithCapacity:50] retain];
		
		xCentre = 0.0;
		yCentre = 0.0;
		
		width = 0.0;
		height = 0.0;
		
		if ( blueBG == nil )
		{
			blueBG = [[UIColor alloc] initWithRed:(CGFloat)125/255.0 green:(CGFloat)125/255.0 blue:(CGFloat)200/255.0 alpha:1.0];
			blueMargin = [[UIColor alloc] initWithRed:(CGFloat)175/255.0 green:(CGFloat)175/255.0 blue:(CGFloat)250/255.0 alpha:1.0];
			blueSC = [[UIColor alloc] initWithRed:(CGFloat)165/255.0 green:(CGFloat)165/255.0 blue:(CGFloat)200/255.0 alpha:1.0];
			axisColor = [[UIColor alloc] initWithRed:(CGFloat)50/255.0 green:(CGFloat)50/255.0 blue:(CGFloat)50/255.0 alpha:1.0];
		}
		
		logFile = nil;
	}
	
	return self;
}

- (void) dealloc
{
	[inner release];
	[outer release];
	[cars release];
	[lines release];
	[labels release];
	[segmentStates removeAllObjects];
	[segmentStates release];
	[accidents release];
	
	int c;
	if ( colours )
	{
		for ( c = 0; c < coloursCount; c++ )
			[colours[c] release];
		free ( colours );
	}
	
	[super dealloc];
}

- (TrackShape *)inner
{
	return inner;
}

- (TrackShape *)outer
{
	return outer;
}

- (void) loadTrackFromStream : (DataStream *) stream
{
	[inner clear];
	[outer clear];
	[lines removeAllObjects];
	[labels removeAllObjects];
	
	width = 0.0;
	height = 0.0;
	
	xCentre = 0.0;
	yCentre = 0.0;
	
	trackLength = 0;
	s1Length = 0;
	s2Length = 0;
	sc1Length = 0;
	sc2Length = 0;
	
	trackProfileLength = 0;
	s1ProfileLength = 0;
	s2ProfileLength = 0;
	sc1ProfileLength = 0;
	sc2ProfileLength = 0;
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
	
	int count = [stream PopInt];
	
	if ( count == 2 )
	{
		[inner loadShape:stream];
		[outer loadShape:stream];
		
		while ( true )
		{
			int count = [stream PopInt];
			if ( count < 0 )
				break;
			TrackLine *line = [[TrackLine alloc] init];
			[line loadShape:stream Count:count];
			[lines addObject:line];
			[line release];
			 
			TrackLine * last_line = [lines objectAtIndex:[lines count] - 1];
			if(last_line && [last_line lineType] == TM_L_RACING_LINE)
				racingLine = last_line;
		}
		
		while ( true )
		{
			int count = [stream PopInt];
			if ( count < 0 )
				break;
			TrackLabel *label = [[TrackLabel alloc] init];
			[label loadShape:stream Count:count];
			[labels addObject:label];
			[label release];
		}
		
		trackLength = [stream PopFloat];
		s1Length = [stream PopFloat];
		s2Length = [stream PopFloat];
		sc1Length = [stream PopFloat];
		sc2Length = [stream PopFloat];
		
		[inner scaleDistances:trackLength * 1000.0];
		[outer scaleDistances:trackLength * 1000.0];
		
		if(racingLine)
			[racingLine scaleDistances:trackLength * 1000.0];
		 		
		width = [inner width] > [outer width] ? [inner width] : [outer width];
		height = [inner height] > [outer height] ? [inner height] : [outer height];
		
		float min_x = [inner min_x] < [outer min_x] ? [inner min_x] : [outer min_x];
		float min_y = [inner min_y] < [outer min_y] ? [inner min_y] : [outer min_y];
		float max_x = [inner max_x] > [outer max_x] ? [inner max_x] : [outer max_x];
		float max_y = [inner max_y] > [outer max_y] ? [inner max_y] : [outer max_y];
		
		xCentre = (min_x + max_x) * 0.5;
		yCentre = (min_y + max_y) * 0.5;
		
		trackProfileLength = [stream PopFloat];
		s1ProfileLength = [stream PopFloat];
		s2ProfileLength = [stream PopFloat];
		sc1ProfileLength = [stream PopFloat];
		sc2ProfileLength = [stream PopFloat];
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
}

- (void) loadTrack : (DataStream *) stream
{
	if([stream isKindOfClass:[BufferedDataStream class]])
		[(BufferedDataStream *)stream SaveToFile:[self getTemporaryFile]];

	[self loadTrackFromStream:stream];	
}

- (void) loadTrackFromTemporaryFile
{
	FileDataStream * stream = [[FileDataStream alloc] initWithPath:[self getTemporaryFile]];
	
	if(stream)
		[self loadTrackFromStream:stream];
		
	[stream release];
}


- (NSString *) getDocumentFileName:(NSString *) name
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsFolder = [paths objectAtIndex:0];
	NSString *fileName = [docsFolder stringByAppendingPathComponent:name];
	return fileName;
}

- (NSString *) getTemporaryFile
{
	return [self getDocumentFileName:@"TempMapFile.tmp"];
}

- (void) updateSegmentStateFromEMM:(int)segment_index State:(int)state
{
	// Find or create segment
	SegmentState * segment = nil;
	if([segmentStates count] > 0)
	{
		for ( int i = 0 ; i < [segmentStates count] ; i++ )
		{
			if([[segmentStates objectAtIndex:i] index] == segment_index)
			{
				segment = [segmentStates objectAtIndex:i];
				break;
			}
		}
	}
	
	if(!segment)
	{
		SegmentState * segmentState = [[SegmentState alloc] init:segment_index State:state];
		[segmentStates addObject:segmentState];
		[segmentState release];
		segment = [segmentStates objectAtIndex:[segmentStates count] - 1];
	}
	
	if(segment)
	{
		switch (state)
		{
			case 0x00:
			case 0x06:
			default:
				[segment setState:TM_TRACK_GREEN];
				break;
				
			case 0x08:
				[segment setState:TM_TRACK_RED];
				break;

			case 0x0E:
				[segment setState:TM_TRACK_YELLOW];
				break;

			case 0x05:
				[segment setState:TM_TRACK_DOUBLE_YELLOW];
				break;

			case 0x0C:
				[segment setState:TM_TRACK_SEGMENT_SLIPPERY];
				break;

			case 0x01:
				[segment setState:TM_TRACK_SEGMENT_BLUE];
				break;

			case 0x0F:
				[segment setState:TM_TRACK_GREEN];
				break;

			case 0x10:
			case 0x15:
			case 0x1E:
			case 0x1F:
				[segment setState:TM_TRACK_SC];
				break;
				
			case 0x20:
			case 0x25:
			case 0x2E:
			case 0x2F:
				[segment setState:TM_TRACK_VSC];
				break;
		}
	}
}

- (void) updateAccidentFromEMM:(int)car_number Severity:(int)severity Sector:(int)sector
{
	double currentTime = [ElapsedTime LocalTimeOfDay];

	// Find or create accident record
	TrackAccident * accident = nil;
	if([accidents count] > 0)
	{
		for ( int i = 0 ; i < [accidents count] ; i++ )
		{
			if([[accidents objectAtIndex:i] carNumber] == car_number)
			{
				accident = [accidents objectAtIndex:i];
				break;
			}
		}
	}
	
	if(!accident)
	{
		TrackAccident * new_accident = [[TrackAccident alloc] init];
		[accidents addObject:new_accident];
		[new_accident release];
		accident = [accidents objectAtIndex:[accidents count] - 1];
		
		[accident setCarNumber:car_number];
		[accident setSeverity:severity];
		[accident setSector:sector];
		[accident setTimeOfDay:currentTime];
	}
	
	if(accident)
	{
		if(severity > [accident severity] || currentTime > [accident timeOfDay] + 60.0)
		{
			[accident setSeverity:severity];
			[accident setSector:sector];
			[accident setTimeOfDay:currentTime];
		}
	}
}

- (void) updateCars : (DataStream *) stream
{
	// Called from normal RacePadServer feed - delete any accidents left from track feed
	
	[accidents removeAllObjects];
	
	// Then clear an load cars and segment states
	
	carCount = 0;
	
	while (true)
	{
		int carNum = [stream PopInt];
		if ( carNum < 0 )
			break;
		
		[[cars objectAtIndex:carCount] load:stream Colours:colours ColoursCount:coloursCount];
		carCount++;
	}
	
	[segmentStates removeAllObjects];
	overallTrackState = TM_TRACK_GREEN;
	while (true)
	{
		int segNum = [stream PopInt];
		if ( segNum < 0 )
			break;
		
		unsigned char state = [stream PopUnsignedChar];
		if ( segNum > 1000 )
		{
			overallTrackState = state;
		}
		else
		{
			SegmentState * segmentState = [[SegmentState alloc] init:segNum State:state];
			[segmentStates addObject:segmentState];
			[segmentState release];
		}
	}
}

- (int) HexVal:( char ) c
{
    if(c >= '0' && c <= '9')
        return (int) (c - '0');
    else if(c >= 'a' && c <= 'f')
        return (int) (c - 'a' + 10);
    else if(c >= 'A' && c <= 'F')
        return (int) (c - 'A' + 10);
    else
        return 0;
}

- (int) HexVal: (char *)buffer Index:(int)index Length:(int)length
{
    int v = 0;
    for ( int i = 0; i < length; i++ )
        v = v * 16 + [self HexVal:buffer[index + i]];
    return v;
}

- (void) HandleEMMPacket:(char *) buffer
{
     /*
	 Let’s take this line
	 1  11  11  11  11  12
	 0   123 4   56  78  90  12  34  56  78  90
	 
	 t    6A3    8    0C    12    00    00    F7    15    60    04
	 t              delimiter
	 6A3            CAN ID
	 8            8 bytes
	 0C            car number = 12 NASR, car is on in the garage
	 12            1             Car in pit
	 2             car type: no-lapped car
	 0000        lap distance
	 F7          car number = 247 Medical car 2
	 15          1             car in pit
	 5             car type: Medical car
	 0460        lap distance, intel format, multiplied by 4; lap distance is hex2dec
	 (0460)/4 = 280.
	 */
			
	if ( strlen(buffer) == 21
		&& buffer[0] == 't'
		&& buffer[1] == '6'
		&& buffer[2] == 'A'
		&& buffer[4] == '8' )
    {
		
		double tod = [ElapsedTime LocalTimeOfDay];

		if(!logFile)
		{
			NSString * logPath = [NSString stringWithFormat:@"CanLog%d.txt", (int)tod];
			logFile = fopen ( [[self getDocumentFileName:logPath] UTF8String], "wb" );
		}
			
		if(logFile)
		{
			//NSString * todString = [NSString stringWithFormat:@"%d", (int)tod];
			//fwrite([todString , 1, strlen(buffer), logFile);
			fwrite(buffer, 1, strlen(buffer), logFile);
			
			putc('\n', logFile);
		}
		
		
        if ( buffer[3] == '2' )
        {
            // Sector Packet
			int sector_index = [self HexVal:buffer Index:9 Length:2];
			int sector_state = [self HexVal:buffer Index:11 Length:2];
			
			[self updateSegmentStateFromEMM:sector_index State:sector_state];
		}
		else if ( buffer[3] == 'C' )
        {
            // Accident Packet
			int ce_id = [self HexVal:buffer Index:13 Length:2];
			int car_number = [self HexVal:buffer Index:17 Length:2];
			int severity = [self HexVal:buffer Index:15 Length:2];
			int sector = [self HexVal:buffer Index:19 Length:2];
			
			if(car_number <= 0 && ce_id >= 0 && ce_id < 32)
				car_number = frnLookup[ce_id];
			
			if(car_number > 0 && severity > 0)
				[self updateAccidentFromEMM:car_number Severity:severity Sector:sector];
		}
        else if ( buffer[3] >= '3' && buffer[3] <= '6' )
        {
            // Car Packet
            for ( int c = 0; c < 2; c++ )
            {
                int car_offset = 5 + c * 8;
				
                int car = [self HexVal:buffer Index:car_offset Length:2];
                unsigned char pit = (unsigned char) [self HexVal:buffer Index:car_offset + 2 Length:1] & 0x1;
                unsigned char type = (unsigned char) [self HexVal:buffer Index:car_offset + 3 Length:1];
                unsigned char ce_id = ((unsigned char) [self HexVal:buffer Index:car_offset + 2 Length:1] & 0xE) / 2 + ([self HexVal:buffer Index:car_offset + 5 Length:1] & 0x3) * 8;
                int distance = ([self HexVal:buffer Index:car_offset + 6 Length:2] * 0x100 + [self HexVal:buffer Index:car_offset + 4 Length:2]) / 4;
				
				if(ce_id >= 0 && ce_id < 32)
					frnLookup[ce_id] = car;
				
				if(type > 0)
				{
					double x = 0.0;
					double y = 0.0;
					
					if(racingLine)
						[racingLine getPointAtDistance:distance X:&x Y:&y];
					else
						[inner getPointAtDistance:distance X:&x Y:&y];

					double progress = (trackLength > 0.0) ? distance / (trackLength * 1000.0) : 0.0;
					
					// Find or create car
					TrackCar * trackCar = nil;
					if(carCount > 0)
					{
						for ( int i = 0 ; i < carCount ; i++ )
						{
							if([[cars objectAtIndex:i] number] == car)
							{
								trackCar = [cars objectAtIndex:i];
								break;
							}
						}
					}
					
					if(!trackCar && carCount < 100)
					{
						trackCar = [cars objectAtIndex:carCount];
						carCount++;
					}
					
					if(trackCar)
						[trackCar updateCar:car X:x Y:y Progress:progress Pit:pit Type:type];
				}
            }
        }
    }
}

- (void) updateCarsFromEMMStream : (DataStream *) stream
{
	char packet[32];	
	int index = 0;
	
	while ( [stream canPop:1] )
	{
		char c = [stream PopUnsignedChar];
		if(index == 0)
		{
			if(c == 't')
			{
				packet[index] = c;
				index ++;
			}
		}
		else
		{
			if(c == '\r' || c == '\n')
			{
				packet[index] = 0;
				[self HandleEMMPacket:packet];
				
				index = 0;
			}
			else if(index < 31)
			{
				packet[index] = c;
				index ++;
			}
			else
			{
				index = 0;	// Give up and wait for next t
			}
		}
	}
/*
	carCount = 0;
	
	while (true)
	{
		int carNum = [stream PopInt];
		if ( carNum < 0 )
			break;
		
		[[cars objectAtIndex:carCount] load:stream Colours:colours ColoursCount:coloursCount];
		carCount++;
	}
	
	[segmentStates removeAllObjects];
	overallTrackState = TM_TRACK_GREEN;
	while (true)
	{
		int segNum = [stream PopInt];
		if ( segNum < 0 )
			break;
		
		unsigned char state = [stream PopUnsignedChar];
		if ( segNum > 1000 )
		{
			overallTrackState = state;
		}
		else
		{
			SegmentState * segmentState = [[SegmentState alloc] init:segNum State:state];
			[segmentStates addObject:segmentState];
			[segmentState release];
		}
	}
 */
}

- (void) drawTrack : (TrackMapView *) view Scale: (float) scale
{
	if ( [inner path]  && [outer path] )
	{
		// Draw track in transparent white and inner and outer track in 2 point white with drop shadow
		[view SaveGraphicsState];
		
		[view SetLineWidth:2 / scale];
		[view SetDropShadowXOffset:5.0 YOffset:5.0 Blur:0.0];
		
		[view SetBGColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3]];
		
		[view BeginPath];
		[view LoadPath:[inner path]];
		[view LoadPath:[outer path]];
		[view FillCurrentPath];
		
		[view SetFGColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
		
		[view BeginPath];
		[view LoadPath:[inner path]];
		[view LoadPath:[outer path]];
		[view LineCurrentPath];
		
		[view ResetDropShadow];
		
		int i;
		// Now draw the other lines (except the racing line)
		int count = [lines count];
		for ( i = 0; i < count; i++)
		{
			TrackLine *line = [lines objectAtIndex:i];
			if( [line lineType] != TM_L_RACING_LINE )
			{
				[view BeginPath];
				[view LoadPath:[line path]];
				if ( [line lineType] == TM_L_PIT_LINE )
					[view SetLineWidth:1 / scale];
				else
					[view SetLineWidth:2 / scale];
				[view SetFGColour:[line colour]];
				[view LineCurrentPath];
			}
		}
		
		// Now overlay any red/yellow segments
		count = [segmentStates count];
		for ( i = 0; i < count; i++)
		{
			if ( [(SegmentState *)[segmentStates objectAtIndex:i] state] != TM_TRACK_GREEN )
			{
				[view SetLineWidth:2 / scale];
				[view SetSolidLine];
				int index = [[segmentStates objectAtIndex:i] index];
				[view BeginPath];
				if ( index < [inner segmentCount] )
					[view LoadPath:[inner segmentPaths][index]];
				if ( index < [outer segmentCount] )
					[view LoadPath:[outer segmentPaths][index]];
				if ( [(SegmentState *)[segmentStates objectAtIndex:i] state] == TM_TRACK_YELLOW )
					[view SetFGColour:[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0]];
				else if ( [(SegmentState *)[segmentStates objectAtIndex:i] state] == TM_TRACK_SC )
					[view SetFGColour:[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0]];
				else if ( [(SegmentState *)[segmentStates objectAtIndex:i] state] == TM_TRACK_VSC )
					[view SetFGColour:[UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0]];
				else if ( [(SegmentState *)[segmentStates objectAtIndex:i] state] == TM_TRACK_SEGMENT_SLIPPERY )
				{
					[view SetFGColour:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]];
					[view LineCurrentPath];
					[view BeginPath];
					if ( index < [inner segmentCount] )
						[view LoadPath:[inner segmentPaths][index]];
					if ( index < [outer segmentCount] )
						[view LoadPath:[outer segmentPaths][index]];
					[view SetFGColour:[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0]];
					[view SetDashedLine:8.0/scale];
				}
				else if ( [(SegmentState *)[segmentStates objectAtIndex:i] state] == TM_TRACK_DOUBLE_YELLOW )
				{
					[view SetLineWidth:5 / scale];
					[view SetFGColour:[UIColor colorWithRed:0.8 green:80. blue:0.3 alpha:1.0]];
					[view LineCurrentPath];
					[view BeginPath];
					if ( index < [inner segmentCount] )
						[view LoadPath:[inner segmentPaths][index]];
					if ( index < [outer segmentCount] )
						[view LoadPath:[outer segmentPaths][index]];
					[view SetFGColour:[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0]];
					[view SetDashedLine:8.0/scale];
				}
				else
					[view SetFGColour:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]];
				[view LineCurrentPath];
			}
		}

		[view SetSolidLine];
		
		// Finally draw the label line
		[view SetLineWidth:1 / scale];
		count = [labels count];
		for ( i = 0; i < count; i++)
		{
			[view BeginPath];
			TrackLabel *label = [labels objectAtIndex:i];
			[view LoadPath:[label path]];
			[view SetFGColour:[label colour]];
			[view LineCurrentPath];
		}
		
		[view RestoreGraphicsState];
	}
}

- (void) drawTrackLabels : (TrackMapView *) view Scale:(float)scale
{
	// Now draw the labels themselves
	CGSize size = [view bounds].size;
	
	int count = [labels count];
	for ( int i = 0; i < count; i++)
	{
		TrackLabel *label = [labels objectAtIndex:i];
		
		/*
		 if ( [label lineType] == TM_L_TIMING_LINE )
		 [view UseBoldFont];
		 else
		 */
		if([view midasStyle])
		{
			if ( [view smallSized] )
				[view UseFont:DW_LIGHT_CONTROL_FONT_];
			else
				[view UseFont:DW_LIGHT_LARGER_CONTROL_FONT_];
		}
		else
		{
			if ( [view smallSized] )
				[view UseControlFont];
			else
				[view UseMediumBoldFont];
		}
		
		float x, y;
		[label getLabelPoint:view Scale:scale X:&x Y:&y];
		CGPoint p = CGPointMake(x, y);
		CGPoint tp = [view TransformPoint:p];
		
		float px = tp.x;
		float py = size.height - tp.y;
		
		[view SetFGColour:[label colour]];
		
		[view DrawString:[label label] AtX:px Y:py];
	}
}

- (void) drawCars : (TrackMapView *) view Scale:(float)scale
{
	if([view midasStyle])
	{
		if ( [view smallSized] )
			[view UseFont:DW_LIGHT_CONTROL_FONT_];
		else
			[view UseFont:DW_LIGHT_REGULAR_FONT_];
	}
	else
	{
		if ( [view smallSized] )
			[view UseControlFont];
		else
			[view UseRegularFont];
	}
	
	int i;

	double currentTime = [ElapsedTime LocalTimeOfDay];
	bool haveRecentUpdate = false;
	for ( i = 0; i < carCount; i++ )
	{
		if([[cars objectAtIndex:i] lastUpdate] > currentTime - 5.0)
		{
			haveRecentUpdate = true;
			break;
		}
	}
			
	for ( i = 0; i < carCount; i++ )
	{
		TrackCar *car = [cars objectAtIndex:i];
		if(!haveRecentUpdate || [car lastUpdate] > currentTime - 5.0)
		{
			bool isFollowCar = ([[view carToFollow] isEqualToString:[car name]]);
			if ( !isFollowCar )
				[car draw:view OnMap:self Scale:scale];
		}
	}
	for ( i = 0; i < carCount; i++ )
	{
		TrackCar *car = [cars objectAtIndex:i];
		if(!haveRecentUpdate || [car lastUpdate] > currentTime - 5.0)
		{
			bool isFollowCar = ([[view carToFollow] isEqualToString:[car name]]);
			if ( isFollowCar )
				[car draw:view OnMap:self Scale:scale];
		}
	}
}

- (void) drawInView:(TrackMapView *)view
{
	[view SaveGraphicsState];
	
	[self constructTransformMatrixForView:view];
	
	float scale = [view homeScale] * [view interpolatedUserScale]; // Usually just userScale unless animating
	[self drawTrack:view Scale:scale];
	
	[view RestoreGraphicsState];
	
	[self drawTrackLabels:view Scale:scale];
	[self drawCars:view Scale:scale];
	
	[view UseRegularFont];
	
	if ( [view isZoomView] )
	{
		NSString *followCar = [view carToFollow];
		if ( followCar != nil )
		{
			[view SetFGColour:[view white_]];
			
			[view DrawString:followCar AtX:3 Y:3];
			
			if ( ![self carExistsByName:followCar] )
			{
				[view UseBigFont];
				float tWidth, tHeight;
				CGSize size = [view InqSize];
				[view GetStringBox:@"In Pit" WidthReturn:&tWidth HeightReturn:&tHeight];
				[view DrawString:@"In Pit" AtX:(size.width - tWidth) / 2 Y:(size.height - tHeight)/2];
			}
		}
	}
	
	// Add accidents if in track feed mode
	if([accidents count] > 0)
	{
		double currentTime = [ElapsedTime LocalTimeOfDay];
		
		[view UseBigFont];
		[view SetFGColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
		
		CGSize size = [view InqSize];
		int textY = 10;
		for ( int i = 0 ; i < [accidents count] ; i++ )
		{
			if([[accidents objectAtIndex:i] timeOfDay] > currentTime - 600.0)
			{
				TrackAccident * accident = [accidents objectAtIndex:i];
				
				float tWidth, tHeight;
				NSString * accidentString = [NSString stringWithFormat:@"ACCIDENT : CAR %d SEVERITY %d IN SECTOR %d", [accident carNumber], [accident severity], [accident sector]];
				[view GetStringBox:accidentString WidthReturn:&tWidth HeightReturn:&tHeight];
				[view DrawString:accidentString AtX:(size.width - tWidth) - 10 Y:textY];
				
				textY += tHeight + 10;
			}
		}
		[view UseRegularFont];
	}
}

- (bool) carExistsByName:(NSString *)name
{
	for ( int i = 0; i < carCount; i++ )
	{
		if([[[cars objectAtIndex:i] name] isEqualToString:name])
			return true;
	}
	
	return false;
}

- (NSString *) nearestCarInView:(TrackMapView *)view ToX:(float)x Y:(float)y
{	
	int nearest_index = -1;
	float nearest_dist = 0.0;
	
	for ( int i = 0; i < carCount; i++ )
	{
		TrackCar * car = [cars objectAtIndex:i];
		float cx = [car x];
		float cy = [car y];
		CGPoint tp = [view TransformPoint:CGPointMake(cx, cy)];
		float tx = tp.x;
		float ty = tp.y;
		float dist = sqrt((x - tx) * (x - tx) + (y - ty) * (y - ty));
		if(nearest_index < 0 || dist < nearest_dist)
		{
			nearest_dist = dist;
			nearest_index = i;
		}
	}
	
	if(nearest_index >= 0)
	{
		return [[cars objectAtIndex:nearest_index] name];
	}
	else
	{
		return nil;
	}
}

- (void) constructTransformMatrixForView:(TrackMapView *)view
{
	NSString * carToFollow = [view isZoomView] ? [view carToFollow] : nil;
	
	if(carToFollow && [carToFollow length] > 0)
	{
		// Get dimensions of current view and the position of the follow car
		CGPoint followCarPos = [self getCarPositionByLabel:carToFollow];
		float rotation = 0;
		if ( view.autoRotate )
			rotation = -90 - [self directionAtPoint:followCarPos.x Y:followCarPos.y];
		
		// Adjust the parameters if we are animating from zoom to full view (o vice versa)
		if([view isAnimating])
		{
			float alpha = [view animationAlpha];
			float userScale = [view userScale];
			int direction = [view animationDirection];
			float s1, s2;
			
			float s = [view interpolatedUserScale];
			
			if(direction == 1)
			{
				s1 = userScale;
				s2 = [view animationScaleTarget];
			}
			else
			{
				s1 = [view animationScaleTarget];
				s2 = userScale;
				alpha = 1.0 - alpha;
			}
			
			// Calculate centre of transformation such that the car position varies linearly with
			// alpha from the centre to it's 1:1 track position.
			// Note : only works correctly with square maps
			
			float carX = followCarPos.x;
			float carY = followCarPos.y;
			float cX = xCentre;
			float cY = -yCentre;
			
			float dX = 2 * ( carX - cX) * s2;
			float dY = 2 * ( carY - cY) * s2;
			
			float x = carX - (dX * alpha) / (s * 2.0);
			float y = carY - (dY * alpha) / (s * 2.0);
			
			[self constructTransformMatrixForView:view WithCentreX:x Y:y Rotation:rotation];
		}
		else
		{
			[self constructTransformMatrixForView:view WithCentreX:followCarPos.x Y:followCarPos.y Rotation:rotation];
		}
	}
	else
	{
		[self constructTransformMatrixForView:view WithCentreX:xCentre Y:-yCentre Rotation:0];
	}
}

- (void) constructTransformMatrixForView:(TrackMapView *)view WithCentreX:(float)x Y:(float)y Rotation:(float) rotation
{
	// Constructs the transform matrix, stores it, and leaves it current
	
	// Get dimensions of current view
	CGRect map_rect = [view bounds];
	
	CGSize viewSize = map_rect.size;
	
	// Make the map as big as possible in the rectangle
	float x_scale = (width > 0.0) ? viewSize.width / width : viewSize.width;
	float y_scale = (height > 0.0) ? viewSize.height / height : viewSize.height;
	
	float mapScale = (x_scale < y_scale) ? x_scale : y_scale;
	
	float mapXOffset, mapYOffset;
	
	
	// If it is an overlay view, we move it to the right. Otherwise centre.
	if([view isOverlayView])
	{
		mapScale = mapScale * 0.7;
		mapXOffset = viewSize.width - width * 0.5 * mapScale - 55 ;
		mapYOffset = viewSize.height * 0.5 + yCentre  ;
	}
	else
	{
		mapScale = mapScale * 0.8;
		mapXOffset = viewSize.width * 0.5 - xCentre  ;
		mapYOffset = viewSize.height * 0.5 + yCentre ;
	}
	
	[view setHomeScale:mapScale];
	[view setHomeXOffset:mapXOffset];
	[view setHomeYOffset:mapYOffset];
	
	float userScale = [view interpolatedUserScale];
	float userXOffset = [view userXOffset];
	float userYOffset = [view userYOffset];
	
	//  And build the matrix
	[view ResetTransformMatrix];
	
	[view SetTranslateX:userXOffset * viewSize.width Y:userYOffset * viewSize.height];	
	[view SetTranslateX:mapXOffset Y:mapYOffset];
	[view SetScale:mapScale * userScale];
	[view SetRotationInDegrees:rotation];
	[view SetTranslateX:-x Y:-y];
	
	[view StoreTransformMatrix];	
}

- (void) adjustScaleInView:(TrackMapView *)view Scale:(float)scale X:(float)x Y:(float)y
{
	// If we're following a car, we just set the scale
	// Otherwise we zoom so that the focus point stays at the same screen location
	if([view isZoomView])
	{
		float currentUserScale = [view userScale];
		if(fabsf(currentUserScale) < 0.001 || fabsf(scale) < 0.001)
			return;
		
		[view setUserScale:currentUserScale * scale];
	}
	else
	{
		CGRect viewBounds = [view bounds];
		CGSize viewSize = viewBounds.size;
		
		if(viewSize.width < 1 || viewSize.height < 1)
			return;
		
		float currentUserPanX = [view userXOffset] * viewSize.width;
		float currentUserPanY = [view userYOffset] * viewSize.height;
		float currentUserScale = [view userScale];
		float currentMapPanX = [view homeXOffset];
		float currentMapPanY = [view homeYOffset];
		float currentMapScale = [view homeScale];
		float currentScale = currentUserScale * currentMapScale;
		
		if(fabsf(currentScale) < 0.001 || fabsf(scale) < 0.001)
			return;
		
		// Calculate where the centre point is in the untransformed map
		float x_in_map = (x - currentUserPanX - currentMapPanX) / currentScale; 
		float y_in_map = (y - currentUserPanY - currentMapPanY) / currentScale;
		
		// Now work out the new scale	
		float newScale = currentScale * scale;
		float newUserScale = currentUserScale * scale;
		
		// Now work out where that point in the map would go now
		float new_x = (x_in_map) * newScale + currentMapPanX;
		float new_y = (y_in_map) * newScale + currentMapPanY;
		
		// Andset the user pan to put it back where it was on the screen
		float newPanX = (x - new_x) / viewSize.width ;
		float newPanY = (y - new_y) / viewSize.height;
		
		[view setUserXOffset:newPanX];
		[view setUserYOffset:newPanY];
		[view setUserScale:newUserScale];
	}
	
}

- (void) adjustPanInView:(TrackMapView *)view X:(float)x Y:(float)y
{
	CGRect viewBounds = [view bounds];
	CGSize viewSize = viewBounds.size;
	
	if(viewSize.width < 1 || viewSize.height < 1)
		return;
	
	float newPanX = ([view userXOffset] * viewSize.width + x) / viewSize.width;
	float newPanY = ([view userYOffset] * viewSize.height + y)  / viewSize.height;
	
	[view setUserXOffset:newPanX];
	[view setUserYOffset:newPanY];
}

- (int) getTrackState
{	
	return overallTrackState;
}

- (CGPoint) getCarPositionByLabel: (NSString *) name
{
	for ( int i = 0; i < carCount; i++ )
	{
		if([[(TrackCar *)[cars objectAtIndex:i] name] isEqualToString:name])
			return CGPointMake([(TrackCar *)[cars objectAtIndex:i] x], [(TrackCar *)[cars objectAtIndex:i] y]);
	}
	
	return CGPointMake(0,0);
}

- (float) directionAtPoint:(float)xp Y:(float)yp
{
	return [inner directionAtPoint:xp Y:yp];
}

// TrackProfile

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
	
	float w, h;
	[view GetStringBox:name WidthReturn:&w HeightReturn:&h];
	
	[view SetFGColour:[view dark_red_]];		
	[view LineX0:px-1 Y0:y0 X1:px-1 Y1:y1];
	[view LineX0:px+1 Y0:y0 X1:px+1 Y1:y1];
	[view SetFGColour:[view white_]];		
	[view LineX0:px Y0:y0 X1:px Y1:y1];
	
	[view SetFGColour:[view white_]];		
	[view DrawString:name AtX:px - w * 0.5 Y:y1 - h - 1];
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
	
	NSString * turnName = @"T";
	turnName = [turnName stringByAppendingString:name];
	
	float w, h;
	[view GetStringBox:turnName WidthReturn:&w HeightReturn:&h];
	
	[view SetFGColour:[view light_grey_]];		
	[view LineX0:px Y0:y0 X1:px Y1:y1];
	[view SetFGColour:[UIColor colorWithRed:0.5 green:0.8 blue:0.8 alpha:1.0]];		
	[view DrawString:turnName AtX:px - w * 0.5 Y:y1 - h - 1];
}

- (void) drawTrackProfile : (TrackProfileView *)view Offset:(float)offset
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
	float graphicHeight = size.height - axisSpace * 2;
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
	NSString * pLossString = [NSString stringWithFormat:@"%ds", (int)(roundf(pitStopLoss * trackProfileLength))];
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
	[self drawTrackLine:view Distance:s1ProfileLength Name:@"S1" Offset:offset Y0:x_axis Y1:y1];
	[self drawTrackLine:view Distance:s2ProfileLength Name:@"S2" Offset:offset Y0:x_axis Y1:y1];
	
	int turnCount = [turns count];
	for ( int i = 0; i < turnCount; i++ )
	{
		TrackTurn *turn = [turns objectAtIndex:i];
		[self drawTurn:view Distance:[turn distance] Name:[turn name] Offset:offset Y0:x_axis Y1:y1];
	}
	
	[view RestoreFont];
	
	// Add tick marks at 1 sec intervals with labels every 5
	if(trackProfileLength > 0.0)
	{
		int counter = 0;
		float xMaxTime = 0.5 * trackProfileLength;
		
		[view SaveFont];
		[view UseMediumBoldFont];
		[view SetFGColour:[view white_]];
		for ( int xval = 0; xval < xMaxTime; xval += 1 )
		{
			double xRight = [view transformX:(0.5 + (float)xval / xMaxTime * 0.5)] * size.width;
			double xLeft = [view transformX:(0.5 - (float)xval / xMaxTime * 0.5)] * size.width;
			
			if ( counter == 0 )
			{
				[view LineRectangleX0:xRight Y0:x_axis X1:xRight Y1:x_axis + 5]; 
				[view LineRectangleX0:xLeft Y0:x_axis X1:xLeft Y1:x_axis + 5]; 
				
				counter = 4;
				
				if ( xval > 0 )
				{
					NSNumber *n = [NSNumber numberWithInt:-xval];
					NSString *s = [n stringValue];
					s = [s stringByAppendingString:@"s"];
					float w, h;
					[view GetStringBox:s WidthReturn:&w HeightReturn:&h];
					[view DrawString:s AtX:xRight - w / 2 Y:x_axis + 4];
					
					n = [NSNumber numberWithInt:xval];
					s = @"+";
					s = [s stringByAppendingString:[n stringValue]];
					s = [s stringByAppendingString:@"s"];
					[view GetStringBox:s WidthReturn:&w HeightReturn:&h];
					[view DrawString:s AtX:xLeft - w / 2 Y:x_axis + 4];
				}
			}
			else
			{
				[view LineRectangleX0:xRight Y0:x_axis X1:xRight Y1:x_axis + 2]; 
				[view LineRectangleX0:xLeft Y0:x_axis X1:xLeft Y1:x_axis + 2];
				
				counter --;
			}
		}
	}
	
	[view RestoreFont];
	
	[view RestoreGraphicsState];
}

- (void) drawInProfileView:(TrackProfileView *)view
{	
	RacePadDatabase *database = [RacePadDatabase Instance];
	ImageListStore * image_store = [database imageListStore];
	
	ImageList *image_list = image_store ? [image_store findList:@"MiniCars"] : nil;
	
	// Find the follow car and offset map to him (will stay at S/F if he's not found)
	double offset = -0.5;
	for ( int i = 0; i < carCount; i++ )
	{
		if ( [[[cars objectAtIndex:i] name] isEqualToString:[view carToFollow]] )
		{
			offset = [[cars objectAtIndex:i] lapProgress] - 0.5;
			break;
		}
	}
	
	[self drawTrackProfile:view Offset:offset];
	
	if(carCount > 0)
	{
		// Find the biggest gap between cars
		double biggestGap = -999.0;
		int biggestGapCar = -1;
		for ( int i = 0; i < carCount; i++ )
		{
			int j = i < (carCount - 1) ? i + 1 : 0;
			double lapProgress_i = [[cars objectAtIndex:i] lapProgress];
			double lapProgress_j = [[cars objectAtIndex:j] lapProgress];
			
			if(lapProgress_j < lapProgress_i)
				lapProgress_j += 1;
			
			double gap = lapProgress_j - lapProgress_i;
			
			if(gap > biggestGap)
			{
				biggestGap = gap;
				biggestGapCar = i;	// Car with biggest gap ahead
			}
		}
		
		if(biggestGapCar >= 0)
		{
			// Now set rows, going backwards from biggestGapCar
			[[cars objectAtIndex:biggestGapCar] setRow:0];
			
			int lastRow = 0;
			
			int carAhead = biggestGapCar;
			double lapProgress_1 = [[cars objectAtIndex:carAhead] lapProgress] * trackProfileLength;
			
			while(true)
			{				
				int carBehind = carAhead > 0 ? carAhead - 1 : (carCount - 1);
				
				while(carBehind != biggestGapCar &&
					  (![[cars objectAtIndex:carBehind] moving] ||
					   [[cars objectAtIndex:carBehind] stopped] ||
					   [[cars objectAtIndex:carBehind] pitted]))
				{
					[[cars objectAtIndex:carBehind] setRow:0];
					carBehind = carBehind > 0 ? carBehind - 1 : (carCount - 1);
				}
				
				if(carBehind == biggestGapCar)
					break;
				
				double lapProgress_2 = [[cars objectAtIndex:carBehind] lapProgress] * trackProfileLength;
				
				if(lapProgress_2 > lapProgress_1)
					lapProgress_1 += trackProfileLength;
				
				double gap = lapProgress_1 - lapProgress_2;
				
				int row = (gap > 3.0) ? 0 : lastRow + 1;
				
				if(row > 4)
					row = 0;
				
				[[cars objectAtIndex:carBehind] setRow:row];
				
				carAhead = carBehind;
				lapProgress_1 = lapProgress_2;
				lastRow = row;
			}
			
			// Finally draw cars
			[view UseControlFont];
			
			// Stopped cars first
			for ( int i = 0; i < carCount; i++ )
			{
				if(![[cars objectAtIndex:i] moving])
					[[cars objectAtIndex:i] drawProfile:view Offset:offset ImageList:image_list];
			}
			
			// Then moving ones
			for ( int i = 0; i < carCount; i++ )
			{
				if([[cars objectAtIndex:i] moving])
					[[cars objectAtIndex:i] drawProfile:view Offset:offset ImageList:image_list];
			}
			
			[view UseRegularFont];
		}
	}
	
}

////////////////////////////////////////////////////////////////////////
//


@end

