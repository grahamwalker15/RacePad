//
//  TrackMapView.m
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "TrackMapView.h"
#import "RacePadDatabase.h"
#import "TrackMap.h"


@implementation TrackMapView


///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Super class overrides

//If the view is stored in the nib file,when it's unarchived it's sent -initWithCoder:

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
		// Put any class specific initialisation here
	}
	
    return self;
}

//If we create it ourselves, we use -initWithFrame:
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		// Put any class specific initialisation here
    }
    return self;
}

- (void)layoutSubviews
{
}

- (void)dealloc
{
	// Put any class specific releasing here
	
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Methods for this class 


- (void) drawTrack
{
	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackMap *trackMap = [database trackMap];
	
	if ( trackMap )
	{
		[trackMap draw:self];
	}
}

- (void)Draw:(CGRect) rect
{
	[self SetBGColour:[UIColor colorWithRed:0.00 green:0.0 blue:0.0 alpha:1.0]];
	[self FillRectangle:current_bounds_];
	
	[self drawTrack];	
}

@end

