//
//  TrackMap.m
//  RacePad
//
//  Created by Mark Riches on 12/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PitWindow.h"
#import "DataStream.h"
#import "PitWindowView.h"

@implementation PitWindowCar

static UIColor *redTrail = nil;
static UIColor *greenTrail = nil;
static UIColor *redBG = nil;
static UIColor *blueBG = nil;
static UIColor *redMargin = nil;
static UIColor *blueMargin = nil;
static UIColor *redSC = nil;
static UIColor *blueSC = nil;
static UIColor *axisColor = nil;
static UIImage *blueFlagImage = nil;
static UIImage *arrowLeaderImage = nil;
static UIImage *kerbImage = nil;
static UIImage *trackImage = nil;

- (id) init
{
	fillColour = nil;
	lineColour = nil;
	textColour = nil;
	
	name = nil;
	
	return [super init];
}

- (void) dealloc
{
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
	[fillColour release];
	[lineColour release];
	[textColour release];
	[name release];

	fillColour = nil;
	lineColour = nil;
	textColour = nil;
	name = nil;


	name = [[stream PopString] retain];
	x = [stream PopFloat];
	
	fillColour = [self loadColour:stream Colours:colours ColoursCount:coloursCount];
	lineColour = [self loadColour:stream Colours:colours ColoursCount:coloursCount];
	textColour = [self loadColour:stream Colours:colours ColoursCount:coloursCount];
	
	inPit = [stream PopBool];
	gapNext = [stream PopFloat];
	gapThis = [stream PopFloat];
	lapped = [stream PopBool];
	lapping = [stream PopBool];
}

- (void) preDraw:(PitWindowView *)view Height:(float)graphicHeight Y:(int)y LastX:(int *) lastX LastY:(int *)lastY
{
	CGSize size = [view InqSize];
	int box_width = 40;
	int box_height = 18;
	px = x * size.width - box_width / 2;
	py = y;
	
	if ( px > *lastX - box_width )
	{
		py = *lastY - box_height - 4;
		if ( py - box_height < (y - graphicHeight + 40) )
			py = y - box_height;
	}
	else
		py = y - box_height;
	
	*lastX = px;
	*lastY = py;
}

- (void) draw:(PitWindowView *)view Y:(int)y XMaxTime:(int) xMaxTime
{
	CGSize size = [view InqSize];
	int box_width = 40;
	int box_height = 18;
	
	
	// Draw box background
	[view SetBGColour:fillColour];
	[view FillRectangleX0:px Y0:py X1:px + box_width Y1:py - box_height];
	
	int gt = ((xMaxTime-gapThis) / (xMaxTime * 2)) * size.width;
	
	// Draw next lap gap indicator
	if ( !inPit )
	{
		if ( redTrail == nil )
		{
			redTrail = [[UIColor alloc ]initWithRed:0.7f green:0 blue:0 alpha:1];
			greenTrail = [[UIColor alloc]initWithRed:0 green:0.7f blue:0 alpha:1];
		}
		if ( abs(gapNext - gapThis) < 10 )
		{
			[view SetLineWidth:3];
			int gn = ((xMaxTime-gapNext) / (xMaxTime * 2)) * size.width;
			if ( gapNext > gapThis )
				[view SetFGColour:redTrail];
			else
				[view SetFGColour:greenTrail];
			[view LineX0:gt Y0:py - box_height - 2  X1:gn Y1:py - box_height - 2];
		}
	}
	[view SetLineWidth:1];
	
	// Draw outline and line to axis
	[view SetFGColour:lineColour];
	[view LineRectangleX0:px Y0:py X1:px + box_width Y1:py - box_height];
	[view LineX0:gt Y0:py X1:gt Y1:y];
	[view FillRectangleX0:gt - 3 Y0:y - 3 X1:gt + 3 Y1:y + 3];
	
	// Driver name
	[view SetFGColour:textColour];
	[view DrawString:name AtX:px + 1 Y:py - box_height - 1];
	
	if ( blueFlagImage == nil )
	{
		blueFlagImage = [[UIImage imageNamed:@"BlueFlag.png"] retain];
		arrowLeaderImage = [[UIImage imageNamed:@"ArrowLeader.png"] retain];
	}
	
	if ( lapped )
	{
		CGSize size = [blueFlagImage size];
		[view DrawImage:blueFlagImage AtX:px + box_width - 5 Y:py - box_height - size.height + 5];
	}
	else if ( lapping )
	{
		CGSize size = [arrowLeaderImage size];
		[view DrawImage:arrowLeaderImage AtX:px + box_width - 5 Y:py - box_height - size.height + 5];
	}
	
}

@end

@implementation PitWindow

- (id) init
{
	if(self = [super init])
	{
		redCars = [[NSMutableArray alloc] init];
		blueCars = [[NSMutableArray alloc] init];
		
		for ( int i = 0; i < 30; i++ )
		{
			PitWindowCar *redCar = [[PitWindowCar alloc]  init];
			[redCars addObject:redCar];
			PitWindowCar *blueCar = [[PitWindowCar alloc]  init];
			[blueCars addObject:blueCar];
		}
		
		redCarCount = 0;
		blueCarCount = 0;
		
		if ( blueBG == nil )
		{
			blueBG = [[UIColor alloc] initWithRed:(CGFloat)125/255.0 green:(CGFloat)125/255.0 blue:(CGFloat)200/255.0 alpha:1.0];
			redBG = [[UIColor alloc] initWithRed:(CGFloat)200/255.0 green:(CGFloat)125/255.0 blue:(CGFloat)125/255.0 alpha:1.0];
			blueMargin = [[UIColor alloc] initWithRed:(CGFloat)175/255.0 green:(CGFloat)175/255.0 blue:(CGFloat)250/255.0 alpha:1.0];
			redMargin = [[UIColor alloc] initWithRed:(CGFloat)250/255.0 green:(CGFloat)175/255.0 blue:(CGFloat)175/255.0 alpha:1.0];
			blueSC = [[UIColor alloc] initWithRed:(CGFloat)165/255.0 green:(CGFloat)165/255.0 blue:(CGFloat)200/255.0 alpha:1.0];
			redSC = [[UIColor alloc] initWithRed:(CGFloat)217/255.0 green:(CGFloat)165/255.0 blue:(CGFloat)125/255.0 alpha:1.0];
			axisColor = [[UIColor alloc] initWithRed:(CGFloat)50/255.0 green:(CGFloat)50/255.0 blue:(CGFloat)50/255.0 alpha:1.0];
		}
	}
	
	return self;
}

- (void) dealloc
{
	[redCars release];
	[blueCars release];

	int c;
	if ( colours )
	{
		for ( c = 0; c < coloursCount; c++ )
			[colours[c] release];
		free ( colours );
	}
	
	[super dealloc];
}

- (void) loadBase: (DataStream *) stream
{
	xMaxTime = [stream PopFloat];
	pitStopLoss = [stream PopFloat];
	pitStopLossMargin = [stream PopFloat];
	pitStopLossSC = [stream PopFloat];

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
		UIColor *colour = [[stream PopRGB] retain];
		if ( index < coloursCount )
			colours[index] = colour;
		else
			[colour release];
	}
}

- (void) load : (DataStream *) stream
{
	redCarCount = 0;
	
	while (true)
	{
		int carNum = [stream PopInt];
		if ( carNum < 0 )
			break;
		
		[[redCars objectAtIndex:redCarCount] load:stream Colours:colours ColoursCount:coloursCount];
		redCarCount++;
	}
	
	
	blueCarCount = 0;
	
	while (true)
	{
		int carNum = [stream PopInt];
		if ( carNum < 0 )
			break;
		
		[[blueCars objectAtIndex:blueCarCount] load:stream Colours:colours ColoursCount:coloursCount];
		blueCarCount++;
	}
}

- (void) drawGraphic: (bool)blueCar Y:(int)y_base Height:(float)graphicHeight View:(PitWindowView *)view
{
	CGSize size = [view InqSize];
	xRange = size.width;
	NSMutableArray *cars;
	int count;
	
	int x_axis = y_base - 30;
	int y1 = y_base - graphicHeight;
	
	int x_pit_0 = (1-pitStopLoss) * size.width;
	int x_pit_1 = pitStopLoss * size.width;
	int x_margin_0 = (1-pitStopLossMargin) * size.width;
	int x_margin_1 = pitStopLossMargin * size.width;
	int x_sc_0 = (1-pitStopLossSC) * size.width;
	int x_sc_1 = pitStopLossSC * size.width;
	
	// Draw track
	[view FillPatternRectangle:trackImage X0:0 Y0:y1 X1:size.width Y1:x_axis];
	
	// Draw pit windows
	if ( blueCar )
	{
		cars = blueCars;
		count = blueCarCount;
		UIColor * col = [blueBG colorWithAlphaComponent:0.4];
		[view SetBGColour: col];
	}
	else
	{
		cars = redCars;
		count = redCarCount;
		UIColor * col = [redBG colorWithAlphaComponent:0.4];
		[view SetBGColour: col];
	}
		
	[view FillRectangleX0:x_pit_0 Y0:x_axis X1:x_pit_1 Y1:y1];
	
	if ( blueCar )
	{
		UIColor * col = [blueMargin colorWithAlphaComponent:0.4];
		[view SetBGColour: col];
	}
	else
	{
		UIColor * col = [redMargin colorWithAlphaComponent:0.4];
		[view SetBGColour: col];
	}

	[view FillRectangleX0:x_margin_0 Y0:x_axis X1:x_pit_0 Y1:y1];
	[view FillRectangleX0:x_pit_1 Y0:x_axis X1:x_margin_1 Y1:y1];
	
	if ( blueCar )
	{
		UIColor * col = [blueSC colorWithAlphaComponent:0.4];
		[view SetBGColour: col];
	}
	else
	{
		UIColor * col = [redSC colorWithAlphaComponent:0.4];
		[view SetBGColour: col];
	}
	
	[view FillRectangleX0:x_sc_0 - 2 Y0:x_axis X1:x_sc_0 + 2 Y1:y1];
	[view FillRectangleX0:x_sc_1 - 2 Y0:x_axis X1:x_sc_1 + 2 Y1:y1];
	
	// Draw kerbs
	[view FillPatternRectangle:kerbImage X0:0 Y0:x_axis-4 X1:size.width Y1:x_axis];
	[view FillPatternRectangle:kerbImage X0:0 Y0:y1 X1:size.width Y1:y1+4];
	
	// Draw Axes
	[view SetFGColour:[view white_]];
	[view SetBGColour:[view white_]];
	int cx = size.width / 2;
	
	// Draw centre line
	[view LineRectangleX0:cx Y0:y_base - 10 X1:cx Y1:y1];
	
	// X Axis
	[view FillRectangleX0:0 Y0:x_axis X1:size.width Y1:x_axis+2];
	
	// Add tick marks at 5 sec intervals
	int counter = 0;
	[view SaveFont];
	[view UseMediumBoldFont];
	for ( int xval = 0; xval < xMaxTime; xval += 1 )
	{
		double xRight = ((float)xval / xMaxTime) * (size.width / 2) + (size.width / 2);
		double xLeft = (size.width / 2) - (((float)xval / xMaxTime) * (size.width / 2));
		
		if ( counter == 0 )
		{
			[view LineRectangleX0:xRight Y0:x_axis X1:xRight Y1:x_axis + 5]; 
			[view LineRectangleX0:xLeft Y0:x_axis X1:xLeft Y1:x_axis + 5]; 
			
			counter = 4;
			
			if ( xval > 0 )
			{
				NSNumber *n = [NSNumber numberWithInt:-xval];
				NSString *s = [n stringValue];
				float w, h;
				[view GetStringBox:s WidthReturn:&w HeightReturn:&h];
				[view DrawString:s AtX:xRight - w / 2 Y:x_axis + 4];
				
				n = [NSNumber numberWithInt:xval];
				s = @"+";
				s = [s stringByAppendingString:[n stringValue]];
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

	[view RestoreFont];

	int lastX = 9999;
	int lastY = y_base - 20;
	int i;
	for ( i = count - 1; i >= 0; i-- )
		[[cars objectAtIndex:i] preDraw: view Height:graphicHeight Y:x_axis LastX:&lastX LastY:&lastY];
	for ( i = 0; i < count; i++ )
		[[cars objectAtIndex:i] draw: view Y:x_axis XMaxTime:xMaxTime];
}

- (void) draw : (PitWindowView *) view
{
	CGSize size = [view InqSize];
	
	if ( kerbImage == nil )
	{
		kerbImage = [[UIImage imageNamed:@"Kerbs.png"] retain];
		trackImage = [[UIImage imageNamed:@"Metal.png"] retain];
	}
	
	float graphicHeight = (size.height - 40) / 2 - 10;
	
	if(graphicHeight > 200)
		graphicHeight = 200;
	
	[self drawGraphic:false Y:(size.height/2 - (size.height/2 - graphicHeight) / 2) Height:graphicHeight View:view];
	[self drawGraphic:true Y:(size.height - (size.height/2 - graphicHeight) / 2) Height:graphicHeight View:view];
}

@end

