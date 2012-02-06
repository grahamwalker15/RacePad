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

enum MovieViewButtonAlignments
{
	MV_ALIGN_TOP,
	MV_ALIGN_LEFT,
} ;

@class MovieView;

@protocol MovieViewDelegate
- (void)notifyMovieAttachedToView:(MovieView *)movieView;
@end

@interface MovieView : BackgroundView
{
	BasePadVideoSource * movieSource;
	bool moviePlayerLayerAdded;
	bool movieScheduledForRemoval;
	UIButton * closeButton;
	
	UIButton * driverNameButton;
	UIButton * movieTypeButton;
	int labelAlignment;
	bool shouldShowLabels;
	
	bool live;
	
	id movieViewDelegate;
}

@property (nonatomic, retain) id movieViewDelegate;

@property (nonatomic, retain) BasePadVideoSource * movieSource;
@property (nonatomic) bool moviePlayerLayerAdded;
@property (nonatomic) bool movieScheduledForRemoval;
@property (nonatomic, retain) UIButton * closeButton;
@property (nonatomic, retain) UIButton * driverNameButton;
@property (nonatomic, retain) UIButton * movieTypeButton;
@property (nonatomic) int labelAlignment;
@property (nonatomic) bool shouldShowLabels;
@property (nonatomic) bool live;

// Manage displayed movies
- (bool) displayMovieSource:(BasePadVideoSource *)source;
- (void) notifyMovieAttachedToSource:(BasePadVideoSource *)source;
- (void) removeMovieFromView;
- (void) resizeMovieSourceWithDuration:(float)duration;

- (void) showMovieLabels;
- (void) hideMovieLabels;

-(void)notifyErrorOnVideoSource:(BasePadVideoSource *)videoSource withError:(NSString *)error;

// Request a redraw on next cycle
- (void)RequestRedraw;
- (void)RequestRedrawInRect:(CGRect)rect;

@end
