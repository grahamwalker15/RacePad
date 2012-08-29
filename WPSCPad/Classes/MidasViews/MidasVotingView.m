//
//  MidasVotingView.m
//  MidasDemo
//
//  Created by Gareth Griffith on 8/28/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasVotingView.h"

#import "MidasDatabase.h"
#import "MidasVoting.h"

@implementation MidasVotingView

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

- (void)InitialiseMembers
{
}

- (void) drawGraph
{
	MidasDatabase *database = [MidasDatabase Instance];
	MidasVoting *midasVoting = [database midasVoting];
	
	if ( midasVoting )
	{
		[midasVoting drawInView:self];
	}
}

- (void)Draw:(CGRect) rect
{
	[self ClearScreen];
	[self drawGraph];	
}

@end

