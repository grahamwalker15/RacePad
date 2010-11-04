//
//  TrackMapView.h
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawingView.h"

@interface TrackMapBackgroundView : DrawingView
{
	CGImageRef background_image_;
	int background_image_w_;
	int background_image_h_;
}

- (void)InitialiseImages;

- (void)ReleaseBackground;

@end

@interface TrackMapView : DrawingView
{

}

@end

