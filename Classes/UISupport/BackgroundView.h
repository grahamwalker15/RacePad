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
	BG_STYLE_FULL_SCREEN_GREY_,
	BG_STYLE_FULL_SCREEN_GRASS_,
	BG_STYLE_TRANSPARENT_,
	BG_STYLE_SHADOWED_GREY_
} ;

@interface BackgroundView : DrawingView
{
	int style;
	int inset;
}

@property (nonatomic) int style;
@property (nonatomic, readonly) int inset;

- (void)InitialiseImages;

@end

