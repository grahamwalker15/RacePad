//
//  PlayerGraphView.m
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "PlayerGraphView.h"
#import "MatchPadDatabase.h"
#import "PlayerGraph.h"


@implementation PlayerGraphView

@synthesize playerToFollow;

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Super class overrides

//If the view is stored in the nib file,when it's unarchived it's sent -initWithCoder:

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
	}
	
    return self;
}

//If we create it ourselves, we use -initWithFrame:
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
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
	[playerToFollow release];
	playerToFollow = nil;
	
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Methods for this class 

- (void) followPlayer:(NSString *)name
{
	if(name && [name length] > 0)
	{
		if(![playerToFollow isEqualToString:name])
		{
			[playerToFollow release];
			playerToFollow = [name retain];
			return;
		}
		else
		{
			return;
		}

	}
	
	// Reach here if either name was nil, or not found
	[playerToFollow release];
	playerToFollow = nil;	
}

- (void) drawGraph
{
	MatchPadDatabase *database = [MatchPadDatabase Instance];
	PlayerGraph *playerGraph = [database playerGraph];
	
	if ( playerGraph )
	{		
		[playerGraph drawInView:self];
	}
}

- (void)Draw:(CGRect) rect
{
	[self ClearScreen];
	[self drawGraph];	
}

@end


