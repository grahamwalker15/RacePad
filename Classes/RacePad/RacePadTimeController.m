//
//  RacePadTimeController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/25/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadCoordinator.h"
#import "RacePadTimeController.h"
#import "RacePadViewController.h"
#import "TimeViewController.h"
#import "JogViewController.h"

@implementation RacePadTimeController

static RacePadTimeController * instance_ = nil;

@synthesize displayed;
@synthesize timeNow;

+(RacePadTimeController *)Instance
{
	if(!instance_)
		instance_ = [[RacePadTimeController alloc] init];
	
	return instance_;
}

-(id)init
{
	if(self = [super init])
	{	
		timeController = [[TimeViewController alloc] initWithNibName:@"TimeControlView" bundle:nil];
		jogController = [[JogViewController alloc] initWithNibName:@"JogControlView" bundle:nil];
		addOnOptionsView = nil;
		
		displayed = false;
		hiding = false;
		hideTimer = nil;
		
		timeNow = 0.0;
	}
	
	return self;
}


- (void)dealloc
{
	[timeController release];
	[jogController release];
	[addOnOptionsView release];
    [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////

- (void) onStartUp
{
}

- (void) displayInViewController:(RacePadViewController *)viewController Animated:(bool)animated
{	
	// Can't display if we're in the middle of hiding
	if(hiding)
		return;
	
	// Release any existing add on from an old view controller
	if(addOnOptionsView)
	{
		[addOnOptionsView removeFromSuperview];
		[addOnOptionsView release];
		addOnOptionsView = nil;
	}
	
	// Get the new add on
	addOnOptionsView = [[viewController timeControllerAddOnOptionsView] retain];
	
	// Get the new positions
	CGRect super_bounds = [viewController.view bounds];
	CGRect time_controller_bounds = [timeController.view bounds];
	CGRect time_toolbar_bounds = [timeController.toolbar bounds];
	CGRect jog_controller_bounds = [jogController.view bounds];
	
	CGRect timeFrame = CGRectMake(super_bounds.origin.x + 30, super_bounds.origin.y + super_bounds.size.height - time_controller_bounds.size.height - 30, super_bounds.size.width - 60, time_controller_bounds.size.height);
	CGRect toolbarFrame = CGRectMake(super_bounds.origin.x + 30, super_bounds.origin.y + super_bounds.size.height - time_toolbar_bounds.size.height - 30, super_bounds.size.width - 60, time_toolbar_bounds.size.height);
	CGRect jogFrame = CGRectMake(toolbarFrame.origin.x + toolbarFrame.size.width - jog_controller_bounds.size.width, toolbarFrame.origin.y - jog_controller_bounds.size.height - 20, jog_controller_bounds.size.width, jog_controller_bounds.size.height);
	[timeController.view setFrame:timeFrame];
	[jogController.view setFrame:jogFrame];
	
	if(addOnOptionsView)
	{
		CGRect options_bounds = [addOnOptionsView bounds];
		CGRect optionsFrame = CGRectMake(super_bounds.origin.x + (super_bounds.size.width - options_bounds.size.width) / 2, toolbarFrame.origin.y - options_bounds.size.height - 10, options_bounds.size.width, options_bounds.size.height);
		[addOnOptionsView setFrame:optionsFrame];
	}

	if(animated)
	{
		[timeController.view setAlpha:0.0];
		[jogController.view setAlpha:0.0];
		if(addOnOptionsView)
		{
			[addOnOptionsView setAlpha:0.0];
		}
	}
	
	[viewController.view addSubview:timeController.view];
	[viewController.view addSubview:jogController.view];
	[self updatePlayButton];
	
	if(addOnOptionsView)
	{
		[viewController.view addSubview:addOnOptionsView];
	}

	if(animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.15];
		[timeController.view setAlpha:1.0];
		[jogController.view setAlpha:1.0];
		if(addOnOptionsView)
		{
			[addOnOptionsView setAlpha:1.0];
		}
		[UIView commitAnimations];
	}
	
	UIBarButtonItem * play_button = [timeController playButton];	
	[play_button setTarget:instance_];
	[play_button setAction:@selector(PlayPressed:)];
	
	UISlider * slider = [timeController timeSlider];
	[slider addTarget:instance_ action:@selector(SliderChanged:) forControlEvents:UIControlEventValueChanged];
	[slider addTarget:instance_ action:@selector(SliderFinished:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
	
	UIBarButtonItem * replay_button = [timeController replayButton];	
	[replay_button setTarget:instance_];
	[replay_button setAction:@selector(ReplayPressed:)];
	
	JogControlView * jog_control = [jogController jogControl];	
	[jog_control setTarget:instance_];
	[jog_control setSelector:@selector(JogControlChanged:)];
	
	ShinyButton *goLiveButton = [timeController goLiveButton];	
	[goLiveButton addTarget:instance_ action:@selector(goLivePressed:) forControlEvents:UIControlEventTouchUpInside];
	
	[self updateLiveButton];
	
	float current_time = [[RacePadCoordinator Instance] currentTime];
	float start_time = [[RacePadCoordinator Instance] startTime];
	float end_time = [[RacePadCoordinator Instance] endTime];
	float live_time = [[RacePadCoordinator Instance] liveTime];
	
	if ( [[RacePadCoordinator Instance] connectionType] == RPC_SOCKET_CONNECTION_ && end_time > live_time)
		end_time = live_time;
	
	[self setSliderMin:start_time Max:end_time];
	[self updateTime:current_time];
	
	displayed = true;
	[self setHideTimer];
	
}

- (void) hide
{
	hiding = true;
	
	if(hideTimer)
	{
		[hideTimer invalidate];
		hideTimer = nil;
	}

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.15];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[timeController.view setAlpha:0.0];
	[jogController.view setAlpha:0.0];
	
	if(addOnOptionsView)
	{
		[addOnOptionsView setAlpha:0.0];
	}
	
	[UIView commitAnimations];
	
	// We set a timer to reset the hiding flag just in case the animationDidStop doesn't get called (maybe on tab change?)
	[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(flagTimerExpired:) userInfo:nil repeats:NO];
}

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context
{
	if([finished intValue] == 1)
	{
		[timeController.view removeFromSuperview];
		[jogController.view removeFromSuperview];
		displayed = false;
		
		// Release any existing add on from an old view controller
		if(addOnOptionsView)
		{
			[addOnOptionsView removeFromSuperview];
			[addOnOptionsView release];
			addOnOptionsView = nil;
		}
		
		hiding = false;
		
	}
}

- (void) flagTimerExpired:(NSTimer *)theTimer
{
	hiding = false;
}

- (void) setHideTimer
{
	// Timer to hide the controls if they're not touched for 5 seconds
	if(hideTimer)
		[hideTimer invalidate];
	
	hideTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(hideTimerExpired:) userInfo:nil repeats:NO];
	
}

- (void) hideTimerExpired:(NSTimer *)theTimer
{
	[self hide];
	hideTimer = nil;
}

- (void) updateTime:(float)time
{
	[self updateSlider:time];
	[self updateClock:time];
	timeNow = time;
}

- (void) updateSlider:(float)time
{
	UISlider * slider = [timeController timeSlider];
	
	if(time < [slider minimumValue])
		[slider setMinimumValue:time];
	
	if(time > [slider maximumValue])
		[slider setMaximumValue:time];
	
	[slider setValue:time animated:false];
}

- (void) updateClock:(float)time
{
	UIButton * clock = [timeController clock];
	
	int h = (int)(time / 3600.0); time -= h * 3600;
	int m = (int)(time / 60.0); time -= m * 60;
	int s = (int)(time);
	NSString * time_string = [NSString stringWithFormat:@"%d:%02d:%02d", h, m, s];
	[clock setTitle:time_string forState:UIControlStateNormal];
}

- (void) setSliderMin:(float)startTime
{
	UISlider * slider = [timeController timeSlider];
	[slider setMinimumValue:startTime];
}

- (void) setSliderMax:(float)endTime
{
	UISlider * slider = [timeController timeSlider];
	[slider setMaximumValue:endTime];
}
- (void) setSliderMin:(float)startTime Max:(float)endTime
{
	UISlider * slider = [timeController timeSlider];
	[slider setMinimumValue:startTime];
	[slider setMaximumValue:endTime];
}


- (void) updatePlayButton
{
	RacePadCoordinator * coordinator = [RacePadCoordinator Instance];
	UIBarButtonItem * play_button = [timeController playButton];	
	
	if(play_button)
	{
		if([coordinator playing])
		{
			[play_button setImage:[UIImage imageNamed:@"pause.png"]];
		}
		else
		{
			[play_button setImage:[UIImage imageNamed:@"play.png"]];
		}
	}
	
	[self updateLiveButton];
	
	[self setHideTimer];
}

- (void) updateLiveButton
{
	ShinyButton *liveButton = [timeController goLiveButton];
	
	if ( [[RacePadCoordinator Instance] liveMode] )
	{
		[liveButton setTitle:@"Live" forState:UIControlStateNormal];
		[liveButton setButtonColour:[UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0]];
		[liveButton setTextColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
		[liveButton requestRedraw];
	}
	else
	{
		[liveButton setTitle:@"Go Live" forState:UIControlStateNormal];
		[liveButton setButtonColour:[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0]];
		[liveButton setTextColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
		[liveButton requestRedraw];
	}
	
}


//////////////////////////////////////////////////////////////////////////////////
// Actions
//////////////////////////////////////////////////////////////////////////////////

- (IBAction)PlayPressed:(id)sender
{
	[jogController killUpdateTimer];	// Just in case it got stuck on

	RacePadCoordinator * coordinator = [RacePadCoordinator Instance];
	if([coordinator playing])
	{
		[coordinator userPause];
		[self updatePlayButton];
	}
	else
	{
		[coordinator prepareToPlay];
		[coordinator startPlay];
		[self updatePlayButton];
	}
	
	[self setHideTimer];
}

- (IBAction)SliderChanged:(id)sender
{
	// Don't update movie while sliding -will do on finish
	[[RacePadCoordinator Instance] setLiveMovieSeekAllowed:false];
	[self actOnSliderValue];
}

- (IBAction)SliderFinished:(id)sender
{
	[[RacePadCoordinator Instance] setLiveMovieSeekAllowed:true];
	[self actOnSliderValue];
}

- (void)actOnSliderValue
{
	[jogController killUpdateTimer];	// Just in case it got stuck on
	
	UISlider * slider = [timeController timeSlider];
	float time = [slider value];
	[[RacePadCoordinator Instance] jumpToTime:time];
	[self updateClock:time];
	timeNow = time;
	[self setHideTimer];
}

- (IBAction)JogControlChanged:(id)sender
{
	RacePadCoordinator * coordinator = [RacePadCoordinator Instance];
	
	[coordinator stopPlay];
	float time = [coordinator currentTime];

	JogControlView * jog_control = [jogController jogControl];
	float change = [jog_control value];
	float sign = change < 0 ? -1.0 :1.0;
	
	change = sign * change * change; // Square it to get finer control on slow motion
	
	time -= change * 0.8;	// 20 * real time for half turn - -ve angle = positive time change
							// Called on 25 hz timer
	
	if(time < [coordinator startTime])
		time = [coordinator startTime];
	
	[coordinator jumpToTime:time];
	[self updateTime:time];
	[self setHideTimer];
}

- (IBAction)ReplayPressed:(id)sender
{
	RacePadCoordinator * coordinator = [RacePadCoordinator Instance];
	
	[coordinator stopPlay];
	float time = [coordinator currentTime];
	
	time -= 20.0;
	if(time < [coordinator startTime])
		time = [coordinator startTime];
	
	[coordinator jumpToTime:time];
	[self updateTime:time];
	
	[coordinator prepareToPlay];
	[coordinator startPlay];
	[self updatePlayButton];
	
	[self setHideTimer];
}

- (IBAction)goLivePressed:(id)sender
{
	if ( ![[RacePadCoordinator Instance] liveMode] )
		[[RacePadCoordinator Instance] goLive:true];
}	

@end
