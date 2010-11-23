//
//  TrackMap.m
//  RacePad
//
//  Created by Mark Riches on 12/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Telemetry.h"
#import "DataStream.h"
#import "TelemetryView.h"

@implementation TelemetryCar

static UIImage * wheelImage = nil;
static UIImage * carImage  = nil;

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
}

- (void) drawInView:(TelemetryView *)view
{
	// Make sure we have the images
	if ( carImage == nil )
	{
		carImage = [[UIImage imageNamed:@"TelemetryBG.png"] retain];
		wheelImage = [[UIImage imageNamed:@"TelemetrySteeringWheel.png"] retain];
	}
	
	// Draw outline
	[view SaveGraphicsState];
	[view SetLineWidth:3];
	[view SetFGColour:[view black_]];
	CGRect inner_rect = CGRectInset([view bounds], 1, 1);
	[view LineRectangle:inner_rect];
	[view RestoreGraphicsState];
	
	// Draw car with G Forces
	CGSize viewBounds = [view bounds].size;
	CGSize carSize = [carImage size];
	
	float carWidth = carSize.width;
	float carHeight = carSize.height;
	
	float carXCentre = 80 + carWidth / 2;
	float carYCentre = viewBounds.height / 2;
	
	float wheelXCentre = viewBounds.width / 2;
	float wheelYCentre = viewBounds.height / 2;

	float pedalBase = viewBounds.height - 10;
	
	[view DrawImage:carImage AtX:carXCentre - carWidth * 0.5 Y:carYCentre - carHeight * 0.5];
		
	float xLeft = carXCentre - 50;
	float xRight = carXCentre + 50;
	float yTop = carYCentre - carHeight * 0.5;
	float yBottom = carYCentre + carHeight * 0.5;
	
	float arrowWidth = 15;
	float arrowLength = 60;
	
	float gRight = gLat > 0 ? gLat * arrowLength / 4 : 0;
	float gLeft = gLat < 0 ? -gLat * arrowLength / 4 : 0;
	float gFront = gLong > 0 ? gLong * arrowLength / 4 : 0;
	float gBack = gLong < 0 ? -gLong * arrowLength / 4 : 0;
	
	CGMutablePathRef arrowLeft = [DrawingView CreateTrianglePathX0:xLeft Y0:carYCentre - arrowWidth X1:xLeft Y1:carYCentre + arrowWidth X2:xLeft - arrowLength Y2:carYCentre];
	CGMutablePathRef arrowRight = [DrawingView CreateTrianglePathX0:xRight Y0:carYCentre - arrowWidth X1:xRight Y1:carYCentre + arrowWidth X2:xRight + arrowLength Y2:carYCentre];
	CGMutablePathRef arrowTop = [DrawingView CreateTrianglePathX0:carXCentre - arrowWidth Y0:yTop X1:carXCentre + arrowWidth Y1:yTop X2:carXCentre Y2:yTop - arrowLength];
	CGMutablePathRef arrowBottom = [DrawingView CreateTrianglePathX0:carXCentre - arrowWidth Y0:yBottom X1:carXCentre + arrowWidth Y1:yBottom X2:carXCentre Y2:yBottom + arrowLength];
	
	[view SaveGraphicsState];
	[view SetBGColour:[view red_]];
	[view SetClippingAreaToPath:arrowTop];
	[view FillRectangleX0:carXCentre - arrowWidth Y0:carYCentre - carHeight * 0.5 -  gBack X1:carXCentre + arrowWidth Y1:carYCentre - carHeight * 0.5];
	[view RestoreGraphicsState];
	
	[view SaveGraphicsState];
	[view SetBGColour:[view green_]];
	[view SetClippingAreaToPath:arrowBottom];
	[view FillRectangleX0:carXCentre - arrowWidth Y0:carYCentre + carHeight * 0.5 X1:carXCentre + arrowWidth Y1:carYCentre + carHeight * 0.5 + gFront];
	[view RestoreGraphicsState];
	
	[view SaveGraphicsState];
	[view SetBGColour:[view orange_]];
	[view SetClippingAreaToPath:arrowLeft];
	[view FillRectangleX0:carXCentre - 25 - gLeft Y0:carYCentre - arrowWidth X1:carXCentre - 25 Y1:carYCentre + arrowWidth];
	[view RestoreGraphicsState];
	
	[view SaveGraphicsState];
	[view SetBGColour:[view orange_]];
	[view SetClippingAreaToPath:arrowRight];
	[view FillRectangleX0:carXCentre + 25 Y0:carYCentre - arrowWidth X1:carXCentre + 25 + gRight Y1:carYCentre + arrowWidth];
	[view RestoreGraphicsState];
	
	[view SetFGColour:[view white_]];
	[view BeginPath];
	[view LoadPath:arrowTop];
	[view LoadPath:arrowBottom];
	[view LoadPath:arrowLeft];
	[view LoadPath:arrowRight];
	[view LinePath];

	// Draw brake and throttle
	float throttleHeight = throttle * 0.01 * 80;
	float brakeHeight = brake * 0.01 * 80;
	
	[view SetBGColour:[view green_]];
	[view FillRectangleX0:wheelXCentre + 10 Y0:pedalBase -  throttleHeight X1:wheelXCentre + 40 Y1:pedalBase];
	
	[view SetBGColour:[view red_]];
	[view FillRectangleX0:wheelXCentre - 40 Y0:pedalBase - brakeHeight X1:wheelXCentre - 10 Y1:pedalBase ];
	
	[view SetFGColour:[view white_]];
	[view LineRectangleX0:wheelXCentre + 10 Y0:pedalBase - 80 X1:wheelXCentre + 40 Y1:pedalBase];
	[view LineRectangleX0:wheelXCentre - 40 Y0:pedalBase - 80 X1:wheelXCentre - 10 Y1:pedalBase ];
	
	//Draw dashboard
	[view SetBGColour:[view very_light_grey_]];
	[view FillRectangleX0:wheelXCentre - 80 Y0:20 X1:wheelXCentre - 20 Y1:60 ];
	[view SetBGColour:[view white_]];
	[view FillRectangleX0:wheelXCentre - 20 Y0:20 X1:wheelXCentre + 80 Y1:60 ];
	
	[view SetFGColour:[view black_]];
	[view LineRectangleX0:wheelXCentre - 80 Y0:20 X1:wheelXCentre - 20 Y1:60 ];
	[view LineRectangleX0:wheelXCentre - 20 Y0:20 X1:wheelXCentre + 80 Y1:60 ];
	
	[view UseMediumBoldFont];
	[view DrawString:[NSString stringWithFormat:@"L"] AtX:wheelXCentre -75 Y:25];
	[view DrawString:[NSString stringWithFormat:@"kph"] AtX:wheelXCentre + 45 Y:25];
	
	[view UseBigFont];
	[view DrawString:[NSString stringWithFormat:@"%d", (int)speed] AtX:wheelXCentre - 10 Y:25];
	
	if(laps > 0)
		 [view DrawString:[NSString stringWithFormat:@"%d", laps] AtX:wheelXCentre - 65 Y:25];

	//Draw wheel
	CGSize wheelSize = [wheelImage size];
	
	[view SaveGraphicsState];
	[view SetTranslateX:wheelXCentre Y:wheelYCentre];
	[view SetRotationInDegrees:steering];
	[view SetTranslateX:(-wheelSize.width * 0.5) Y:(-wheelSize.height * 0.5)];
	[view DrawImage:wheelImage AtX:0 Y:0];
	[view RestoreGraphicsState];
	
	/*
	[view UseMediumBoldFont];
	[view SetFGColour:[view black_]];
	
	float ytext = 25;
	
	[view DrawString:@"Speed" AtX:25 Y:ytext];
	[view DrawString:[NSString stringWithFormat:@"%.2f kph", speed] AtX:100 Y:ytext];
	ytext +=25;

	[view DrawString:@"Distance" AtX:25 Y:ytext];
	[view DrawString:[NSString stringWithFormat:@"%.2f m", distance] AtX:100 Y:ytext];
	ytext +=25;
	
	[view DrawString:@"Throttle" AtX:25 Y:ytext];
	[view DrawString:[NSString stringWithFormat:@"%.2f %%", throttle] AtX:100 Y:ytext];
	ytext +=25;

	[view DrawString:@"Brake" AtX:25 Y:ytext];
	[view DrawString:[NSString stringWithFormat:@"%.2f kph", brake] AtX:100 Y:ytext];
	ytext +=25;

	[view DrawString:@"Steering" AtX:25 Y:ytext];
	[view DrawString:[NSString stringWithFormat:@"%.2f deg", speed] AtX:100 Y:ytext];
	ytext +=25;

	[view DrawString:@"G Lat" AtX:25 Y:ytext];
	[view DrawString:[NSString stringWithFormat:@"%.2f g", gLat] AtX:100 Y:ytext];
	ytext +=25;
	
	[view DrawString:@"G Long" AtX:25 Y:ytext];
	[view DrawString:[NSString stringWithFormat:@"%.2f g", gLong] AtX:100 Y:ytext];
	ytext +=25;
	
	[view DrawString:@"Lap" AtX:25 Y:ytext];
	[view DrawString:[NSString stringWithFormat:@"%d L", laps] AtX:100 Y:ytext];
	ytext +=25;
	 
	*/
	
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

