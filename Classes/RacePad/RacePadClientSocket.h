//
//  RacePadClientSocket.h
//  RacePad
//
//  Created by Gareth Griffith on 10/5/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "Socket.h"

@interface RacePadClientSocket : Socket
{
}

- (void) RequestVersion;
- (void) RequestEvent;
- (void) RequestTrackMap;
- (void) SetReferenceTime:(float)reference_time;
- (void) RequestTimingPage;
- (void) StreamTimingPage;
- (void) StreamCars;
- (void) RequestDriverHelmets;
- (void) requestDriverView :(NSString *) driver;
- (void) acceptPushData :(BOOL) send;

@end
