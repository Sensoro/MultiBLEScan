//
//  SENBLEScanner.h
//  MultiBLEScan-OC
//
//  Created by David Yang on 15/4/13.
//  Copyright (c) 2015年 Sensoro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SENBLEScanner : NSObject

- (void) startService;
- (void) stopService;

+ (instancetype)sharedInstance;

@end
