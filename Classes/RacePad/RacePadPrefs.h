//
//  RacePadPrefs.h
//  RacePad
//
//  Created by Mark Riches on 04/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RacePadPrefs : NSObject {
	
	NSMutableDictionary *prefs;

}

+ (RacePadPrefs *)Instance;

- (void) setPref: (NSString *)key Value: (id)value;
- (id) getPref: (NSString *)key;

- (void) save;

@end
