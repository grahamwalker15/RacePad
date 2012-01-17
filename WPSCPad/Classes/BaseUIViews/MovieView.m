//
//  MovieView.m
//  RacePad
//
//  Created by Gareth Griffith on 10/31/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "MovieView.h"

@implementation MovieView

@synthesize movieSource;
@synthesize moviePlayerLayerAdded;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        // Initialization code
		movieSource = nil;
		moviePlayerLayerAdded = false;
    }
    return self;
}

- (void)dealloc
{
	[movieSource release];
    [super dealloc];
}

- (bool) displayMovieSource:(BasePadVideoSource *)source
{	
	AVPlayerLayer * moviePlayerLayer = [source moviePlayerLayer];
	
	if(moviePlayerLayer && !moviePlayerLayerAdded)
	{
		CALayer *superlayer = self.layer;
		
		[moviePlayerLayer setFrame:self.bounds];
		[superlayer addSublayer:moviePlayerLayer];
		
		[self setMoviePlayerLayerAdded:true];
		[self setMovieSource:source];
		
		return true;
	}
	
	return false;
}

- (void)removeMovieFromView
{
	if(moviePlayerLayerAdded && movieSource)
	{
		AVPlayerLayer * moviePlayerLayer = [movieSource moviePlayerLayer];
		if(moviePlayerLayer)
			[moviePlayerLayer removeFromSuperlayer];

	}
	
	moviePlayerLayerAdded = false;
	
	[movieSource release];
	movieSource = nil;
}

- (void)RequestRedraw
{
}

- (void)RequestRedrawInRect:(CGRect)rect
{
}

@end
