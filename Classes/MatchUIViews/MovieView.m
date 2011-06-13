//
//  MovieView.m
//  RacePad
//
//  Created by Gareth Griffith on 10/31/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "MovieView.h"


@implementation MovieView

@synthesize moviePlayer;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
}


- (void)RequestRedraw
{
}

- (void)RequestRedrawInRect:(CGRect)rect
{
}

@end
