//
//  HeadToHeadView.m
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "HeadToHeadView.h"
#import "RacePadDatabase.h"
#import "HeadToHead.h"

#import "UIConstants.h"
#import "HeadToHead.h"


@implementation HeadToHeadView

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Super class overrides

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
	}
	
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
}

- (void)dealloc
{
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Methods for this class 

- (void) drawHeadToHead
{
	RacePadDatabase *database = [RacePadDatabase Instance];
	HeadToHead *headToHead = [database headToHead];
	
	if ( headToHead )
	{
		[self UseBoldFont];
		NSString *s;
		if ( headToHead.completedLapCount )
			s = [NSString stringWithFormat:@"%s v %s Gap: %5.2f", [headToHead.abbr0 UTF8String], [headToHead.abbr1 UTF8String], [(HeadToHeadLap *)[headToHead.laps objectAtIndex:headToHead.completedLapCount - 1] gap]];
		else
			s = [NSString stringWithFormat:@"Head To Head View"];
		[self DrawString:s AtX:20 Y:20];
	}
}

- (void)Draw:(CGRect) rect
{
	[self ClearScreen];
	[self drawHeadToHead];	
}

@end

