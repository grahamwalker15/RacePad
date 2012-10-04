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

#import "TestFlight.h"

@implementation MovieView

@synthesize movieViewDelegate;

@synthesize movieSource;
@synthesize moviePlayerLayerAdded;
@synthesize movieScheduledForDisplay;
@synthesize movieScheduledForRemoval;
@synthesize movieSourceCached;

@synthesize closeButton;

@synthesize loadingLabel;
@synthesize loadingTwirl;	
@synthesize loadingScreen;	
@synthesize errorLabel;

@synthesize titleView;
@synthesize titleBackgroundImage;
@synthesize audioImage;
@synthesize movieNameButton;
@synthesize movieTypeButton;
@synthesize labelAlignment;
@synthesize shouldShowLabels;

@synthesize live;
@synthesize muted;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        // Initialization code
		movieSource = nil;
		moviePlayerLayerAdded = false;
		movieScheduledForDisplay = false;
		movieScheduledForRemoval = false;
        movieSourceCached = false;
		closeButton = nil;
		loadingTwirl = nil;
		loadingLabel = nil;
		loadingScreen = nil;
		errorLabel = nil;
		
		shouldShowLabels = false;
		
		titleView = nil;
		titleBackgroundImage = nil;
		
		movieNameButton = nil;
		movieTypeButton = nil;
		audioImage = nil;
		
		live = false;
        muted = false;
		
		movieViewDelegate = nil;
    }
    return self;
}

- (void)dealloc
{
	[movieViewDelegate release];
	
	[movieSource release];
	[closeButton release];
	[movieNameButton release];
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
    
    // Set the movie type
	
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

- (void) setAudioMuted:(bool)value
{
    muted = value;
	if(movieSource  && [movieSource movieLoaded])
        [movieSource movieSetMuted:muted];
}

- (bool) movieSourceAssociated
{
	return (moviePlayerLayerAdded || movieScheduledForDisplay);
}

- (void) storeMovieSource
{
	[self clearMovieSourceStore];
	
	if(movieSource)
		pendingMovieSource = [movieSource retain];
    
    movieSourceCached = true;
}

- (void) restoreMovieSource
{
	if(movieSourceCached || pendingMovieSource)
	{
        if(!movieSourceCached)
        {
            [self setMovieViewDelegate:nil];
            [self displayMovieSource:pendingMovieSource];
        }

		[pendingMovieSource release];
		pendingMovieSource = nil;
        
        movieSourceCached = false;
        movieScheduledForRemoval = false;
	}
}

- (void) clearMovieSourceStore
{
    if(movieSourceCached)
        [self removeMovieFromView];
        
    movieSourceCached = false;
    
	if(pendingMovieSource)
	{
		[pendingMovieSource release];
		pendingMovieSource = nil;
	}
}

- (void) notifyMovieAboutToShowSource:(BasePadVideoSource *)source
{
	// Show the loading indicator if we're loading a remote movie
	if(source && [source movieType] != MOVIE_TYPE_ARCHIVE_)
		[self showMovieLoading];
	
    [self setMovieSource:source];

	// Hide the error
	[self hideMovieError];
}

- (void) notifyMovieAttachedToSource:(BasePadVideoSource *)source
{	
    [self setMovieSource:source];
    
	// Set the movie as active
	[source activateMovie];
	
	// Add the source's player layer to this movie view
	AVPlayerLayer * moviePlayerLayer = [source moviePlayerLayer];
	
	if(moviePlayerLayer && !moviePlayerLayerAdded)
	{
		CALayer *superlayer = self.layer;
		
		[superlayer addSublayer:moviePlayerLayer];
		[moviePlayerLayer setFrame:self.bounds];
		
		[self setMoviePlayerLayerAdded:true];
		[self setMovieScheduledForDisplay:false];
		
		[source setParentMovieView:self];
		
		[source setMovieDisplayed:true];

		if(titleView)
			[self bringSubviewToFront:titleView];
				
		// Tell the delegate that we've done it
		if(movieViewDelegate)
			[movieViewDelegate notifyMovieAttachedToView:self];
		
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

    [source movieSetMuted:muted];
    
    if([[BasePadCoordinator Instance] liveMode])
    {
        [source moviePrepareToPlayLive];
    }
    else
    {
        float currentTime = [[BasePadCoordinator Instance] currentPlayTime];
        [source movieGotoTime:currentTime];
    }
    
    if([source movieForceLive] || [[BasePadCoordinator Instance] playing])
        [source moviePlay];
    else
        [source movieStop];
    
	// Tell the delegate that we're ready
	if(movieViewDelegate)
		[movieViewDelegate notifyMovieReadyToPlayInView:self];
    
    if(titleView)
    {
        [self bringSubviewToFront:titleView];
        [self updateMovieLabels];
    }
    
    TFLog(@"play done: %@", [source movieName]);

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
			if([movieSource movieType] == MOVIE_TYPE_ARCHIVE_)
				[movieSource detachMovie];
			else
				[movieSource unloadMovie];
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
		[errorLabel setText:error];
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

- (void) showMovieLabels:(int)requestedTitleStyle;
{
	if(!movieSource || !titleView || !titleBackgroundImage || !movieNameButton || !movieTypeButton)
		return;
    
    titleStyle = requestedTitleStyle;
	
	[titleView setAlpha:0.0];
	[titleView setHidden:false];
	
    [self updateMovieLabels];
    			
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
	
	[titleView setAlpha:1.0];
	
	[UIView commitAnimations];
}

- (void) hideMovieLabels
{
	if(!titleView)
		return;
	
	[titleView setHidden:true];
}

- (void) updateMovieLabels
{
	if(!movieSource || !titleView || !titleBackgroundImage || !movieNameButton || !movieTypeButton)
		return;
	
	float xRight = CGRectGetMaxX([titleView bounds]);
	
	if(titleStyle == MV_CLOSE_AND_AUDIO)
	{
		[titleBackgroundImage setImage:[UIImage imageNamed:@"videoTitleOverlayFull.png"]];
		[movieNameButton setFrame:CGRectMake(xRight - 190, 0, 115, 16)];
		[movieTypeButton setFrame:CGRectMake(xRight - 190, 16, 115, 16)];
		[audioImage setHidden:false];
	}
	else if(titleStyle == MV_CLOSE_NO_AUDIO)
	{
		[titleBackgroundImage setImage:[UIImage imageNamed:@"videoTitleOverlayNoAudio.png"]];
		[movieNameButton setFrame:CGRectMake(xRight - 160, 0, 115, 16)];
		[movieTypeButton setFrame:CGRectMake(xRight - 160, 16, 115, 16)];
		[audioImage setHidden:true];
	}
	else if(titleStyle == MV_NO_CLOSE_NO_AUDIO)
	{
		[titleBackgroundImage setImage:[UIImage imageNamed:@"videoTitleOverlayNoClose.png"]];
		[movieNameButton setFrame:CGRectMake(xRight - 125, 0, 115, 16)];
		[movieTypeButton setFrame:CGRectMake(xRight - 125, 16, 115, 16)];
		[audioImage setHidden:true];
	}
	
	[movieNameButton setTitle:[movieSource movieName] forState:UIControlStateNormal];
	
    live = [movieSource movieForceLive] ? true : [[BasePadCoordinator Instance] liveMode];
	
	if(live)
		[movieTypeButton setTitle:@"LIVE" forState:UIControlStateNormal];
	else
		[movieTypeButton setTitle:@"REPLAY" forState:UIControlStateNormal];
    
    [movieTypeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [movieNameButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
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
