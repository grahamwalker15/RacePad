//
//  BasePadPrefs.h
//  BasePad
//
//  Created by Mark Riches on 04/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BasePadPrefs : NSObject {
	
	NSMutableDictionary *prefs;

}

+ (BasePadPrefs *)Instance;

- (void) setPref: (NSString *)key Value: (id)value;
- (id) getPref: (NSString *)key;

- (void) save;

@end
