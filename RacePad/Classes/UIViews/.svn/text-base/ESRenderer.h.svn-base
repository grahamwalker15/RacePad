//
//  ESRenderer.h
//  RacePad
//
//  Created by Gareth Griffith on 9/29/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface ESRenderer : NSObject
{
	
    EAGLContext *context;

    // The pixel dimensions of the CAEAGLLayer
    GLint backingWidth;
    GLint backingHeight;

    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view
    GLuint defaultFramebuffer, colorRenderbuffer;
	
}

- (void)render;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;


@end
