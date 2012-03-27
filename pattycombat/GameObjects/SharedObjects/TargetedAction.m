//
//  TargetedAction.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 21/11/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "TargetedAction.h"

@interface TargetedAction (Private)

// Ugly hack to get around a compiler bug.
- (id) initWithTarget:(id) targetIn actionByAnotherName:(CCFiniteTimeAction*) actionIn;

@end

@implementation TargetedAction

@synthesize forcedTarget;

+ (id) actionWithTarget:(id) target action:(CCFiniteTimeAction*) action
{
	return [[self alloc] initWithTarget:target actionByAnotherName:action];
}

- (id) initWithTarget:(id) targetIn action:(CCFiniteTimeAction*) actionIn
{
	return [self initWithTarget:targetIn actionByAnotherName:actionIn];
}

- (id) initWithTarget:(id) targetIn actionByAnotherName:(CCFiniteTimeAction*) actionIn
{
	if(nil != (self = [super initWithDuration:actionIn.duration]))
	{
		forcedTarget = targetIn;
		action = actionIn;
	}
	return self;
}


//- (void) updateDuration:(id)aTarget
//{
//	[action updateDuration:forcedTarget];
//	duration_ = action.duration;
//}

- (void) startWithTarget:(id)aTarget
{
	[super startWithTarget:forcedTarget];
	[action startWithTarget:forcedTarget];
}

- (void) stop
{
	[action stop];
}

- (void) update:(ccTime) time
{
	[action update:time];
}

@end
