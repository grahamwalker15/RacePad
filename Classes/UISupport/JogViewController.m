//
//  JogViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 12/31/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "JogViewController.h"

@implementation JogControlView

@synthesize angle;
@synthesize change;
@synthesize target;
@synthesize selector;


static UIImage * baseImage = nil;
static UIImage * insetImage = nil;

static bool jog_images_initialised_ = false;

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

- (void)dealloc
{
	[baseImage release];
	[insetImage release];
	[target release];
	
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
	CGRect currentBounds = [self bounds];
	[baseImage drawAtPoint:CGPointMake(0, 0)];
	
	float xCentre = currentBounds.size.width / 2;
	float yCentre = currentBounds.size.height / 2;
	
	float radius = xCentre < yCentre ? xCentre - 25 : yCentre - 25;
	
	float xInset = radius * cos(angle) + xCentre - insetImage.size.width / 2;
	float yInset = - radius * sin(angle) + yCentre - insetImage.size.height / 2;
	
	[insetImage drawAtPoint:CGPointMake(xInset, yInset)];
}

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Methods for this class 

- (void)InitialiseMembers
{
	angle = 0.0;
	target = nil;
}

- (void)InitialiseImages
{
	if(!jog_images_initialised_)
	{
		jog_images_initialised_ = true;
		
		baseImage = [[UIImage imageNamed:@"JogControlBase.png"] retain];
		insetImage = [[UIImage imageNamed:@"JogControlInset.png"] retain];
	}
	else
	{
		[baseImage retain];
		[insetImage retain];
	}
	
}

- (void)JogAngleChanged
{
	[self setNeedsDisplay];
	
	if(target)
		[target performSelector:selector withObject:self];
}

- (float)value
{
	// Returns change -1 to 1 for a full turn
	return change / M_PI;
}

@end

@implementation JogViewController

@synthesize jogControl;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[self addJogRecognizerToView:jogControl];

    [super viewDidLoad];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [super dealloc];
}

- (void) OnJogGestureInView:(UIView *)gestureView AngleChange:(float)angle State:(int)state
{
	[jogControl setChange:angle];
	[jogControl setAngle:[jogControl angle] + angle];
	[jogControl JogAngleChanged];
}

@end
