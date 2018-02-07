//
//  EAGLView.h
//  RacePad
//
//  Created by Gareth Griffith on 9/29/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ESRenderer.h"

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView
{    
@private
	
	id renderer_;

    BOOL animating_;
    BOOL display_link_supported_;
    NSInteger animation_frame_interval_;
    // Use of the CADisplayLink class is the preferred method for controlling your animation timing.
    // CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
    // The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink
    // isn't available.
    id display_link_;
    NSTimer *animation_timer_;
}

@property (readonly, nonatomic, getter=IsAnimating) BOOL animating_;
@property (nonatomic, setter = SetAnimationFrameInterval, getter=AnimationFrameInterval) NSInteger animation_frame_interval_;
@property (nonatomic, retain, setter=SetRenderer, getter=GetRenderer) id renderer_;;

- (IBAction)StartAnimation;
- (IBAction)StopAnimation;
- (IBAction)DrawView:(id)sender;

@end
