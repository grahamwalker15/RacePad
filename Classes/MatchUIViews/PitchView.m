//
//  PitchView.m
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "PitchView.h"
#import "BackgroundView.h"
#import "MatchPadDatabase.h"
#import "Pitch.h"


@implementation PitchView

@synthesize isZoomView;
@synthesize isOverlayView;
@synthesize smallSized;
@synthesize homeXOffset;
@synthesize homeYOffset;
@synthesize homeScaleX;
@synthesize homeScaleY;
@synthesize userXOffset;
@synthesize userYOffset;
@synthesize userScale;
@synthesize playerToFollow;
@synthesize isAnimating;
@synthesize animationScaleTarget;
@synthesize animationAlpha;
@synthesize animationDirection;
@synthesize autoRotate;
@synthesize showWholeMove;
@synthesize playerTrails;
@synthesize playerPos;
@synthesize passes;
@synthesize passNames;
@synthesize ballTrail;

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Super class overrides

//If the view is stored in the nib file,when it's unarchived it's sent -initWithCoder:

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
		[self InitialiseImages];
		[self InitialiseMembers];		
	}
	
    return self;
}

//If we create it ourselves, we use -initWithFrame:
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		[self InitialiseImages];
		[self InitialiseMembers];		
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
}

- (void)dealloc
{
	[playerToFollow release];
	playerToFollow = nil;
	
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Methods for this class 

- (void)InitialiseMembers
{
	userScale = 1.0;
	userXOffset = 0.0;
	userYOffset = 0.0;	
	
	isZoomView = false;
	isOverlayView = false;
	smallSized = false;
	
	isAnimating = false;
	animationDirection = 0;
	animationAlpha = 0.0;
	
	playerToFollow = nil;
	autoRotate = false;
	showWholeMove = false;
	
	playerTrails = true;
	playerPos = true;
	passes = true;
	passNames = true;
	
	pitchColour = [DrawingView CreateColourRed:118 Green:158 Blue:58];
	[self initialisePerspective];
}

- (void)InitialiseImages
{
}

- (float) interpolatedUserScale
{
	if(isAnimating)
		return ((1.0 - animationAlpha) * userScale + animationAlpha * animationScaleTarget);
	else
		return userScale;
}

- (void) followPlayer:(NSString *)name
{
	if(name && [name length] > 0)
	{
		if(![playerToFollow isEqualToString:name])
		{
			[playerToFollow release];
			playerToFollow = [name retain];
			return;
		}
		else
		{
			return;
		}

	}
	
	// Reach here if either name was nil, or not found
	[playerToFollow release];
	playerToFollow = nil;	
}

// Drawing routines

-(void) initialisePerspective
{
	float x3 = 0;
	float y3 = 1;
	float x2 = 1;
	float y2 = 1;
	float x1 = 0.8;
	float y1 = 0;
	float x0 = 0.2;
	float y0 = 0;
	
	float dx1 = x1-x2;
	float dy1 = y1-y2;
	float dx2 = x3-x2;
	float dy2 = y3-y2;
	float dx3 = x0-x1+x2-x3;
	float dy3 = y0-y1+y2-y3;
	
	if (dx3 == 0 && dy3 == 0) {
		a11 = x1-x0;
		a21 = x2-x1;
		a31 = x0;
		a12 = y1-y0;
		a22 = y2-y1;
		a32 = y0;
		a13 = a23 = 0;
	} else {
		a13 = (dx3*dy2-dx2*dy3)/(dx1*dy2-dy1*dx2);
		a23 = (dx1*dy3-dy1*dx3)/(dx1*dy2-dy1*dx2);
		a11 = x1-x0+a13*x1;
		a21 = x3-x0+a23*x3;
		a31 = x0;
		a12 = y1-y0+a13*y1;
		a22 = y3-y0+a23*y3;
		a32 = y0;
	}
}

- (void) transformPoint:(float *)x Y:(float *)y
{
	float f = 1.0f / (a13 * *x+ a23 * *y + 1);
	*x = (a11 * *x + a21 * *y + a31) * f;
	*y = (a12 * *x + a22 * *y + a32) * f;
}

- (void) viewLine: (float)x0 Y0:(float) y0 X1:(float)x1 Y1:(float) y1
{
	[self transformPoint:&x0 Y:&y0];
	[self transformPoint:&x1 Y:&y1];
	[self LineX0:x0 Y0:y0 X1:x1 Y1:y1];
}

- (void) viewSpot: (float)x0 Y0:(float) y0 LineScale:(float) lineScale
{
	[self transformPoint:&x0 Y:&y0];
	[self LineCircle:x0 Y0:y0 Radius:5/lineScale];
}

- (void) constructTransformMatrix:(float)x Y:(float)y Rotation:(float) rotation
{
	// Constructs the transform matrix, stores it, and leaves it current
	
	CGRect map_rect = [self bounds];
	
	CGSize viewSize = map_rect.size;
	
	float x_scale = homeScaleX;
	float y_scale = homeScaleY;
	float mapXOffset = homeXOffset;
	float mapYOffset = homeYOffset;
	
	//  And build the matrix
	[self ResetTransformMatrix];
	
	[self SetTranslateX:userXOffset * viewSize.width Y:userYOffset * viewSize.height];	
	[self SetTranslateX:mapXOffset Y:mapYOffset];
	[self SetScaleX:x_scale * [self interpolatedUserScale] Y:y_scale * userScale];
	[self SetRotationInDegrees:rotation];
	[self SetTranslateX:-x Y:-y];
	
	[self StoreTransformMatrix];	
}

- (void) constructTransformMatrix
{
	[self constructTransformMatrix:0 Y:-0 Rotation:0];
}

- (void) drawPitch: (float) xScale YScale: (float) yScale XOffset:(float) xOffset YOffset:(float) yOffset LineScale:(float)lineScale
{
	[self SaveGraphicsState];
	
	[self SetLineWidth:1.5/lineScale];
	[self SetFGColour: white_];
	// Edges
	[self viewLine:0 * xScale + xOffset Y0:0 * yScale + yOffset X1:0 * xScale + xOffset Y1:1 * yScale + yOffset];
	[self viewLine:0 * xScale + xOffset Y0:1 * yScale + yOffset X1:1 * xScale + xOffset Y1:1 * yScale + yOffset];
	[self viewLine:1 * xScale + xOffset Y0:1 * yScale + yOffset X1:1 * xScale + xOffset Y1:0 * yScale + yOffset];
	[self viewLine:1 * xScale + xOffset Y0:0 * yScale + yOffset X1:0 * xScale + xOffset Y1:0 * yScale + yOffset];
	
	// Centre Line
	[self viewLine:0.5 * xScale + xOffset Y0:0 * yScale + yOffset X1:0.5 * xScale + xOffset Y1:1 * yScale + yOffset];
	// Centre Circle
	// [view LineCircle:0.5 * xScale + xOffset Y0:0.5 * yScale + yOffset Radius:0.085 * xScale];
	// [view LineCircle:0.5 * xScale + xOffset Y0:0.5 * yScale + yOffset Radius:0.002 * xScale];
	
	// LH Penalty Area
	[self viewLine:0 * xScale + xOffset Y0:0.211 * yScale + yOffset X1:0.17 * xScale + xOffset Y1:0.211 * yScale + yOffset];
	[self viewLine:0.17 * xScale + xOffset Y0:0.211 * yScale + yOffset X1:0.17 * xScale + xOffset Y1:0.789 * yScale + yOffset];
	[self viewLine:0.17 * xScale + xOffset Y0:0.789 * yScale + yOffset X1:0 * xScale + xOffset Y1:0.789 * yScale + yOffset];
	// [view LineArc:0.115 * xScale + xOffset Y0:0.5 * yScale + yOffset StartAngle:DegreesToRadians(45) EndAngle:DegreesToRadians(315) Clockwise:true Radius:0.077 * xScale];
	// LH Goal Area
	[self viewLine:0 * xScale + xOffset Y0:0.368 * yScale + yOffset X1:0.058 * xScale + xOffset Y1:0.368 * yScale + yOffset];
	[self viewLine:0.058 * xScale + xOffset Y0:0.368 * yScale + yOffset X1:0.058 * xScale + xOffset Y1:0.632 * yScale + yOffset];
	[self viewLine:0.058 * xScale + xOffset Y0:0.632 * yScale + yOffset X1:0 * xScale + xOffset Y1:0.632 * yScale + yOffset];
	
	// RH Penalty Area
	[self viewLine:1 * xScale + xOffset Y0:0.211 * yScale + yOffset X1:0.83 * xScale + xOffset Y1:0.211 * yScale + yOffset];
	[self viewLine:0.83 * xScale + xOffset Y0:0.211 * yScale + yOffset X1:0.83 * xScale + xOffset Y1:0.789 * yScale + yOffset];
	[self viewLine:0.83 * xScale + xOffset Y0:0.789 * yScale + yOffset X1:1 * xScale + xOffset Y1:0.789 * yScale + yOffset];
	// [view LineArc:0.885 * xScale + xOffset Y0:0.5 * yScale + yOffset StartAngle:DegreesToRadians(135) EndAngle:DegreesToRadians(225) Clockwise:false Radius:0.077 * xScale];
	// RH Goal Area
	[self viewLine:1 * xScale + xOffset Y0:0.368 * yScale + yOffset X1:0.942 * xScale + xOffset Y1:0.368 * yScale + yOffset];
	[self viewLine:0.942 * xScale + xOffset Y0:0.368 * yScale + yOffset X1:0.942 * xScale + xOffset Y1:0.632 * yScale + yOffset];
	[self viewLine:0.942 * xScale + xOffset Y0:0.632 * yScale + yOffset X1:1 * xScale + xOffset Y1:0.632 * yScale + yOffset];
	
	[self SetLineWidth:3/lineScale];
	// LH Goal
	[self viewLine:0 * xScale + xOffset Y0:0.442 * yScale + yOffset X1:0 * xScale + xOffset Y1:0.558 * yScale + yOffset];
	
	// RH Goal
	[self viewLine:1 * xScale + xOffset Y0:0.442 * yScale + yOffset X1:1 * xScale + xOffset Y1:0.558 * yScale + yOffset];
	
	[self RestoreGraphicsState];
}

- (void) initialiseTransformMatrix
{
	// Constructs the transform matrix, stores it, and leaves it current
	
	// Get dimensions of current view
	CGRect map_rect = [self bounds];
	
	CGSize viewSize = map_rect.size;
	
	// Make the map as big as possible in the rectangle
	// The pitch is inset 25 pixels all round
	float x_scale = viewSize.width - 50;
	float y_scale = viewSize.height - 50;
	
	float mapXOffset, mapYOffset;
	
	
	// If it is an overlay view, we move it to the right. Otherwise centre.
	/*
	 if([view isOverlayView])
	 {
	 x_scale = x_scale * 0.7;
	 y_scale = y_scale * 0.7;
	 mapXOffset = viewSize.width - width * 0.5 * x_scale - 55 ;
	 mapYOffset = viewSize.height * 0.5 + yCentre  ;
	 }
	 else
	 {
	 x_scale = x_scale * 0.9;
	 y_scale = y_scale * 0.9;
	 mapXOffset = viewSize.width * 0.5 - xCentre  ;
	 mapYOffset = viewSize.height * 0.5 + yCentre ;
	 }
	 */
	mapXOffset = 25;
	mapYOffset = 25;
	
	[self setHomeScaleX:x_scale];
	[self setHomeScaleY:y_scale];
	[self setHomeXOffset:mapXOffset];
	[self setHomeYOffset:mapYOffset];
}

- (void)Draw:(CGRect) rect
{
	[self ClearScreen];
	[self SaveGraphicsState];
	
	CGRect map_rect = [self bounds];
	
	CGSize viewSize = map_rect.size;
	
	[self initialiseTransformMatrix];
	
	float x_scale = homeScaleX * [self interpolatedUserScale]; // Usually just userScale unless animating
	float y_scale = homeScaleY * [self interpolatedUserScale]; // Usually just userScale unless animating
	float xOffset = homeXOffset + userXOffset * viewSize.width;
	float yOffset = homeYOffset + userYOffset * viewSize.height;
	
	float x[4], y[4];
	x[0] = -0.1;
	y[0] = -0.1;
	x[1] = -0.1;
	y[1] = 1.1;
	x[2] = 1.1;
	y[2] = 1.1;
	x[3] = 1.1;
	y[3] = -0.1;
	for ( int i = 0; i < 4; i++ )
	{
		[self transformPoint:x+i Y:y+i];
		x[i] = x[i] * x_scale + xOffset;
		y[i] = y[i] * y_scale + yOffset;
	}
	
	CGMutablePathRef path = CGPathCreateMutable();
	
	CGPathMoveToPoint (path, nil, (CGFloat)x[0], (CGFloat)y[0]);
	
	for ( int i = 1 ; i < 4 ; i++)
		CGPathAddLineToPoint (path, nil, (CGFloat)x[i], (CGFloat)y[i]);
	
	[self SetBGColour:pitchColour];
	[self FillPath:path];
	
	CGPathRelease(path);
	
	// Draw pitch outline in un-scaled space - because of the circles!
	// [self drawLines:view XScale:x_scale YScale:y_scale XOffset:xOffset YOffset:yOffset];
	
	[self constructTransformMatrix];
	
	float scale = x_scale > y_scale ? x_scale : y_scale;
	[self drawPitch:1 YScale:1 XOffset:0 YOffset:0 LineScale:scale];
	[self RestoreGraphicsState];
	
	MatchPadDatabase *database = [MatchPadDatabase Instance];
	Positions *positions = [database positions];
	if ( positions )
	{
		if ( playerTrails )
			[positions drawTrailsInView:self Scale:scale XScale:x_scale YScale:y_scale];
		if ( ballTrail )
			[positions drawBallTrailInView:self Scale:scale XScale:x_scale YScale:y_scale];
		if ( playerPos )
			[positions drawPlayersInView:self Scale:scale XScale:x_scale YScale:y_scale];
	}
	
	Pitch *pitch = [database pitch];
	if ( pitch )
	{		
		[self SaveGraphicsState];
		[self constructTransformMatrix];
		if ( passes )
			[pitch drawPassesInView:self AllNames:showWholeMove Scale:scale XScale:x_scale YScale:y_scale];
		[self RestoreGraphicsState];
		if ( passNames )
			[pitch drawNamesInView:self AllNames:showWholeMove Scale:scale XScale:x_scale YScale:y_scale];
	}
	
}

- (void) adjustScale:(float)scale X:(float)x Y:(float)y
{
	// If we're following a car, we just set the scale
	// Otherwise we zoom so that the focus point stays at the same screen location
	if(isZoomView)
	{
		float currentUserScale = userScale;
		if(fabsf(currentUserScale) < 0.001 || fabsf(scale) < 0.001)
			return;
		
		[self setUserScale:currentUserScale * scale];
	}
	else
	{
		CGRect viewBounds = [self bounds];
		CGSize viewSize = viewBounds.size;
		
		if(viewSize.width < 1 || viewSize.height < 1)
			return;
		
		float currentUserPanX = userXOffset * viewSize.width;
		float currentUserPanY = userYOffset * viewSize.height;
		float currentUserScale = userScale;
		float currentMapPanX = homeXOffset;
		float currentMapPanY = homeYOffset;
		float currentMapScaleX = homeScaleX;
		float currentMapScaleY = homeScaleY;
		float currentScaleX = currentUserScale * currentMapScaleX;
		float currentScaleY = currentUserScale * currentMapScaleY;
		
		if(fabsf(currentScaleX) < 0.001 || fabsf(scale) < 0.001)
			return;
		if(fabsf(currentScaleY) < 0.001 || fabsf(scale) < 0.001)
			return;
		
		// Calculate where the centre point is in the untransformed map
		float x_in_map = (x - currentUserPanX - currentMapPanX) / currentScaleX; 
		float y_in_map = (y - currentUserPanY - currentMapPanY) / currentScaleY;
		
		// Now work out the new scale	
		float newScaleX = currentScaleX * scale;
		float newScaleY = currentScaleY * scale;
		float newUserScale = currentUserScale * scale;
		
		// Now work out where that point in the map would go now
		float new_x = (x_in_map) * newScaleX + currentMapPanX;
		float new_y = (y_in_map) * newScaleY + currentMapPanY;
		
		// Andset the user pan to put it back where it was on the screen
		float newPanX = (x - new_x) / viewSize.width ;
		float newPanY = (y - new_y) / viewSize.height;
		
		[self setUserXOffset:newPanX];
		[self setUserYOffset:newPanY];
		[self setUserScale:newUserScale];
	}
	
}

- (void) adjustPan:(float)x Y:(float)y
{
	CGRect viewBounds = [self bounds];
	CGSize viewSize = viewBounds.size;
	
	if(viewSize.width < 1 || viewSize.height < 1)
		return;
	
	float newPanX = (userXOffset * viewSize.width + x) / viewSize.width;
	float newPanY = (userYOffset * viewSize.height + y)  / viewSize.height;
	
	[self setUserXOffset:newPanX];
	[self setUserYOffset:newPanY];
}

@end


