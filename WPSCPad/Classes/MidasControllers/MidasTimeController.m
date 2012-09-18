//
//  MidasTimeController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 9/17/12.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasTimeController.h"

#import "MidasVideoViewController.h"
#import "MidasPopupManager.h"

#import "RacePadCoordinator.h"
#import "BasePadMedia.h"
#import "BasePadVideoSource.h"
#import "MovieView.h"

@implementation MidasTimeController

static MidasTimeController * instance_ = nil;

+(MidasTimeController *)Instance
{
	if(!instance_)
		instance_ = [[MidasTimeController alloc] init];
	
	return instance_;
}

- (void)prepareForSliderAction
{
    // If we use the slider to switch out of live view, but only have a forced live view displayed, pop up a new video
    if ( true || [[BasePadCoordinator Instance] liveMode] )
    {
        if(parentController && [parentController isKindOfClass:[MidasVideoViewController class]])
        {
            MidasVideoViewController * videoViewController = (MidasVideoViewController *) parentController;
            
            int movieCount = [videoViewController countMovieViews];
            
            if(movieCount <= 1)
            {
                MovieView * mainMovieView = [videoViewController mainMovieView];
                
                if(mainMovieView && [mainMovieView movieSourceAssociated] && [mainMovieView movieSource] && [[mainMovieView movieSource] movieForceLive])
                {
                    BasePadVideoSource * videoSource = [[BasePadMedia Instance] findNextMovieForReview];
                
                    if(videoSource && ![videoSource movieDisplayed])
                    {
                        MovieView * auxMovieView = [videoViewController findFreeMovieView];
                        if(auxMovieView)
                        {
                            [videoViewController prepareToAnimateMovieViews:auxMovieView From:MV_MOVIE_FROM_BOTTOM];
                            [auxMovieView setMovieViewDelegate:self];
                            [auxMovieView displayMovieSource:videoSource]; // Will get notification below when finished
                            
                            [videoViewController animateMovieViews:auxMovieView From:MV_MOVIE_FROM_BOTTOM];
                            
                        }
                    }
                }
            }
        }
    }
}

- (void)notifyMovieAttachedToView:(MovieView *)movieView	// MovieViewDelegate method
{
}

- (void)notifyMovieReadyToPlayInView:(MovieView *)movieView	// MovieViewDelegate method
{
}

@end
