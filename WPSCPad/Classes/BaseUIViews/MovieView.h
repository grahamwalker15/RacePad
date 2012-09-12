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

enum MovieViewTitleDisplays
{
	MV_CLOSE_AND_AUDIO,
	MV_CLOSE_NO_AUDIO,
	MV_NO_CLOSE_NO_AUDIO
} ;

@class MovieView;

@protocol MovieViewDelegate
- (void)notifyMovieAttachedToView:(MovieView *)movieView;
- (void)notifyMovieReadyToPlayInView:(MovieView *)movieView;
@end

@interface MovieView : BackgroundView
{
	BasePadVideoSource * movieSource;
	BasePadVideoSource * pendingMovieSource; // Used to restore a previous view
	
	bool moviePlayerLayerAdded;
	bool movieScheduledForDisplay;
	bool movieScheduledForRemoval;

	UIView * titleView;
	UIImageView * titleBackgroundImage;

	UIImageView * audioImage;
	UIButton * closeButton;
	
	UIButton * movieNameButton;
	UIButton * movieTypeButton;
	
	IBOutlet UILabel * loadingLabel;
	IBOutlet UIActivityIndicatorView * loadingTwirl;	
	IBOutlet UILabel * errorLabel;
	IBOutlet UIImageView * loadingScreen;
	
	int labelAlignment;
	bool shouldShowLabels;
	
	bool live;
	
	id movieViewDelegate;
}

@property (nonatomic, retain) id movieViewDelegate;

@property (nonatomic, retain) BasePadVideoSource * movieSource;
@property (nonatomic) bool moviePlayerLayerAdded;
@property (nonatomic) bool movieScheduledForDisplay;
@property (nonatomic) bool movieScheduledForRemoval;
@property (nonatomic, retain) UIView * titleView;
@property (nonatomic, retain) UIImageView * titleBackgroundImage;
@property (nonatomic, retain) UIImageView * audioImage;
@property (nonatomic, retain) UIButton * closeButton;
@property (nonatomic, retain) UIButton * movieNameButton;
@property (nonatomic, retain) UIButton * movieTypeButton;
@property (nonatomic, retain) UILabel * loadingLabel;
@property (nonatomic, retain) UIActivityIndicatorView * loadingTwirl;	
@property (nonatomic, retain) UIImageView * loadingScreen;
@property (nonatomic, retain) UILabel * errorLabel;

@property (nonatomic) int labelAlignment;
@property (nonatomic) bool shouldShowLabels;
@property (nonatomic) bool live;

// Manage displayed movies
- (bool) displayMovieSource:(BasePadVideoSource *)source;
- (void) redisplayMovieSource;

- (bool) movieSourceAssociated;

- (void) storeMovieSource;
- (void) restoreMovieSource;
- (void) clearMovieSourceStore;

- (void) notifyMovieAboutToShowSource:(BasePadVideoSource *)source;
- (void) notifyMovieAttachedToSource:(BasePadVideoSource *)source;
- (void) notifyMovieSourceReadyToPlay:(BasePadVideoSource *)source;

- (void) removeMovieFromView;
- (void) resizeMovieSourceAnimated:(bool)animated WithDuration:(float)duration;

- (void) showMovieLabels:(int)titleStyle;
- (void) hideMovieLabels;

- (void) showMovieLoading;
- (void) hideMovieLoading;

- (void) showMovieError;
- (void) hideMovieError;

-(void)notifyErrorOnVideoSource:(BasePadVideoSource *)videoSource withError:(NSString *)error;
-(void)notifyInfoOnVideoSource:(BasePadVideoSource *)videoSource withMessage:(NSString *)message;

// Request a redraw on next cycle
- (void)RequestRedraw;
- (void)RequestRedrawInRect:(CGRect)rect;

@end
