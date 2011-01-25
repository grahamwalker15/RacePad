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
#import "RacePadDatabase.h"
#import "TabletState.h"

#import "TelemetryView.h"
#import "UIConstants.h"

@implementation TelemetryCar

@synthesize brakePressed;
@synthesize throttlePressed;

static UIImage * bigWheelImage = nil;
static UIImage * smallWheelImage = nil;
static UIImage * drivingWheelImage = nil;
static UIImage * carImage  = nil;
static UIImage * pedalImage  = nil;
static UIImage * gearImage  = nil;
static UIImage * rpmImageWhite  = nil;
static UIImage * rpmImageGreen  = nil;
static UIImage * rpmImageOrange  = nil;
static UIImage * rpmImageRed  = nil;
static UIImage * blueBarImage = nil;
static UIImage * redBarImage = nil;

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

- (void) drawInView:(TelemetryView *)view Colour:(int)colour
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
		blueBarImage = [[UIImage imageNamed:@"BlueBar.png"] retain];
		redBarImage = [[UIImage imageNamed:@"RedBar.png"] retain];
	}
	
	int sampleScore = 0;
	
	// Get the device orientation and set things up accordingly
	int orientation = [[RacePadCoordinator Instance] deviceOrientation];

	UIImage * wheelImage = nil;
	int pedalHeight;

	if ( view.drivingMode )
	{
		if ( drivingWheelImage == nil )
			drivingWheelImage = [[UIImage imageNamed:@"DrivingWheel.png"] retain];
		wheelImage = drivingWheelImage;
		pedalHeight = 80;
	}
	else
		if(orientation == UI_ORIENTATION_PORTRAIT_)
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

	// Draw car with G Forces
	CGSize carSize = [carImage size];
	
	float carWidth = carSize.width;
	float carHeight = carSize.height;
	
	float carXCentre = 80 + carWidth / 2;
	float carYCentre = viewBoundsSize.height / 2;
	
	float wheelXCentre = viewBoundsSize.width / 2;
	float wheelYCentre = viewBoundsSize.height / 2;
	
	UIColor * transparent_white_ = [DrawingView CreateColourRed:255 Green:255 Blue:255 Alpha:0.3];
	
	if ( !view.drivingMode )
	{
	
		[view DrawImage:carImage AtX:carXCentre - carWidth * 0.5 Y:carYCentre - carHeight * 0.5];
			
		float xLeft = carXCentre - 35;
		float xRight = carXCentre + 35;
		float yTop = carYCentre - carHeight * 0.5 - 3;
		float yBottom = carYCentre + carHeight * 0.5 + 3;
		
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
		
		CGPathRelease(arrowTop);
		CGPathRelease(arrowBottom);
		CGPathRelease(arrowLeft);
		CGPathRelease(arrowRight);
	}
	
	// Draw brake and throttle
	float throttleX;
	float brakeX;
	float pedalBase;
	
	if ( view.drivingMode )
	{
		throttleX = viewBoundsSize.width - 120;
		brakeX = 90;
		pedalBase = 20 + pedalHeight;
	}
	else
	{
		throttleX = wheelXCentre + 10;
		brakeX = wheelXCentre - 40;
		pedalBase = viewBoundsSize.height - 10;
	}

	CGMutablePathRef rectThrottle = [DrawingView CreateRoundedRectPathX0:throttleX Y0:pedalBase - pedalHeight X1:throttleX + 30 Y1:pedalBase Radius:5.0];
	CGMutablePathRef rectBrake = [DrawingView CreateRoundedRectPathX0:brakeX Y0:pedalBase - pedalHeight X1:brakeX + 30 Y1:pedalBase Radius:5.0];
	
	float throttleHeight = throttle * 0.01 * pedalHeight;
	float brakeHeight = brake * 0.01 * pedalHeight;
	
	[view SaveGraphicsState];
	[view SetClippingAreaToPath:rectThrottle];
	[view DrawImage:pedalImage AtX:throttleX Y:pedalBase - pedalHeight];
	[view SetBGColour:[view green_]];
	[view FillRectangleX0:throttleX Y0:pedalBase -  throttleHeight X1:throttleX + 30 Y1:pedalBase];
	[view RestoreGraphicsState];
	
	[view SaveGraphicsState];
	[view SetClippingAreaToPath:rectBrake];
	[view DrawImage:pedalImage AtX:brakeX Y:pedalBase - pedalHeight];
	[view SetBGColour:[view red_]];
	[view FillRectangleX0:brakeX Y0:pedalBase - brakeHeight X1:brakeX + 30 Y1:pedalBase ];
	[view RestoreGraphicsState];
		
	if ( view.drivingMode )
	{
		if ( throttleHeight <= 0 && !throttlePressed )
		{
			[view SetFGColour:[view white_]];
			sampleScore += 1;
		}
		else if ( throttleHeight > 0 && throttlePressed )
		{
			[view SetFGColour:[view green_]];
			sampleScore += 2;
		}
		else
			[view SetFGColour:[view red_]];
		[view BeginPath];
		[view LoadPath:rectThrottle];
		[view LineCurrentPath];
		
		if ( brakeHeight <= 0 && !brakePressed )
		{
			[view SetFGColour:[view white_]];
			sampleScore += 1;
		}
		else if ( brakeHeight > 0 && brakePressed )
		{
			[view SetFGColour:[view green_]];
			sampleScore += 2;
		}
		else
			[view SetFGColour:[view red_]];
		[view BeginPath];
		[view LoadPath:rectBrake];
		[view LineCurrentPath];
	}
	else
	{
		[view SetFGColour:[view white_]];
		[view BeginPath];
		[view LoadPath:rectThrottle];
		[view LoadPath:rectBrake];
		[view LineCurrentPath];
	}
		
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
	
	[view SetBGColour:[view dark_grey_]];
	[view FillRectangleX0:mapRect.origin.x Y0:mapRect.origin.y + mapRect.size.height + 3 X1:mapRect.origin.x + mapRect.size.width Y1:mapRect.origin.y + mapRect.size.height + 16 ];
	
	float lapDist = 6920.0;
	float s1Dist = 2229.0 / lapDist;
	float s2Dist = 5016.0 / lapDist;
	
	float distWidth = distance / lapDist * mapRect.size.width;
	
	if(colour == RPD_BLUE_CAR_)
		[view FillPatternRectangle:blueBarImage X0:mapRect.origin.x Y0:mapRect.origin.y + mapRect.size.height + 3 X1:mapRect.origin.x + distWidth Y1:mapRect.origin.y + mapRect.size.height + 16 ];
	else
		[view FillPatternRectangle:redBarImage X0:mapRect.origin.x Y0:mapRect.origin.y + mapRect.size.height + 3 X1:mapRect.origin.x + distWidth Y1:mapRect.origin.y + mapRect.size.height + 16 ];

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
		[view DrawString:sectorLabel AtX:xLeft + (sWidth - w) * 0.5 Y:mapRect.origin.y + mapRect.size.height + 16 - h + 1];
	}

	float steeringAngle = steering;
	if ( [view drivingMode] )
	{
		steeringAngle -= [[TabletState Instance] currentRotation];
		if ( steeringAngle  > 180 )
			steeringAngle -= 360;
		if ( steeringAngle < -180 )
			steeringAngle += 360;
	}

	//Draw dashboard BG
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

	// Draw RPM Lights
	int rpmLimit[12] = {7000, 8500, 10500, 12500, 14000, 15000, 15500, 16000, 16500, 16900, 17200, 17500};
	
	float rpmPos = dashLeft + 8;
	float rpmStep = 12;
	float rpmY = dashYBase +3;
	
	if ( view.drivingMode )
	{
		int steeringScore = 12 - (int) ( fabs ( steeringAngle ) / 4 );
		if ( steeringScore < 0 )
			steeringScore = 0;
		for(int i = 0 ; i < 12 ; i++)
		{
			if(steeringScore < i)
				[view DrawImage:rpmImageWhite AtX:rpmPos Y:rpmY];
			else if(i == 11)
				[view DrawImage:rpmImageGreen AtX:rpmPos Y:rpmY];
			else if(i >= 9)
				[view DrawImage:rpmImageOrange AtX:rpmPos Y:rpmY];
			else
				[view DrawImage:rpmImageRed AtX:rpmPos Y:rpmY];
			
			rpmPos += rpmStep;
		}
		sampleScore += steeringScore;
	}
	else
	{
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
	}

	// Draw Dashboard Text
	[view SetFGColour:[view black_]];
	[view UseMediumBoldFont];
	
	if ( view.drivingMode )
	{
		[view DrawString:[NSString stringWithFormat:@"%d", sampleScore] AtX:dashLeft + 35 Y:dashYBase + 16];
		score += sampleScore;
		
		[view UseBigFont];
		[view DrawString:[NSString stringWithFormat:@"%d", score] AtX:dashSplit +10 Y:dashYBase + 16];
	}
	else
	{
		[view DrawImage:gearImage AtX:dashLeft + 5 Y:dashYBase + 31];
		[view DrawString:[NSString stringWithFormat:@"KPH"] AtX:dashRight - 35 Y:dashYBase + 31];
		
		[view UseBigFont];
		[view DrawString:[NSString stringWithFormat:@"%d", (int)speed] AtX:dashSplit +10 Y:dashYBase + 16];
		
		if(gear > 0)
			[view DrawString:[NSString stringWithFormat:@"%d", gear] AtX:dashLeft + 35 Y:dashYBase + 16];
		else
			[view DrawString:[NSString stringWithFormat:@"N"] AtX:dashLeft + 35 Y:dashYBase + 16];
	}
	//Draw wheel
	CGSize wheelSize = [wheelImage size];
	
	[view SaveGraphicsState];
	[view SetTranslateX:wheelXCentre Y:wheelYCentre];
	[view SetRotationInDegrees:steeringAngle];
	[view SetTranslateX:(-wheelSize.width * 0.5) Y:(-wheelSize.height * 0.5)];
	[view SetDropShadowXOffset:4 YOffset:8 Blur:3];
	[view DrawImage:wheelImage AtX:0 Y:0];
	[view RestoreGraphicsState];
	
	// Driving Game Test
	if ( [view drivingMode] )
	{
		if ( fabs ( steeringAngle ) < 10 )
			[view SetFGColour:[view white_]];
		else
			[view SetFGColour:[view red_]];
		[view LineX0:wheelXCentre - wheelSize.width / 2 Y0:wheelYCentre X1:wheelXCentre + wheelSize.width / 2 Y1:wheelYCentre];
		[view LineX0:wheelXCentre Y0:wheelYCentre + wheelSize.height / 2 X1:wheelXCentre Y1:wheelYCentre - wheelSize.height / 2];
	}
	
	[transparent_white_ release];
	
	CGPathRelease(rectThrottle);
	CGPathRelease(rectBrake);
	
}

- (void) resetDriving
{
	brakePressed = false;
	throttlePressed = false;
	score = 0;
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

- (void) drawCar:(int)car InView:(TelemetryView *)view;
{	
	if(car == RPD_BLUE_CAR_)
		[blueCar drawInView:view Colour:car];
	else if(car == RPD_RED_CAR_)
		[redCar drawInView:view Colour:car];
}


////////////////////////////////////////////////////////////////////////
//


@end

