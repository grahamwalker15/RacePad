//
//  MovieView.m
//  RacePad
//
//  Created by Gareth Griffith on 10/31/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "MovieView.h"
#import "BasePadCoordinator.h"

@implementation MovieView

@synthesize movieSource;
@synthesize moviePlayerLayerAdded;
@synthesize movieScheduledForRemoval;
@synthesize closeButton;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        // Initialization code
		movieSource = nil;
		moviePlayerLayerAdded = false;
		movieScheduledForRemoval = false;
		closeButton = nil;
    }
    return self;
}

- (void)dealloc
{
	[movieSource release];
	[closeButton release];
    [super dealloc];
}

- (bool) displayMovieSource:(BasePadVideoSource *)source
{	
	// Remove any existing movie from this view
	if(moviePlayerLayerAdded)
		[self removeMovieFromView];
		
	// If the movie is not attached to a player in this source, do it
	if(![source movieAttached])
		[source attachMovie];
	
	// Then add that player to this movie view
	AVPlayerLayer * moviePlayerLayer = [source moviePlayerLayer];
	
	if(moviePlayerLayer && !moviePlayerLayerAdded)
	{
		CALayer *superlayer = self.layer;
		
		[moviePlayerLayer setFrame:self.bounds];
		[superlayer addSublayer:moviePlayerLayer];
		
		[self setMoviePlayerLayerAdded:true];
		[self setMovieSource:source];
		
		[source setParentMovieView:self];

		
		[source setMovieDisplayed:true];
		
		float currentTime = [[BasePadCoordinator Instance] currentPlayTime];
		[source movieGotoTime:currentTime];
		
		if([[BasePadCoordinator Instance] playing])
		{
			[source moviePlay];
		}
		
		if(closeButton)
		{
			[self bringSubviewToFront:closeButton];
		}
		
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
		
		[movieSource setParentMovieView:nil];

		[movieSource movieStop];
		[movieSource setMovieDisplayed:false];
		
		if(![movieSource shouldAutoDisplay])
			[movieSource detachMovie];
	}
	
	moviePlayerLayerAdded = false;
	movieScheduledForRemoval = false;
	
	[movieSource release];
	movieSource = nil;
	
}

- (void) resizeMovieSourceWithDuration:(float)duration
{	
	if(!movieSource || !moviePlayerLayerAdded)
		return;
	
	AVPlayerLayer * moviePlayerLayer = [movieSource moviePlayerLayer];
	
	if(moviePlayerLayer)
	{
		[CATransaction begin];
		[CATransaction setAnimationDuration:duration];
		[(CALayer *)moviePlayerLayer setFrame:[self bounds]];
		[CATransaction commit];
	}
}

-(void)notifyErrorOnVideoSource:(BasePadVideoSource *)videoSource withError:(NSString *)error
{
}

- (void)RequestRedraw
{
}

- (void)RequestRedrawInRect:(CGRect)rect
{
}

@end
