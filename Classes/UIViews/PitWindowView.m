//
//  PitWindowView.m
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "PitWindowView.h"
#import "RacePadDatabase.h"
#import "PitWindow.h"


@implementation PitWindowView

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Super class overrides

//If the view is stored in the nib file,when it's unarchived it's sent -initWithCoder:
/*
- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
		[self InitialiseImages];
	}
	
    return self;
}
*/

//If we create it ourselves, we use -initWithFrame:
/*
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		[self InitialiseImages];
    }
    return self;
}
*/

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

- (void) drawPitWindow
{
	RacePadDatabase *database = [RacePadDatabase Instance];
	PitWindow *pitWindow = [database pitWindow];
	
	if ( pitWindow )
	{
		[pitWindow draw:self];
	}
}

- (void)Draw:(CGRect) rect
{
	[self ClearScreen];
	[self drawPitWindow];	
}

@end

