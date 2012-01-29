//
//  MovieView.h
//  RacePad
//
//  Created by Gareth Griffith on 10/31/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BackgroundView.h"
#import "BasePadVideoSource.h"

enum MovieViewAnimationDirections
{
	MV_CURRENT_POSITION,
	MV_MOVIE_FROM_RIGHT,
	MV_MOVIE_FROM_LEFT,
	MV_MOVIE_FROM_TOP,
	MV_MOVIE_FROM_BOTTOM,
} ;

@interface MovieView : BackgroundView
{
	BasePadVideoSource * movieSource;
	bool moviePlayerLayerAdded;
	bool movieScheduledForRemoval;
	UIButton * closeButton;
}

@property (nonatomic, retain) BasePadVideoSource * movieSource;
@property (nonatomic) bool moviePlayerLayerAdded;
@property (nonatomic) bool movieScheduledForRemoval;
@property (nonatomic, retain) UIButton * closeButton;

// Manage displayed movies
- (bool) displayMovieSource:(BasePadVideoSource *)source;
- (void) removeMovieFromView;
- (void) resizeMovieSourceWithDuration:(float)duration;

-(void)notifyErrorOnVideoSource:(BasePadVideoSource *)videoSource withError:(NSString *)error;

// Request a redraw on next cycle
- (void)RequestRedraw;
- (void)RequestRedrawInRect:(CGRect)rect;

@end
