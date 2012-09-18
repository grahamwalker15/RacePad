//
//  MidasClientSocket.m
//  MidasDemo
//
//  Created by Gareth Griffith on 9/13/12.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasClientSocket.h"
#import "MidasCoordinator.h"

@implementation MidasClientSocket

- (void)Connected
{
    [[MidasCoordinator Instance] onSessionLoaded];
}

@end
