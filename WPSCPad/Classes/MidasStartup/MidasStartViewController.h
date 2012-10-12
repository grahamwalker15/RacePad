//
//  MidasStartViewController.h
//  Midas
//
//  Created by Daniel Tull on 11.08.2012.
//  Copyright (c) 2012 SBG Sports Software Ltd.. All rights reserved.
//

#import "BasePadViewController.h"
#import "BasePadCoordinator.h"

@interface MidasStartViewController : BasePadViewController <ConnectionFeedbackDelegate>
{

}

-(IBAction)loadArchive:(id)sender;
-(IBAction)loadLive:(id)sender;
-(IBAction)connectLive:(id)sender;

@end

