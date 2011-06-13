//
//  MovieView.h
//  RacePad
//
//  Created by Gareth Griffith on 10/31/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "BackgroundView.h"


@interface MovieView : BackgroundView
{
	MPMoviePlayerController * moviePlayer;
}

@property (nonatomic, retain) MPMoviePlayerController * moviePlayer;

// Request a redraw on next cycle
- (void)RequestRedraw;
- (void)RequestRedrawInRect:(CGRect)rect;

@end
