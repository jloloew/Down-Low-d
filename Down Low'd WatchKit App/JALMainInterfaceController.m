//
//  JALMainInterfaceController.m
//  Down Low'd
//
//  Created by Justin Loew on 9/12/15.
//  Copyright © 2015 Justin Loew. All rights reserved.
//

#import "JALMainInterfaceController.h"

@interface JALMainInterfaceController ()
@property (nonatomic) NSUInteger accelCount;
@end

@implementation JALMainInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
	
	self.accelDataListener = [[AccelDataListener alloc] initWithSpikeDetectedHandler:void (^)() {
		NSLog("%lu", ++self.accelCount);
	}];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



