//
//  BackgroundView.h
//  RacePad
//
//  Created by Gareth Griffith on 11/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawingView.h"

enum BackgroundStyles
{
	BG_STYLE_FULL_SCREEN_CARBON_,
	BG_STYLE_FULL_SCREEN_GREY_,
	BG_STYLE_FULL_SCREEN_GRASS_,
	BG_STYLE_MIDAS_,
	BG_STYLE_TRANSPARENT_,
	BG_STYLE_INVISIBLE_,
	BG_STYLE_SHADOWED_GREY_,
	BG_STYLE_ROUNDED_STRAP_,
} ;

@interface BackgroundView : DrawingView
{
	int style;
	int inset;
	
	NSMutableArray * frames;	// An array of CGRects (wrapped in NSValue) which need to be drawn in outline
}

@property (nonatomic) int style;
@property (nonatomic, readonly) int inset;

- (void)InitialiseImages;

- (void)drawFrames;
- (void)drawOutline:(CGRect) rect;

- (void)clearFrames;
- (void)addFrame:(CGRect) rect;

@end

