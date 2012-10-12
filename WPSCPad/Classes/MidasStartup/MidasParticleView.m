//
//  MidasParticleView.m
//  Midas
//
//  Created by Daniel Tull on 13/08/2012.
//  Copyright (c) 2012 SBG Sports Software Ltd.. All rights reserved.
//

#import "MidasParticleView.h"

const CGFloat MidasParticleViewWaftDistance = 50.0f;
const NSInteger MidasParticleViewParticleSpacing = 100;

@implementation MidasParticleView {
	__strong NSMutableArray *_particles;
	NSUInteger _maximumParticles;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (!self) return nil;

	_particles = [NSMutableArray new];

	CGFloat maxAcross = self.bounds.size.width / MidasParticleViewParticleSpacing;
	CGFloat maxHigh = self.bounds.size.height / MidasParticleViewParticleSpacing;
	_maximumParticles = floorf(maxAcross * maxHigh);

	NSInteger xPosition = -MidasParticleViewParticleSpacing;
	while (xPosition < self.bounds.size.width + MidasParticleViewParticleSpacing) {
		UIImageView *particle = [self _generateNewParticleAroundXPosition:(CGFloat)xPosition];

		[self _animateParticle:particle delay:[self _randomDelay]];

		xPosition += MidasParticleViewParticleSpacing;
	}

	return self;
}

- (void)_animateParticle:(UIImageView *)particle
				   delay:(NSTimeInterval)delay {

	CGRect frame = particle.frame;

	if (frame.origin.y < 0) {
		[particle removeFromSuperview];
		[_particles removeObject:particle];
		NSInteger xPosition = frame.origin.x;
		if (xPosition < 0)
			xPosition += self.bounds.size.width;
		else if (xPosition > self.bounds.size.width)
			xPosition -= self.bounds.size.width;
		particle = [self _generateNewParticleAroundXPosition:xPosition];
		frame = particle.frame;
	}

	if ([_particles count] < _maximumParticles
		&& frame.origin.y > self.bounds.size.height - MidasParticleViewWaftDistance
		&& frame.origin.y < self.bounds.size.height) {
		UIImageView *newParticle = [self _generateNewParticleAroundXPosition:frame.origin.x];
		[self _animateParticle:newParticle delay:[self _randomDelay]];
	}

	frame.origin.x += (MidasParticleViewWaftDistance * [self _randomDirection]);
	frame.origin.y -= MidasParticleViewWaftDistance;
	
	__weak MidasParticleView *weakSelf = self;
	[UIView animateWithDuration:1.5 delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
		particle.frame = frame;
	} completion:^(BOOL finished) {
		[weakSelf _animateParticle:particle delay:0.0f];
	}];
}

- (NSTimeInterval)_randomDelay {
	return ((arc4random() % 100)+100)/100.f;
}

- (NSInteger)_randomDirection {
	NSInteger direction = arc4random() % 2;
	if (direction < 0.5) return -1;
	return 1;
}

- (UIImageView *)_generateNewParticleAroundXPosition:(CGFloat)xPosition {
	UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"particle%i", arc4random() % 2]];
	UIImageView *particle = [[UIImageView alloc] initWithImage:image];
	CGRect frame = particle.frame;
	frame.origin.x = xPosition;
	frame.origin.y = self.bounds.size.height + (arc4random() % MidasParticleViewParticleSpacing);
	particle.frame = frame;
	[self addSubview:particle];
	[_particles addObject:particle];
	return particle;
}

@end
