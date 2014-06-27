//
//  MCSocket.h
//  RacePad
//
//  Created by Gareth Griffith on 10/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//
// The quick brown fox
//
//

#import <Foundation/Foundation.h>

#import "Socket.h"
@class BufferedDataStream;

@interface MCSocket : Socket
{
    BufferedDataStream *MCData;
    int lastFragmentIndex;
}

- (void)OnReceive:(CFSocketRef) socket_ref Data:(CFDataRef)data;

@end
