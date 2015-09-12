//
//  JALMainInterfaceController.h
//  Down Low'd
//
//  Created by Justin Loew on 9/12/15.
//  Copyright © 2015 Justin Loew. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "AccelDataListener-Swift.h"

@interface JALMainInterfaceController : WKInterfaceController
@property (IBOutlet) WKInterfaceLabel *accelCountLabel;
@property (nonatomic) AccelDataListener *accelDataListener;
@end
