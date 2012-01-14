//
//  TwitterView.h
//  F1Test
//
//  Created by Andrew Greenshaw on 09/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifdef USE_REAL_TWITTER
@class ACAccount;
#endif

#import <UIKit/UIKit.h>
#import "BaseSocialmediaView.h"

@interface TwitterView : BaseSocialmediaView
{
    unsigned long long lastTweetId;
}

@property unsigned long long lastTweetId;

@end
