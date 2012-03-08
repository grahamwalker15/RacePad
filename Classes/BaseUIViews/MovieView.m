//
//  MovieView.m
//  RacePad
//
//  Created by Gareth Griffith on 10/31/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "MovieView.h"
#import "BasePadMedia.h"
#import "BasePadCoordinator.h"

@implementation MovieView

@synthesize movieViewDelegate;

@synthesize movieSource;
@synthesize moviePlayerLayerAdded;
@synthesize movieScheduledForDisplay;
@synthesize movieScheduledForRemoval;
@synthesize closeButton;

@synthesize loadingLabel;
@synthesize loadingTwirl;	
@synthesize loadingScreen;	
@synthesize errorLabel;

@synthesize driverNameButton;
@synthesize movieTypeButton;
@synthesize labelAlignment;
@synthesize shouldShowLabels;

@synthesize live;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        // Initialization code
		movieSource = nil;
		moviePlayerLayerAdded = false;
		movieScheduledForDisplay = false;
		movieScheduledForRemoval = false;
		closeButton = nil;
		loadingTwirl = nil;
		loadingLabel = nil;
		loadingScreen = nil;
		errorLabel = nil;
		
		shouldShowLabels = false;
		labelAlignment = MV_ALIGN_TOP;
		
		driverNameButton = nil;
		movieTypeButton = nil;
		
		live = false;
		
		movieViewDelegate = nil;
    }
    return self;
}

- (void)dealloc
{
	[movieViewDelegate release];
	
	[movieSource release];
	[closeButton release];
	[driverNameButton release];
	[movieTypeButton release];
	[loadingTwirl release];
	[loadingScreen release];
	[loadingLabel release];
	[errorLabel release];
	
    [super dealloc];
}

- (bool) displayMovieSource:(BasePadVideoSource *)source
{	
	// Remove any existing movie from this view
	if(moviePlayerLayerAdded)
		[self removeMovieFromView];
	
	// Now mark ourselves as ready to display
	movieScheduledForDisplay = true;
	
	// If the movie is not attached to a player in this source, do it and wait for notification
	// Otherwise we'll notify ourselves that it is attached
	if(![source movieLoaded])
	{
		[[BasePadMedia Instance] queueMovieLoad:source IntoView:self];
	}
	else
	{
		if(![source movieAttached])
			[source attachMovie];
		
		// Notify ourselves that it's done
		[self notifyMovieAttachedToSource:source];
	}
	
	return true;
}

- (void) redisplayMovieSource
{
	if(movieSource)
		[self displayMovieSource:movieSource];
}

- (bool) movieSourceAssociated
{
	return (moviePlayerLayerAdded || movieScheduledForDisplay);
}

- (void) notifyMovieAboutToShowSource:(BasePadVideoSource *)source
{
	// Show the loading indicator if we're loading a remote movie
	if(source && [source movieType] != MOVIE_TYPE_ARCHIVE_)
		[self showMovieLoading];
	
	// Hide the error
	[self hideMovieError];
}

- (void) notifyMovieAttachedToSource:(BasePadVideoSource *)source
{	
	// Set the movieas active
	[source setMovieActive:true];
	
	// Add the source's player layer to this movie view
	AVPlayerLayer * moviePlayerLayer = [source moviePlayerLayer];
	
	if(moviePlayerLayer && !moviePlayerLayerAdded)
	{
		CALayer *superlayer = self.layer;
		
		[moviePlayerLayer setFrame:self.bounds];
		[superlayer addSublayer:moviePlayerLayer];
		
		[self setMoviePlayerLayerAdded:true];
		[self setMovieScheduledForDisplay:false];
		[self setMovieSource:source];
		
		[source setParentMovieView:self];
		
		[source setMovieDisplayed:true];
		
		float currentTime = [[BasePadCoordinator Instance] currentPlayTime];
		[source movieGotoTime:currentTime];
		
		if([[BasePadCoordinator Instance] playing])
			[source moviePlay];
		else
			[source movieStop];
		
		if(closeButton)
			[self bringSubviewToFront:closeButton];
		
		if(driverNameButton)
			[self bringSubviewToFront:driverNameButton];
		
		if(movieTypeButton)
			[self bringSubviewToFront:movieTypeButton];
		
		// Tell the delegate that we've done it
		if(movieViewDelegate)
			[movieViewDelegate notifyMovieAttachedToView:self];
		
		// Get rid of loading screen
		//if(loadingScreen)
		//	[loadingScreen setHidden:true];
		
		// And keep the loading and error stuff visible if it's there
		if(loadingTwirl)
			[self bringSubviewToFront:loadingTwirl];
		if(loadingLabel)
			[self bringSubviewToFront:loadingLabel];
		if(errorLabel)
			[self bringSubviewToFront:errorLabel];
	}
}

- (void) notifyMovieSourceReadyToPlay:(BasePadVideoSource *)source
{	
	// Remove the loading indicators
	[self hideMovieLoading];
	
	// Tell the delegate that we're ready
	if(movieViewDelegate)
		[movieViewDelegate notifyMovieReadyToPlayInView:self];
}

- (void)removeMovieFromView
{
	if(moviePlayerLayerAdded && movieSource)
	{
		AVPlayerLayer * moviePlayerLayer = [movieSource moviePlayerLayer];
		if(moviePlayerLayer)
			[moviePlayerLayer removeFromSuperlayer];
		
		moviePlayerLayerAdded = false;
		movieScheduledForDisplay = false;
		movieScheduledForRemoval = false;
		
		[movieSource setParentMovieView:nil];
		
		[movieSource movieStop];
		[movieSource setMovieDisplayed:false];
		
		if(![movieSource shouldAutoDisplay])
		{
			if([movieSource movieType] == MOVIE_TYPE_VOD_STREAM_)
				[movieSource unloadMovie];
			else
				[movieSource detachMovie];
		}
	}
	
	moviePlayerLayerAdded = false;
	movieScheduledForDisplay = false;
	movieScheduledForRemoval = false;
	
	[movieSource release];
	movieSource = nil;
	
}

- (void) resizeMovieSourceAnimated:(bool)animated WithDuration:(float)duration
{	
	if(!movieSource || !moviePlayerLayerAdded)
		return;
	
	AVPlayerLayer * moviePlayerLayer = [movieSource moviePlayerLayer];
	
	if(moviePlayerLayer)
	{
		if(animated)
		{
			[CATransaction begin];
			[CATransaction setAnimationDuration:duration];
		}
		
		[(CALayer *)moviePlayerLayer setFrame:[self bounds]];
		
		if(animated)
		{
			[CATransaction commit];
		}
	}
}

-(void)notifyErrorOnVideoSource:(BasePadVideoSource *)videoSource withError:(NSString *)error
{
	[self hideMovieLoading];
	
	if(errorLabel)
	{
		if(error)
			[errorLabel setText:error];
		else
			[errorLabel setText:@"Unknown error"];
		
		[self showMovieError];
	}
}

-(void)notifyInfoOnVideoSource:(BasePadVideoSource *)videoSource withMessage:(NSString *)message
{
	[self hideMovieLoading];
	
	if(errorLabel)
	{
		[errorLabel setText:message];
		[self showMovieError];
	}
}


- (void)RequestRedraw
{
}

- (void)RequestRedrawInRect:(CGRect)rect
{
}

- (void) showMovieLabels
{
	if(!movieSource || !driverNameButton || !movieTypeButton)
		return;
	
	[driverNameButton setAlpha:0.0];
	[driverNameButton setHidden:false];
	
	[movieTypeButton setAlpha:0.0];
	[movieTypeButton setHidden:false];
	
	[driverNameButton setTitle:[movieSource movieName] forState:UIControlStateNormal];
	
	if(live)
		[movieTypeButton setTitle:@"LIVE" forState:UIControlStateNormal];
	else
		[movieTypeButton setTitle:@"REPLAY" forState:UIControlStateNormal];
	
	CGRect ourBounds = [self bounds];
	CGRect driverNameBounds = [driverNameButton bounds];
	CGRect movieTypeBounds = [movieTypeButton bounds];
	
	if(labelAlignment == MV_ALIGN_TOP)
	{
		[movieTypeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
		[driverNameButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
		
		float ytop = ourBounds.origin.y - 2;
		[movieTypeButton setFrame:CGRectMake(ourBounds.origin.x + 5, ytop - movieTypeBounds.size.height, movieTypeBounds.size.width, movieTypeBounds.size.height)];
		ytop -= movieTypeBounds.size.height;
		[driverNameButton setFrame:CGRectMake(ourBounds.origin.x + 5, ytop - driverNameBounds.size.height, driverNameBounds.size.width, driverNameBounds.size.height)];
	}
	else
	{
		[movieTypeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
		[driverNameButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
		
		float ytop = ourBounds.origin.y;
		[driverNameButton setFrame:CGRectMake(ourBounds.origin.x - driverNameBounds.size.width - 3, ytop, driverNameBounds.size.width, driverNameBounds.size.height)];
		ytop += driverNameBounds.size.height;
		[movieTypeButton setFrame:CGRectMake(ourBounds.origin.x - movieTypeBounds.size.width - 3, ytop, movieTypeBounds.size.width, movieTypeBounds.size.height)];
	}
	
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
	
	[driverNameButton setAlpha:1.0];
	[movieTypeButton setAlpha:1.0];
	
	[UIView commitAnimations];
}

- (void) hideMovieLabels
{
	if(!driverNameButton || !movieTypeButton)
		return;
	
	[driverNameButton setHidden:true];
	[movieTypeButton setHidden:true];
}

- (void) showMovieLoading
{
	if(loadingScreen)
		[loadingScreen setHidden:false];
	
	if(loadingTwirl)
	{
		[loadingTwirl setHidden:false];
		[loadingTwirl startAnimating];
	}
	
	if(loadingLabel)
		[loadingLabel setHidden:false];
	
	
}

- (void) hideMovieLoading
{
	if(loadingTwirl)
	{
		[loadingTwirl setHidden:true];
		[loadingTwirl stopAnimating];
	}
	
	if(loadingLabel)
		[loadingLabel setHidden:true];
	
	if(loadingScreen)
		[loadingScreen setHidden:true];
	
}

- (void) showMovieError
{
	if(errorLabel)
		[errorLabel setHidden:false];
}

- (void) hideMovieError
{
	if(errorLabel)
		[errorLabel setHidden:true];
}


@end
