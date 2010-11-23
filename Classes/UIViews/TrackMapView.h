//
//  TrackMapView.h
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawingView.h"

@interface TrackMapView : DrawingView
{
	bool isZoomView;
	
	float userXOffset;
	float userYOffset;	
	float userScale;
	
	NSString * carToFollow;
}

@property (nonatomic) bool isZoomView;

@property (nonatomic) float userXOffset;
@property (nonatomic) float userYOffset;
@property (nonatomic) float userScale;

@property (nonatomic, retain) NSString * carToFollow;

- (void)InitialiseMembers;
- (void)InitialiseImages;
- (void)followCar:(NSString *)name;

@end

