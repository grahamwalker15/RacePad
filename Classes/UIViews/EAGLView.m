//
//  EAGLView.m
//  RacePad
//
//  Created by Gareth Griffith on 9/29/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "EAGLView.h"

#import "ESRenderer.h"

@implementation EAGLView

@synthesize renderer_;
@synthesize animating_;
@dynamic animation_frame_interval_;

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;

        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];

		renderer_ = nil;
		
        animating_ = FALSE;
        display_link_supported_ = FALSE;
        animation_frame_interval_ = 1;
        display_link_ = nil;
        animation_timer_ = nil;

        // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
        // class is used as fallback when it isn't available.
        NSString *reqSysVer = @"3.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
		
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
            display_link_supported_ = TRUE;
    }

    return self;
}

- (IBAction)DrawView:(id)sender
{
	[renderer_ render];
}

- (void)layoutSubviews
{
	[renderer_ resizeFromLayer:(CAEAGLLayer*)self.layer];
	[self DrawView:nil];
}

- (NSInteger)AnimationFrameInterval
{
    return animation_frame_interval_;
}

- (void)SetAnimationFrameInterval:(NSInteger)frame_interval
{
    // Frame interval defines how many display frames must pass between each time the
    // display link fires. The display link will only fire 30 times a second when the
    // frame internal is two on a display that refreshes 60 times a second. The default
    // frame interval setting of one will fire 60 times a second when the display refreshes
    // at 60 times a second. A frame interval setting of less than one results in undefined
    // behavior.
    if (frame_interval >= 1)
    {
        animation_frame_interval_ = frame_interval;

        if (animating_)
        {
            [self StopAnimation];
            [self StartAnimation];
        }
    }
}

- (IBAction)StartAnimation
{
    if (!animating_)
    {
        if (display_link_supported_)
        {
            // CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
            // if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
            // not be called in system versions earlier than 3.1.

            display_link_ = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(DrawView:)];
            [display_link_ setFrameInterval:animation_frame_interval_];
            [display_link_ addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else
		{
            animation_timer_ = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animation_frame_interval_) target:self selector:@selector(DrawView:) userInfo:nil repeats:TRUE];
		}
		
        animating_ = TRUE;
    }
}

- (IBAction)StopAnimation
{
    if (animating_)
    {
        if (display_link_supported_)
        {
            [display_link_ invalidate];
            display_link_ = nil;
        }
        else
        {
            [animation_timer_ invalidate];
            animation_timer_ = nil;
        }

        animating_ = FALSE;
    }
}

- (void)dealloc
{
    [renderer_ release];

    [super dealloc];
}

@end
