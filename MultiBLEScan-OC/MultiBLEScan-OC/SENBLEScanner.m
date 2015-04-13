//
//  SENBLEScanner.m
//  MultiBLEScan-OC
//
//  Created by David Yang on 15/4/13.
//  Copyright (c) 2015年 Sensoro. All rights reserved.
//

#import "SENBLEScanner.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface SENBLEScanner () <CBCentralManagerDelegate>{
    CBCentralManager *_bluetoothManager;
    
    BOOL _started;
}

@end

@implementation SENBLEScanner

+ (instancetype)sharedInstance{
    static dispatch_once_t __pred;
    __strong static SENBLEScanner *__sharedInstance = nil;
    
    dispatch_once(&__pred, ^{
        __sharedInstance = [[SENBLEScanner alloc] init];
    });
    
    return __sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _started = NO;
    }
    
    return self;
}

- (void) startService{
    if (_bluetoothManager == nil) {
        //新分配一个CBCentralManager，会调用centralManagerDidUpdateState回调，在此函数中启动扫描。
        _bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self
                                                                 queue:nil
                                                               options:@{CBCentralManagerOptionShowPowerAlertKey: @NO}];
    }else{
        //已经启动过了，则在这里直接启动。
        [self startScan];
    }
}

- (void) stopService{
    [self stopScan];
}

- (void) startScan{
    if(_started == YES){
        return;
    }
    
    [_bluetoothManager scanForPeripheralsWithServices:nil
                                              options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @NO}];
}

- (void) stopScan{
    if(_started == NO){
        return;
    }
    [_bluetoothManager stopScan];
}

#pragma mark CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [self startScan];
            NSLog(@"Bluetooth was power on!");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"Bluetooth was power off!");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"Bluetooth was resetting!");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"Bluetooth was unsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"Bluetooth was unauthorized");
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    
    NSLog(@"Find new BLE Info");
}

@end
