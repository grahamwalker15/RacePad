//
//  BasePadVideoViewController.h
//  BasePad
//
//  Created by Gareth Griffith on 5/6/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadViewController.h"

@class BasePadVideoSource;
@class MovieView;

@interface BasePadVideoViewController : BasePadViewController
{
	IBOutlet UILabel * loadingLabel;
	IBOutlet UIActivityIndicatorView * loadingTwirl;	
	IBOutlet UILabel * videoDelayLabel;
}

- (void) showLoadingIndicators;
- (void) hideLoadingIndicators;

- (MovieView *) firstMovieView;

- (void) displayMovieSource:(BasePadVideoSource *)source;
- (void) removeMovieFromView:(BasePadVideoSource *)source;
- (void) removeMoviesFromView;

- (void) notifyMovieInformation;

@end
