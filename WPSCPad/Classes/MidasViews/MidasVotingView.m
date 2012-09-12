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

@synthesize driver;
@synthesize votesForLabel;
@synthesize votesAgainstLabel;
@synthesize ratingLabel;

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Super class overrides

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
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
    if(midasVoting)
        [midasVoting release];
    
    if(driver)
        [driver release];
    
    if(votesForLabel)
        [votesForLabel release];
    
    if(votesAgainstLabel)
        [votesAgainstLabel release];

    if(ratingLabel)
       [ratingLabel release];

    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Methods for this class 

- (void)InitialiseMembers
{
    midasVoting = nil;
    driver = nil;
    
    votesForLabel = nil;
    votesAgainstLabel = nil;
    ratingLabel = nil;
}

- (void) drawGraph
{
    if(midasVoting)
        [midasVoting drawInView:self];
}

- (void)Draw:(CGRect) rect
{
	[self ClearScreen];
	if ( driver )
	{
        if(midasVoting)
            [midasVoting release];
        
        midasVoting = [[MidasVoting alloc] initWithDriver:driver];
        
        [self drawGraph];
        
		[votesForLabel setText:[NSString stringWithFormat:@"%d", [midasVoting votesFor]]];
		[votesAgainstLabel setText:[NSString stringWithFormat:@"%d", [midasVoting votesAgainst]]];
 
		int position = [midasVoting position];
		int driverCount = [midasVoting driverCount];
        if((position % 10) == 1 && position != 11)
            [ratingLabel setText:[NSString stringWithFormat:@"%dst out of %d", position, driverCount]];
        else if((position % 10) == 2 && position != 12)
            [ratingLabel setText:[NSString stringWithFormat:@"%dnd out of %d", position, driverCount]];
        else if((position % 10) == 3 && position != 13)
            [ratingLabel setText:[NSString stringWithFormat:@"%drd out of %d", position, driverCount]];
        else
            [ratingLabel setText:[NSString stringWithFormat:@"%dth out of %d", position, driverCount]];
        
        [midasVoting release];
        midasVoting = nil;
	}
}

@end

