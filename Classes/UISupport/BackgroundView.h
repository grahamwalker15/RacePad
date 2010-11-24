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
	BG_STYLE_TRANSPARENT_
} ;

#define BG_INSET 20

@interface BackgroundView : DrawingView
{
	int style;
}

@property (nonatomic) int style;

- (void)InitialiseImages;

@end

