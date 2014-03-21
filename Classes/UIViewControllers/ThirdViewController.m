    //
//  ThirdViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "ThirdViewController.h"


@implementation ThirdViewController

- (id)init
{
	if(self = [super init])
	{
		renderer_ = nil;
	}
	
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	EAGLView * controlled_view = (EAGLView *)[super view];
	if(controlled_view)
	{
		renderer_ = [[ThirdViewRenderer alloc] init];
		[controlled_view SetRenderer:renderer_];
		[controlled_view SetAnimationFrameInterval:2];
	}
	
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
	EAGLView * controlled_view = (EAGLView *)[super view];
	[controlled_view StartAnimation];
}

- (void)viewWillDisappear:(BOOL)animated
{
	EAGLView * controlled_view = (EAGLView *)[super view];
	[controlled_view StopAnimation];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

/*
- (void)viewDidUnload
{
}
*/


- (void)dealloc
{
    [super dealloc];
}

@end

@implementation ThirdViewRenderer

- (void)render
{
    // Replace the implementation of this method to do your own custom drawing
	
    static const GLfloat squareVertices[] = {
        -0.5f,  -0.33f,
		0.5f,  -0.33f,
        -0.5f,   0.33f,
		0.25f,   0.66f,
    };
	
    static const GLubyte squareColors[] = {
        255, 255,   0, 255,
        255, 255,   0, 255,
        0,     0,   0,   0,
        0,     0,   0,   0,
    };
	
    static float transY = 0.0f;
	
    // This application only creates a single context which is already set current at this point.
    // This call is redundant, but needed if dealing with multiple contexts.
    [EAGLContext setCurrentContext:context];
	
    // This application only creates a single default framebuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple framebuffers.
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
	
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glRotatef(transY, 0.0f, 0.0f, 1.0f);
    glTranslatef(0.0f, (GLfloat)(sinf(transY)/2.0f), 0.0f);
    transY += 0.075f;
	
    glClearColor(1.0f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
	
    glVertexPointer(2, GL_FLOAT, 0, squareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
    glEnableClientState(GL_COLOR_ARRAY);
	
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
    // This application only creates a single color renderbuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple renderbuffers.
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

@end

