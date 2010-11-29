//
//  TrackMap.m
//  RacePad
//
//  Created by Mark Riches on 12/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Telemetry.h"
#import "DataStream.h"
#import "RacePadCoordinator.h"
#import "TelemetryView.h"

@implementation TelemetryCar

static UIImage * bigWheelImage = nil;
static UIImage * smallWheelImage = nil;
static UIImage * carImage  = nil;
static UIImage * pedalImage  = nil;
static UIImage * gearImage  = nil;
static UIImage * rpmImageWhite  = nil;
static UIImage * rpmImageGreen  = nil;
static UIImage * rpmImageOrange  = nil;
static UIImage * rpmImageRed  = nil;
static UIImage * blackBarImage = nil;

- (void) load:(DataStream *)stream 
{
	speed = [stream PopFloat];
	throttle = [stream PopFloat];
	distance = [stream PopFloat];
	gLong = [stream PopFloat];
	gLat = [stream PopFloat];
	brake = [stream PopFloat];
	steering = [stream PopFloat];
	laps = [stream PopInt];
	gear = [stream PopInt];
	rpm = [stream PopInt];
}

- (void) drawInView:(TelemetryView *)view
{
	// Make sure we have the images
	if ( carImage == nil )
	{
		carImage = [[UIImage imageNamed:@"TelemetryCar.png"] retain];
		bigWheelImage = [[UIImage imageNamed:@"TelemetrySteeringWheel.png"] retain];
		smallWheelImage = [[UIImage imageNamed:@"TelemetrySteeringWheelSmall.png"] retain];
		pedalImage = [[UIImage imageNamed:@"Pedal.png"] retain];
		rpmImageWhite = [[UIImage imageNamed:@"RPMWhite.png"] retain];
		rpmImageGreen = [[UIImage imageNamed:@"RPMGreen.png"] retain];
		rpmImageOrange = [[UIImage imageNamed:@"RPMOrange.png"] retain];
		rpmImageRed = [[UIImage imageNamed:@"RPMRed.png"] retain];
		gearImage = [[UIImage imageNamed:@"GearCog.png"] retain];
		blackBarImage = [[UIImage imageNamed:@"BlackBar.png"] retain];
	}
	
	// Get the device orientation and set things up accordingly
	int orientation = [[RacePadCoordinator Instance] deviceOrientation];

	UIImage * wheelImage = nil;
	int pedalHeight;

	if(orientation == RPC_ORIENTATION_PORTRAIT_)
	{
		wheelImage = bigWheelImage;
		pedalHeight = 80;
	}
	else
	{
		wheelImage = smallWheelImage;
		pedalHeight = 60;
	}
	
	CGSize viewBoundsSize = [view bounds].size;
	CGRect mapRect = [view mapRect];

	// Draw outline
	[view SaveGraphicsState];
	[view SetLineWidth:3];
	[view SetFGColour:[view black_]];
	CGRect inner_rect = CGRectInset([view bounds], 1, 1);
	[view LineRectangle:inner_rect];
	[view RestoreGraphicsState];
	
	// Draw car with G Forces
	CGSize carSize = [carImage size];
	
	float carWidth = carSize.width;
	float carHeight = carSize.height;
	
	float carXCentre = 80 + carWidth / 2;
	float carYCentre = viewBoundsSize.height / 2;
	
	float wheelXCentre = viewBoundsSize.width / 2;
	float wheelYCentre = viewBoundsSize.height / 2;

	float pedalBase = viewBoundsSize.height - 10;
	
	[view DrawImage:carImage AtX:carXCentre - carWidth * 0.5 Y:carYCentre - carHeight * 0.5];
		
	float xLeft = carXCentre - 35;
	float xRight = carXCentre + 35;
	float yTop = carYCentre - carHeight * 0.5;
	float yBottom = carYCentre + carHeight * 0.5;
	
	float arrowWidth = 15;
	float arrowLength = 60;
	
	float gLeft = gLat > 0 ? gLat * arrowLength / 4 : 0;
	float gRight = gLat < 0 ? -gLat * arrowLength / 4 : 0;
	float gFront = gLong < 0 ? -gLong * arrowLength / 4 : 0;
	float gBack = gLong > 0 ? gLong * arrowLength / 4 : 0;
	
	CGMutablePathRef arrowLeft = [DrawingView CreateTrianglePathX0:xLeft Y0:carYCentre - arrowWidth X1:xLeft Y1:carYCentre + arrowWidth X2:xLeft - arrowLength Y2:carYCentre];
	CGMutablePathRef arrowRight = [DrawingView CreateTrianglePathX0:xRight Y0:carYCentre - arrowWidth X1:xRight Y1:carYCentre + arrowWidth X2:xRight + arrowLength Y2:carYCentre];
	CGMutablePathRef arrowTop = [DrawingView CreateTrianglePathX0:carXCentre - arrowWidth Y0:yTop X1:carXCentre + arrowWidth Y1:yTop X2:carXCentre Y2:yTop - arrowLength];
	CGMutablePathRef arrowBottom = [DrawingView CreateTrianglePathX0:carXCentre - arrowWidth Y0:yBottom X1:carXCentre + arrowWidth Y1:yBottom X2:carXCentre Y2:yBottom + arrowLength];

	CGMutablePathRef rectThrottle = [DrawingView CreateRoundedRectPathX0:wheelXCentre + 10 Y0:pedalBase - pedalHeight X1:wheelXCentre + 40 Y1:pedalBase Radius:5.0];
	CGMutablePathRef rectBrake = [DrawingView CreateRoundedRectPathX0:wheelXCentre - 40 Y0:pedalBase - pedalHeight X1:wheelXCentre - 10 Y1:pedalBase Radius:5.0];
	
	UIColor * transparent_white_ = [DrawingView CreateColourRed:255 Green:255 Blue:255 Alpha:0.3];
	
	[view SaveGraphicsState];
	[view SetClippingAreaToPath:arrowTop];
	[view SetBGColour:transparent_white_];
	[view FillPath:arrowTop];
	[view SetBGColour:[view red_]];
	[view FillRectangleX0:carXCentre - arrowWidth Y0:carYCentre - carHeight * 0.5 -  gFront X1:carXCentre + arrowWidth Y1:carYCentre - carHeight * 0.5];
	[view RestoreGraphicsState];
	
	[view SaveGraphicsState];
	[view SetClippingAreaToPath:arrowBottom];
	[view SetBGColour:transparent_white_];
	[view FillPath:arrowBottom];
	[view SetBGColour:[view green_]];
	[view FillRectangleX0:carXCentre - arrowWidth Y0:carYCentre + carHeight * 0.5 X1:carXCentre + arrowWidth Y1:carYCentre + carHeight * 0.5 + gBack];
	[view RestoreGraphicsState];
	
	[view SaveGraphicsState];
	[view SetClippingAreaToPath:arrowLeft];
	[view SetBGColour:transparent_white_];
	[view FillPath:arrowLeft];
	[view SetBGColour:[view orange_]];
	[view FillRectangleX0:carXCentre - 25 - gLeft Y0:carYCentre - arrowWidth X1:carXCentre - 25 Y1:carYCentre + arrowWidth];
	[view RestoreGraphicsState];
	
	[view SaveGraphicsState];
	[view SetClippingAreaToPath:arrowRight];
	[view SetBGColour:transparent_white_];
	[view FillPath:arrowRight];
	[view SetBGColour:[view orange_]];
	[view FillRectangleX0:carXCentre + 25 Y0:carYCentre - arrowWidth X1:carXCentre + 25 + gRight Y1:carYCentre + arrowWidth];
	[view RestoreGraphicsState];
	
	[view SetFGColour:[view white_]];
	[view BeginPath];
	[view LoadPath:arrowTop];
	[view LoadPath:arrowBottom];
	[view LoadPath:arrowLeft];
	[view LoadPath:arrowRight];
	[view LineCurrentPath];

	// Draw brake and throttle
	float throttleHeight = throttle * 0.01 * pedalHeight;
	float brakeHeight = brake * 0.01 * pedalHeight;
	
	[view SaveGraphicsState];
	[view SetClippingAreaToPath:rectThrottle];
	[view DrawImage:pedalImage AtX:wheelXCentre + 10 Y:pedalBase - pedalHeight];
	[view SetBGColour:[view green_]];
	[view FillRectangleX0:wheelXCentre + 10 Y0:pedalBase -  throttleHeight X1:wheelXCentre + 40 Y1:pedalBase];
	[view RestoreGraphicsState];
	
	
	[view SaveGraphicsState];
	[view SetClippingAreaToPath:rectBrake];
	[view DrawImage:pedalImage AtX:wheelXCentre - 40 Y:pedalBase - pedalHeight];
	[view SetBGColour:[view red_]];
	[view FillRectangleX0:wheelXCentre - 40 Y0:pedalBase - brakeHeight X1:wheelXCentre - 10 Y1:pedalBase ];
	[view RestoreGraphicsState];
		
	[view SetFGColour:[view white_]];
	[view BeginPath];
	[view LoadPath:rectThrottle];
	[view LoadPath:rectBrake];
	[view LineCurrentPath];
	
	//Draw dashboard
	float dashLeft = wheelXCentre - 80;
	float dashRight = wheelXCentre + 80;
	float dashSplit = wheelXCentre - 20;
	float dashYBase = 20;
	
	[view SetBGColour:[view very_light_grey_]];
	[view FillRectangleX0:dashLeft Y0:dashYBase + 16 X1:dashRight Y1:dashYBase + 51 ];
	[view SetBGColour:[view dark_grey_]];
	[view FillRectangleX0:dashLeft Y0:dashYBase + 16 X1:dashSplit Y1:dashYBase + 51  ];
	[view SetBGColour:[view very_dark_grey_]];
	[view FillRectangleX0:dashLeft Y0:dashYBase X1:dashRight Y1:dashYBase  + 16 ];
	
	[view SetFGColour:[view black_]];
	[view LineRectangleX0:dashLeft Y0:dashYBase X1:dashRight Y1:dashYBase + 16  ];
	[view LineRectangleX0:dashLeft Y0:dashYBase + 16 X1:dashSplit Y1:dashYBase + 51  ];
	[view LineRectangleX0:dashSplit Y0:dashYBase + 16 X1:dashRight Y1:dashYBase + 51  ];
	
	[view SetFGColour:[view white_]];
	[view LineRectangleX0:dashLeft - 1 Y0:dashYBase - 1 X1:dashRight + 1 Y1:dashYBase + 52 ];
	
	[view SetFGColour:[view black_]];
	[view UseMediumBoldFont];
	[view DrawImage:gearImage AtX:dashLeft + 5 Y:dashYBase + 31];
	[view DrawString:[NSString stringWithFormat:@"KPH"] AtX:dashRight - 35 Y:dashYBase + 31];
	
	[view UseBigFont];
	[view DrawString:[NSString stringWithFormat:@"%d", (int)speed] AtX:dashSplit +10 Y:dashYBase + 16];
	
	if(gear > 0)
		[view DrawString:[NSString stringWithFormat:@"%d", gear] AtX:dashLeft + 35 Y:dashYBase + 16];
	else
		[view DrawString:[NSString stringWithFormat:@"N"] AtX:dashLeft + 35 Y:dashYBase + 16];
	
	
	// Draw lap counter and distance guage around the map
	if(laps > 0)
	{
		[view UseMediumBoldFont];
		NSString * lapLabel = [NSString stringWithFormat:@"Lap %d", laps];
		
		float w, h;
		[view GetStringBox:lapLabel WidthReturn:&w HeightReturn:&h];

		[view SetFGColour:[view white_]];
		[view DrawString:lapLabel AtX:mapRect.origin.x + mapRect.size.width - w Y:mapRect.origin.y - h - 3];
	}
	
	[view SetBGColour:transparent_white_];
	[view FillRectangleX0:mapRect.origin.x Y0:mapRect.origin.y + mapRect.size.height + 3 X1:mapRect.origin.x + mapRect.size.width Y1:mapRect.origin.y + mapRect.size.height + 16 ];
	
	float lapDist = 6920.0;
	float s1Dist = 2229.0 / lapDist;
	float s2Dist = 5016.0 / lapDist;
	
	float distWidth = distance / lapDist * mapRect.size.width; 
	[view SetBGColour:[view dark_grey_]];
	//[view FillRectangleX0:mapRect.origin.x Y0:mapRect.origin.y + mapRect.size.height + 3 X1:mapRect.origin.x + distWidth Y1:mapRect.origin.y + mapRect.size.height + 16 ];
	[view FillPatternRectangle:blackBarImage X0:mapRect.origin.x Y0:mapRect.origin.y + mapRect.size.height + 3 X1:mapRect.origin.x + distWidth Y1:mapRect.origin.y + mapRect.size.height + 16 ];

	[view SetFGColour:[view white_]];
	[view LineX0:mapRect.origin.x + s1Dist * mapRect.size.width Y0:mapRect.origin.y + mapRect.size.height + 3 X1:mapRect.origin.x + s1Dist * mapRect.size.width Y1:mapRect.origin.y + mapRect.size.height + 16 ];
	[view LineX0:mapRect.origin.x + s2Dist * mapRect.size.width Y0:mapRect.origin.y + mapRect.size.height + 3 X1:mapRect.origin.x + s2Dist * mapRect.size.width Y1:mapRect.origin.y + mapRect.size.height + 16 ];
	[view LineRectangleX0:mapRect.origin.x Y0:mapRect.origin.y + mapRect.size.height + 3 X1:mapRect.origin.x + mapRect.size.width Y1:mapRect.origin.y + mapRect.size.height + 16 ];
	
	[view UseControlFont];
	for(int i = 0 ; i < 3 ; i++)
	{
		NSString * sectorLabel = [NSString stringWithFormat:@"Sector %d", i+1];
	
		float w, h;
		[view GetStringBox:sectorLabel WidthReturn:&w HeightReturn:&h];
		
		float xLeft, xRight;
		
		if(i == 0)
		{
			xLeft = mapRect.origin.x;
			xRight = mapRect.origin.x + s1Dist * mapRect.size.width;
		}
		else if(i == 1)
		{
			xLeft = mapRect.origin.x + s1Dist * mapRect.size.width;
			xRight = mapRect.origin.x + s2Dist * mapRect.size.width;
		}
		else
		{
			xLeft = mapRect.origin.x + s2Dist * mapRect.size.width;
			xRight = mapRect.origin.x + mapRect.size.width;
		}
		
		float sWidth = xRight - xLeft;
			
		[view SetFGColour:[view white_]];
		[view DrawString:sectorLabel AtX:xLeft + (sWidth - w) * 0.5 Y:mapRect.origin.y + mapRect.size.height + 16 - h];
	}

	// Draw RPM Lights
	int rpmLimit[12] = {7000, 8500, 10500, 12500, 14000, 15000, 15500, 16000, 16500, 16900, 17200, 17500};
	
	float rpmPos = dashLeft + 8;
	float rpmStep = 12;
	float rpmY = dashYBase +3;
	
	for(int i = 0 ; i < 12 ; i++)
	{
		if(rpm < rpmLimit[i])
			[view DrawImage:rpmImageWhite AtX:rpmPos Y:rpmY];
		else if(i == 11)
			[view DrawImage:rpmImageRed AtX:rpmPos Y:rpmY];
		else if(i >= 9)
			[view DrawImage:rpmImageOrange AtX:rpmPos Y:rpmY];
		else
			[view DrawImage:rpmImageGreen AtX:rpmPos Y:rpmY];
		
		rpmPos += rpmStep;

	}

	//Draw wheel
	CGSize wheelSize = [wheelImage size];
	
	[view SaveGraphicsState];
	[view SetTranslateX:wheelXCentre Y:wheelYCentre];
	[view SetRotationInDegrees:steering];
	[view SetTranslateX:(-wheelSize.width * 0.5) Y:(-wheelSize.height * 0.5)];
	[view SetDropShadowXOffset:4 YOffset:8 Blur:3];
	[view DrawImage:wheelImage AtX:0 Y:0];
	[view RestoreGraphicsState];
	
	[transparent_white_ release];
	
	CGPathRelease(arrowTop);
	CGPathRelease(arrowBottom);
	CGPathRelease(arrowLeft);
	CGPathRelease(arrowRight);
	CGPathRelease(rectThrottle);
	CGPathRelease(rectBrake);
	
}

@end


@implementation Telemetry

@synthesize redCar;
@synthesize blueCar;

- (id) init
{
	if(self = [super init])
	{
		redCar = [[TelemetryCar alloc] init];
		blueCar = [[TelemetryCar alloc] init];
	}
	
	return self;
}

- (void) dealloc
{
	[redCar release];
	[blueCar release];
	
	[super dealloc];
}

- (void) load : (DataStream *) stream
{
	[redCar load:stream];
	[blueCar load:stream];
}

- (void) drawCar:(TelemetryCar *)car InView:(TelemetryView *)view;
{	
	[car drawInView:view];
}


////////////////////////////////////////////////////////////////////////
//


@end

