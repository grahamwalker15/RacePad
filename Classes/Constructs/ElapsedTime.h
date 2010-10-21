//
//  ElapsedTime.h
//  RacePad
//
//  Created by Mark Riches on 20/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ElapsedTime : NSObject {
	
	double start;

}

- (id) init;
- (void) reset;
- (double) value;

@end
