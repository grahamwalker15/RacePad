//
//  SurveyView.m
//  TrackSurvey
//
//  Created by Mark Riches 2/5/2011.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "SurveyView.h"
#import "BackgroundView.h"
#import "ElapsedTime.h"

@implementation SurveyPoint

@synthesize lat;
@synthesize	lng;

@end

@implementation SurveyView

@synthesize homeXOffset;
@synthesize homeYOffset;
@synthesize homeScaleX;
@synthesize homeScaleY;
@synthesize userXOffset;
@synthesize userYOffset;
@synthesize userScale;
@synthesize isAnimating;
@synthesize animationScaleTarget;
@synthesize animationAlpha;
@synthesize animationDirection;
@synthesize autoRotate;
@synthesize text;

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Super class overrides

//If the view is stored in the nib file,when it's unarchived it's sent -initWithCoder:

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
		[self InitialiseImages];
		[self InitialiseMembers];		
	}
	
    return self;
}

//If we create it ourselves, we use -initWithFrame:
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		[self InitialiseImages];
		[self InitialiseMembers];		
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
}

- (void)dealloc
{
	[points release];
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Methods for this class 

- (void)InitialiseMembers
{
	userScale = 1.0;
	userXOffset = 0.0;
	userYOffset = 0.0;	
	
	isAnimating = false;
	animationDirection = 0;
	animationAlpha = 0.0;
	
	autoRotate = false;
	
	points = [[NSMutableArray arrayWithCapacity:1000] retain];
	
}

- (void)InitialiseImages
{
}

- (float) interpolatedUserScale
{
	if(isAnimating)
		return ((1.0 - animationAlpha) * userScale + animationAlpha * animationScaleTarget);
	else
		return userScale;
}

- (void) PrepareDrawing
{
	bool first = true;
	double x0, y0, x1, y1;
	
	int count = [points count];
	for ( int i = 0; i < count; i++ )
	{
		SurveyPoint *point = [points objectAtIndex:i];
		double x = point.lng;
		double y = point.lat;
		if ( first )
		{
			x0 = x;
			y0 = y;
			x1 = x;
			y1 = y;
			first = false;
		}
		else
		{
			if ( x < x0 )
				x0 = x;
			if ( y < y0 )
				y0 = y;
			if ( x > x1 )
				x1 = x;
			if ( y > y1 )
				y1 = y;
		}
	}
	
	surveyX0 = x0;
	surveyY0 = y0;
	
	double centre_lat = y0 + (y1 - y0) / 2;
	
	double latval = centre_lat * 0.01745329251994;
	double lat_scale_y = 40075.16 * 1000 / 360.0;
	double long_scale_x = 40075.16 * 1000 / 360.0 * cos(latval);
	
	double map_width = (x1 - x0) * long_scale_x;
	double map_height = (y1 - y0) * lat_scale_y;
	
	float x_scale = map_width / current_size_.width;
	float y_scale = map_height / current_size_.height;
	
	if ( x_scale < y_scale )
	{
		x_scale_ = current_size_.width / (x1 - x0);
		y_scale_ = x_scale_ * long_scale_x / lat_scale_y;
	}
	else
	{
		y_scale_ = current_size_.height / (y1 - y0);
		x_scale_ = y_scale_ * lat_scale_y / long_scale_x;
	}
}

- (void) transformPoint: (double) x Y: (double) y X0: (float *) x0 Y0: (float *) y0
{
	*x0 = (float) ((x - surveyX0) * x_scale_ * userScale + x_offset_ + userXOffset);
	*y0 = (float) (current_size_.height - ( (y - surveyY0) * y_scale_ * userScale + y_offset_ + userYOffset ));
}

- (void) unTransformPoint: (int) x Y: (int) y X0: (float *) x0 Y0: (float *) y0
{
	*x0 = (x - userXOffset - x_offset_) / userScale / x_scale_;
	*y0 = ((current_size_.height - y) - userYOffset - y_offset_) / userScale / y_scale_;
}

- (void) drawSurvey
{
	[self SetFGColour: black_];
	[self SetBGColour: very_light_grey_];
	if ( [points count] > 1 )
	{
		[self PrepareDrawing];
		int count = [points count];
		SurveyPoint *point = [points objectAtIndex:0];
		float x0, y0;
		[self transformPoint:point.lng Y:point.lat X0:&x0 Y0:&y0];
		for ( int i = 1; i < count; i++ )
		{
			point = [points objectAtIndex:i];
			float x1, y1;
			[self transformPoint:point.lng Y:point.lat X0:&x1 Y0:&y1];
			[self LineX0:x0 Y0:y0 X1:x1 Y1:y1];
			x0 = x1;
			y0 = y1;
		}
	}
}

- (void)Draw:(CGRect) rect
{
	[self ClearScreen];
	[self drawSurvey];	
	[self DrawString:text AtX:5 Y:30];
}

- (void) addPoint:(double) lng Lat:(double) lat
{
	if ( [points count] > 0 )
	{
		SurveyPoint *last = [points objectAtIndex:[points count] - 1];
		if ( last
		  && last.lat == lat
		  && last.lng == lng )
			return;
	}
	
	SurveyPoint *point = [[SurveyPoint alloc] init];
	point.lat = lat;
	point.lng = lng;
	[points addObject:point];
}

- (void) startSurvey
{
	[points removeAllObjects];
}

- (void) saveSurvey
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *folder = [paths objectAtIndex:0];
	int day, month, year;
	[ElapsedTime GetYear:&year Month:&month Day:&day];
	int d = (int) [ElapsedTime LocalTimeOfDay];
	int hour = d / 3600;
	int min = (d % 3600) / 60;
	int sec = d % 60;
	NSString *csv_name = [NSString stringWithFormat:@"Survey_%d-%d-%d_%d-%d-%d.csv", year, month, day, hour, min, sec];
	NSString *kml_name = [NSString stringWithFormat:@"Survey_%d-%d-%d_%d-%d-%d.kml", year, month, day, hour, min, sec];

	FILE *output = fopen ( [[folder stringByAppendingPathComponent: csv_name] UTF8String], "wt" );
	FILE *kml = fopen ( [[folder stringByAppendingPathComponent: kml_name] UTF8String], "wt" );
	if ( output && kml )
	{
		fprintf ( kml, "<?xml version=\"1.0\"?>\n" );
		fprintf ( kml, "<kml xmlns=\"http://earth.google.com/kml/2.1\">\n" );
		fprintf ( kml, "<Document creator=\"TrackSurvey\">\n" );
		fprintf ( kml, "<name>track</name>\n" );
		fprintf ( kml, "<open>1</open>\n" );
		fprintf ( kml, "<Folder>\n" );
		fprintf ( kml, "<name>SBG Trackmap</name>\n" );
		fprintf ( kml, "<open>0</open>\n" );
		fprintf ( kml, "<Placemark>\n" );
		fprintf ( kml, "<name>RACING_LINE</name>\n" );
        fprintf ( kml, "<Style>\n" );
		fprintf ( kml, "<LineStyle>\n" );
		fprintf ( kml, "<color>ffff00ff</color>\n" );
		fprintf ( kml, "<width>2</width>\n" );
		fprintf ( kml, "</LineStyle>\n" );
        fprintf ( kml, "</Style>\n" );
        fprintf ( kml, "<MultiGeometry>\n" );
		fprintf ( kml, "<LineString>\n" );
		fprintf ( kml, "<tessellate>1</tessellate>\n" );
		fprintf ( kml, "<coordinates>\n" );
		int count = [points count];
		for ( int i = 0; i < count; i++ )
		{
			SurveyPoint *point = [points objectAtIndex:i];
			fprintf ( output, "%10.6f, %10.6f\n", point.lng, point.lat );
			fprintf ( kml, "%7.6f,%7.6f\n", point.lng, point.lat );
		}
		fprintf ( kml, "</coordinates>\n" );
		fprintf ( kml, "</LineString>\n" );
        fprintf ( kml, "</MultiGeometry>\n" );
		fprintf ( kml, "</Placemark>\n" );
		fprintf ( kml, "</Folder>\n" );
		fprintf ( kml, "</Document>\n" );
		fprintf ( kml, "</kml>\n" );
		fclose ( output );
		fclose ( kml );
	}
}

@end


