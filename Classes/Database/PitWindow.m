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
#import "RacePadDatabase.h"
// #import "ImageListStore.h"

#import "UIConstants.h"

@implementation PitWindowCar

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
static UIImage *grassImage = nil;

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

- (void) preDrawInView:(PitWindowView *)view Simplified:(bool)simplified Height:(float)graphicHeight Y:(int)y LastX:(int *)lastX LastRow:(int *)lastRow
{
	CGSize size = [view InqSize];
	
	shouldDraw = true;
	
	int box_width = 40;
	int box_height = 18;
	
	int car_width = 50;
	int car_height = 12;
	
	int car_base = y - car_height - 16;
	
	if(simplified)
		car_base += 6;
	
	int box_base = y - graphicHeight - 12;
		
	row = *lastRow;
	
	px = [view transformX:x] * size.width - box_width / 2;
	py = box_base;
	
	cx = [view transformX:x] * size.width;
	cy = car_base;
	
	// The positioning of cars is different depending on whether we're in simplified mode
	if(simplified)
	{
        if(fabs(x - 0.5) < 0.0001) // The reference car - FIXME - should have exlicit ID of reference
		{
			row = 0;
			shouldDraw = true;
		}
		else if (lapped || lapping)
		{
			row = 4;
			shouldDraw = false;
		}
		else if ( cx > *lastX - car_width )
		{
			row++;
			if ( row >= 4 )
				row = 1;
			
			shouldDraw = false;
		}
		else
		{
			row = 1;
			shouldDraw = true;
		}
	}
	else
	{
		if ( cx > *lastX - car_width )
		{
			row++;
			if ( row >= 3 )
				row = 0;
		}
		else
		{
			row = 0;
		}
	}
	
	cy = car_base - (car_height + 2) * row;
	py = box_base - (box_height + 4) * row;
		
	if(!(simplified && (lapped || lapping)))
	{
		*lastX = cx;
		*lastRow = row;
	}
}

- (void) drawInView:(PitWindowView *)view Simplified:(bool)simplified Y:(int)y XMaxTime:(int) xMaxTime ImageList:(ImageList *)imageList
{
	CGSize size = [view InqSize];
	int box_width = 40;
	int box_height = 18;
	
	//Make sure we've got the images
	if ( blueFlagImage == nil )
	{
		blueFlagImage = [[UIImage imageNamed:@"BlueFlag.png"] retain];
		arrowLeaderImage = [[UIImage imageNamed:@"ArrowLeader.png"] retain];
	}
	
	// Draw box label if shouldDraw is on
	if(shouldDraw)
	{
		// First, the background
		// Shadow
		[view SetBGToShadowColour];		
		[view FillRectangleX0:px + 3 Y0:py + 3 X1:px + box_width + 3 Y1:py - box_height + 3];
		[view SetBGColour:fillColour];
		[view FillRectangleX0:px Y0:py X1:px + box_width Y1:py - box_height];
	
		int gt = [view transformX:((xMaxTime-gapThis) / (xMaxTime * 2))] * size.width;
	
		// Draw next lap gap indicator
		// Don't do this for the moment - too confusing
		/*
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
				int gn = [view transformX:((xMaxTime-gapNext) / (xMaxTime * 2))] * size.width;
				
				if ( gapNext > gapThis )
					[view SetFGColour:redTrail];
				else
					[view SetFGColour:greenTrail];
				
				[view LineX0:gt Y0:py - box_height - 2  X1:gn Y1:py - box_height - 2];
			}
		}
		*/
	
		[view SetLineWidth:1];
		
		// Draw outline and line to axis
		[view SetFGColour:lineColour];
		[view LineRectangleX0:px Y0:py X1:px + box_width Y1:py - box_height];
		[view LineX0:gt Y0:cy+8 X1:gt Y1:y];
		
		if(fabs(x - 0.5) > 0.001)
			[view SetFGColour:[lineColour colorWithAlphaComponent:0.2]];
		
		[view LineX0:gt Y0:py X1:gt Y1:cy+8];	
		
		[view SetBGColour:lineColour];
		[view FillRectangleX0:gt - 3 Y0:y - 3 X1:gt + 3 Y1:y + 3];
		
		// Driver name
		[view SetFGColour:textColour];
		[view DrawString:name AtX:px + 1 Y:py - box_height - 1];
	
	}
	
	// Draw flags and arrows
	if ( lapped )
	{
		CGSize size = [blueFlagImage size];
		
		if(shouldDraw)
		{
			[view DrawImage:blueFlagImage AtX:px + box_width - 5 Y:py - box_height - size.height + 5];
			[view DrawImage:blueFlagImage AtX:cx Y:cy - 8];
		}
		else
		{
			[view DrawImage:blueFlagImage AtX:cx Y:cy - 8 WithAlpha:0.5];
		}
	}
	else if ( lapping )
	{
		CGSize size = [arrowLeaderImage size];
		if(shouldDraw)
		{
			[view DrawImage:arrowLeaderImage AtX:px + box_width - 5 Y:py - box_height - size.height + 5];
			[view DrawImage:arrowLeaderImage AtX:cx Y:cy - 8];
		}
		else
		{
			[view DrawImage:arrowLeaderImage AtX:cx Y:cy - 8 WithAlpha:0.5];
		}
	}

	// Draw car
	if(imageList)
	{
		UIImage *image = [imageList findItem:name];
		if(simplified && (lapped || lapping))
			[view DrawImage:image AtX:cx - 25 Y:cy WithAlpha:0.5];
		else
			[view DrawImage:image AtX:cx - 25 Y:cy];
	}
	
}

@end

@implementation PitWindow

@synthesize simplified;

- (id) init
{
	if(self = [super init])
	{
		simplified = true;
		
		redCars = [[NSMutableArray alloc] init];
		blueCars = [[NSMutableArray alloc] init];
		
		for ( int i = 0; i < 30; i++ )
		{
			PitWindowCar *redCar = [[PitWindowCar alloc]  init];
			[redCars addObject:redCar];
			[redCar release];
			
			PitWindowCar *blueCar = [[PitWindowCar alloc]  init];
			[blueCars addObject:blueCar];
			[blueCar release];
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

- (void) drawGraphicInView:(PitWindowView *)view IsBlueCar:(bool)blueCar Y:(int)y_base Height:(float)graphicHeight
{
	CGSize size = [view InqSize];
	xRange = size.width;
	NSMutableArray *cars;
	int count;
	
	int x_axis = y_base;
	int y1 = y_base - graphicHeight;
	
	int x_pit_0 = [view transformX:(1-pitStopLoss)] * size.width;
	int x_pit_1 = [view transformX:pitStopLoss] * size.width;
	int x_margin_0 = [view transformX:(1-pitStopLossMargin)] * size.width;
	int x_margin_1 = [view transformX:pitStopLossMargin] * size.width;
	int x_sc_0 = [view transformX:(1-pitStopLossSC)] * size.width;
	int x_sc_1 = [view transformX:pitStopLossSC] * size.width;
	
	// Draw background and track
	[view FillPatternRectangle:grassImage X0:0 Y0:0 X1:size.width - 1 Y1:size.height - 1];
	
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
	
	// Draw pit loss figure
	NSString * pLossString = [NSString stringWithFormat:@"%ds", (int)(roundf(pitStopLoss * xMaxTime))];
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
	
	// Add tick marks at 5 sec intervals
	int counter = 0;
	[view SaveFont];
	[view UseMediumBoldFont];
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
	
	// Get image list for the car images
	RacePadDatabase *database = [RacePadDatabase Instance];
	ImageListStore * image_store = [database imageListStore];
	
	ImageList *image_list = image_store ? [image_store findList:@"MiniCars"] : nil;
		
	int lastX = 9999;
	int lastRow = 0;
	int i;
	for ( i = count - 1; i >= 0; i-- )
		[[cars objectAtIndex:i] preDrawInView:view Simplified:simplified Height:graphicHeight Y:x_axis LastX:&lastX LastRow:&lastRow];
	
	for ( i = 0; i < count; i++ )
		[[cars objectAtIndex:i] drawInView:view Simplified:simplified Y:x_axis XMaxTime:xMaxTime ImageList:image_list];
	
}

- (void) drawCar:(int)car InView:(PitWindowView *)view
{
	CGSize size = [view InqSize];
	
	if ( kerbImage == nil )
	{
		grassImage = [[UIImage imageNamed:@"Grass.png"] retain];
		kerbImage = [[UIImage imageNamed:@"Kerbs.png"] retain];
		trackImage = [[UIImage imageNamed:@"Metal.png"] retain];
	}
	
	float axisSpace = size.height > 250 ? 30 : 25;
	
	float graphicHeight = (size.height - axisSpace) / 2;
	
	if(graphicHeight > 130)
		graphicHeight = 130;
	else if(graphicHeight < 90)
		graphicHeight = 90;
	
	[self drawGraphicInView:view IsBlueCar:(car == RPD_BLUE_CAR_) Y:(size.height - axisSpace) Height:graphicHeight];
}

@end

