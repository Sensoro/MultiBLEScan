//
//  MasterViewController.m
//  MultiBLEScan-OC
//
//  Created by David Yang on 15/4/13.
//  Copyright (c) 2015年 Sensoro. All rights reserved.
//

#import "MasterViewController.h"
#import "SENBLEScanner.h"
#import "SBKDBeaconCell.h"
#import <SensoroBeaconKit/SensoroBeaconKit.h>

static NSString *CellIdentifier = @"SBKDBeaconCell";

@interface MasterViewController () <SBKBeaconManagerDelegate> {
    NSArray *_UUIDs;
    NSMutableArray *_beacons;
}

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
//
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
//
    [self.tableView registerNib:[UINib nibWithNibName:CellIdentifier bundle:nil]
         forCellReuseIdentifier:CellIdentifier];
    self.tableView.rowHeight = 112;
    self.tableView.allowsSelection = NO;
    
    
    [[SENBLEScanner sharedInstance] startService];
    
    _beacons = [NSMutableArray array];

    _UUIDs = @[@"23A01AF0-232A-4518-9C0E-323FB773F5EF",
               @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
    
    [[SBKBeaconManager sharedInstance] setDebugModeActive:YES];
    [[SBKBeaconManager sharedInstance] requestAlwaysAuthorization];
    
    [SBKBeaconManager sharedInstance].delegate = self;
    for (NSString *str in _UUIDs) {
        SBKBeaconID *beaconID = [SBKBeaconID beaconIDWithString:str];
        [[SBKBeaconManager sharedInstance] startRangingBeaconsWithID:beaconID wakeUpApplication:YES];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _beacons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//
//    SBKBeacon *object = _beacons[indexPath.row];
//    cell.textLabel.text = object.beaconID.stringRepresentation;
//    return cell;
    SBKDBeaconCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    SBKBeacon *beacon = _beacons[indexPath.row];
    cell.majorAndMinorLabel.text = [NSString stringWithFormat:@"%04X-%04X ", beacon.beaconID.major.intValue, beacon.beaconID.minor.intValue];
    cell.UUIDLabel.text = beacon.beaconID.proximityUUID.UUIDString;
    cell.detailLabel.text = [NSString stringWithFormat:@"Model: %@, RSSI: %d, accuracy : %f",
                             beacon.hardwareModelName ?: @"Unknown",
                             (int)beacon.rssi,beacon.accuracy];
    
    cell.deviceInfo.text = [NSString stringWithFormat:@"hardware: %@ firmware %@",
                            beacon.hardwareModelName,beacon.firmwareVersion];
    
    cell.sensorInfo.text = [NSString stringWithFormat:@"Temp.:%@ Ligth:%@ Tx : %@",
                            beacon.temperature,beacon.light, [SBKUnitConvertHelper transmitPowerToString:beacon]];
    
    if (beacon.inRange) {
        if (beacon.proximity != CLProximityUnknown) {
            [cell.dotImageView setImage:[UIImage imageNamed:@"dot_green"]];
        } else {
            [cell.dotImageView setImage:[UIImage imageNamed:@"dot_yellow"]];
        }
    } else {
        [cell.dotImageView setImage:[UIImage imageNamed:@"dot_red"]];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_beacons removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark 


- (void)beaconManager:(SBKBeaconManager *)beaconManager didRangeNewBeacon:(SBKBeacon *)beacon {
    [_beacons addObject:beacon];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_beacons.count - 1 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"New Beacon: %@", beacon.beaconID];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

- (void)beaconManager:(SBKBeaconManager *)beaconManager beaconDidGone:(SBKBeacon *)beacon {
    
    [_beacons removeObject:beacon];
    
    if ([self.tableView numberOfRowsInSection:0] > _beacons.count) {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_beacons.count inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)beaconManager:(SBKBeaconManager *)beaconManager scanDidFinishWithBeacons:(NSArray *)beacons {
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
    
    //NSArray* allBeacons = [SBKBeaconManager sharedInstance].allBeacons;
}


@end
