//
//  MidasCoordinator.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/4/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasCoordinator.h"

#import "ElapsedTime.h"
#import "WorkOffline.h"
#import "midasVideoViewController.h"

@implementation MidasCoordinator

static MidasCoordinator * instance_ = nil;

+(MidasCoordinator *)Instance
{
	if(!instance_)
		instance_ = [[MidasCoordinator alloc] init];
	
	return instance_;
}

-(id)init
{
	if(self =[super init])
	{
		// Create a view controller for the driver lap times which may be displayed as an overlay
		midasVideoViewController = [[MidasVideoViewController alloc] initWithNibName:@"MidasVideoView" bundle:nil];
		
		// Create social media objects
		socialmediaMessageQueue = [[NSMutableArray alloc] init];
		socialmediaSources = [[NSMutableArray alloc] init];
		
		socialmediaMessageQueueBlocked = false;

		socialmediaResponderMask = 0;
		socialmediaResponder = nil;
	}
	
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void) onStartUp
{	
	[self updateSponsor];
}

- (void) goOffline
{
	if ( workOffline == nil )
		workOffline = [[WorkOffline alloc] initWithNibName:@"MidasWorkOffline" bundle:nil];
	
	[workOffline setAnimatedDismissal:false];
	
	[registeredViewController presentModalViewController:workOffline animated:YES];
}

- (void) onDisplayFirstView
{
	[self goOffline];
}

-(void)displayVideoViewController
{
	// We display the default video view once session is loaded
	
	// Set the style for its presentation
	[registeredViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	[registeredViewController setModalPresentationStyle:UIModalPresentationCurrentContext];
	
	// And present it
	[registeredViewController presentModalViewController:midasVideoViewController animated:true];
	
	[self startPlay];
}

-(void)onSessionLoaded
{
	// We display the default video view once session is loaded
	[self performSelector:@selector(displayVideoViewController) withObject:nil afterDelay: 0.1];
}

////////////////////////////////////////////////////////////////////////////////////////
// Registration etc. of social media sources and responder
////////////////////////////////////////////////////////////////////////////////////////

-(void)RegisterSocialmediaResponder:(BasePadViewController <MidasSocialmediaResponderDelegate> *)responder WithTypeMask:(int)mask
{
	// If nil is passed, just release any existing one
	if(!responder)
	{
		[socialmediaResponder release];
		socialmediaResponder = nil;
		socialmediaResponderMask = 0;
		return;
	}
	
	id oldSocialmediaResponder = socialmediaResponder;
	
	socialmediaResponder = [responder retain];
	socialmediaResponderMask = mask;
	
	if(oldSocialmediaResponder)
		[oldSocialmediaResponder release];
}

-(void)ReleaseSocialmediaResponder:(BasePadViewController <MidasSocialmediaResponderDelegate> *)responder
{
	if(socialmediaResponder == responder)
	{
		[socialmediaResponder release];
		socialmediaResponder = nil;
		socialmediaResponderMask = 0;
	}
}

-(void)AddSocialmediaSource:(id)source WithType:(int)type
{
	// First make sure that this source is not already in the list
	MidasSocialmediaSource * existingSource = [self findSocialmediaSource:source];
	
	if(existingSource)
	{
		// If it is, just set the type
		[existingSource setSocialmediaType:type];
		return;
	}
	
	// Reach here if the view wasn't found - so we'll add a new one
	MidasSocialmediaSource * newSource = [[MidasSocialmediaSource alloc] initWithSource:source Type:type];
	[socialmediaSources addObject:newSource];
	[newSource release];
}

-(void)RemoveSocialmediaSource:(id)source
{
	int index;
	MidasSocialmediaSource * existingSource = [self findSocialmediaSource:source WithIndexReturned:&index];
	
	if(existingSource && index >= 0)
	{
		[socialmediaSources removeObjectAtIndex:index];
	}
}

-(MidasSocialmediaSource *)findSocialmediaSource:(id)source
{
	int count = [socialmediaSources count];
	
	if(count > 0)
	{
		for ( int i = 0 ; i < count ; i++)
		{
			MidasSocialmediaSource * existingSource = [socialmediaSources objectAtIndex:i];
			if([existingSource socialmediaSource] == source)
			{
				return existingSource;
			}
		}
	}
	
	// Reach here if the view wasn't found
	return nil;
}

-(MidasSocialmediaSource *)findSocialmediaSource:(id)source WithIndexReturned:(int *)index
{
	*index = -1;
	
	int count = [socialmediaSources count];
	
	if(count > 0)
	{
		for ( int i = 0 ; i < count ; i++)
		{
			MidasSocialmediaSource * existingSource = [socialmediaSources objectAtIndex:i];
			if([existingSource socialmediaSource] == source)
			{
				*index = i;
				return existingSource;
			}
		}
	}
		
	// Reach here if the view wasn't found
	return nil;
}

- (void) playUpdateTimer1hzFired: (NSTimer *)theTimer
{
	[super playUpdateTimer1hzFired:theTimer];

	float elapsed = [elapsedTime value] * activePlaybackRate;
	float updateTime = currentTime + elapsed;

	// Get any new messages from all registered sources
	int count = [socialmediaSources count];
	
	if(count > 0)
	{
		for ( int i = 0 ; i < count ; i++)
		{
			MidasSocialmediaSource * existingSource = [socialmediaSources objectAtIndex:i];
			id <MidasSocialmediaSourceDelegate> socialmediaSource = [existingSource socialmediaSource];
			[socialmediaSource queueNewMessages:socialmediaMessageQueue AtTime:updateTime];
		}
	}
	// Then update the responder if there is anything on the queue
	[self checkSocialmediaMessageQueue];
	
}

- (void)blockSocialmediaQueue
{
	socialmediaMessageQueueBlocked = true;
}

- (void)releaseSocialmediaQueue
{
	socialmediaMessageQueueBlocked = false;
	[self checkSocialmediaMessageQueue];
}

- (void)checkSocialmediaMessageQueue
{
	if(socialmediaMessageQueueBlocked)
		return;
	
	float elapsed = playing ? [elapsedTime value] * activePlaybackRate : 0.0;
	float timeNow = currentTime + elapsed;
	
	
	// Go through the queue looking for a message to notify. Throw away any more than 30 secs old.
	
	bool notified = false;

	if(socialmediaResponder)
	{
		while(!notified && [socialmediaMessageQueue count] > 0)
		{
			MidasSocialmediaMessage * message = [[socialmediaMessageQueue objectAtIndex:0] retain];
			[socialmediaMessageQueue removeObjectAtIndex:0];
		
			if(message && [message messageTime] > (timeNow - 30.0))	// i.e. message less that 30 secs old
			{
				[socialmediaResponder notifyNewSocialmediaMessage:message];
				notified = true;
			}
		
			[message release];
		}

	}
}

-(void) resetListUpdateTimings
{
	[super resetListUpdateTimings];
	
	// Get any new messages from all registered sources
	int count = [socialmediaSources count];
	
	if(count > 0)
	{
		for ( int i = 0 ; i < count ; i++)
		{
			MidasSocialmediaSource * existingSource = [socialmediaSources objectAtIndex:i];
			id <MidasSocialmediaSourceDelegate> socialmediaSource = [existingSource socialmediaSource];
			
			[socialmediaSource resetMessageCount];
			[socialmediaSource queueNewMessages:socialmediaMessageQueue AtTime:currentTime];
		}
	}
	
	// Then update the responder if there is anything on the queue
	[self checkSocialmediaMessageQueue];
	
}


@end


////////////////////////////////////////////////////////////////
//  MIDAS SOCIAL MEDIA CLASSES

@implementation MidasSocialmediaMessage

@synthesize messageType;
@synthesize messageTime;
@synthesize messageSender;
@synthesize messageID;

-(id)initWithSender:(NSString *)sender Type:(int)type Time:(float)time ID:(int)identifier
{
	if(self = [super init])
	{
		messageType = type;
		messageTime = time;
		messageSender = [sender retain];
		messageID = identifier;
	}
	return self;		
}

- (void)dealloc
{
	[messageSender release];
    [super dealloc];
}

@end

@implementation MidasSocialmediaSource

@synthesize socialmediaSource;
@synthesize socialmediaType;

-(id)initWithSource:(id)source Type:(int)type
{
	if(self = [super init])
	{
		socialmediaSource = [source retain];
		socialmediaType = type;
	}
	return self;		
}

- (void)dealloc
{
	[socialmediaSource release];
    [super dealloc];
}

@end


