//
//  LocationsViewController.m
//  Qaware-Gui
//
//  Created by Zach Taylor on 9/27/14.
//  Copyright (c) 2014 Zach Taylor. All rights reserved.
//

#import "LocationsViewController.h"
#import "LocationItem.h"
#import "LocationItemCell.h"
@import CoreLocation;


@interface LocationsViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;
@property (strong, nonatomic) NSMutableArray *locations;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end


@implementation LocationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.locations = [[NSMutableArray alloc] init];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self loadLocations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"Failed monitoring region: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager failed: %@", error);
}

-(void)startMonitoringItem:(LocationItem *)item {
    CLBeaconRegion *beaconRegion = [self beaconRegionWithItem:item];
    [self.locationManager startMonitoringForRegion:beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:beaconRegion];
}

-(void)stopMonitoringItem:(LocationItem *)item {
    CLBeaconRegion *beaconRegion = [self beaconRegionWithItem:item];
    [self.locationManager stopMonitoringForRegion:beaconRegion];
    [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
}

- (void)loadLocations
{
    self.locations = [NSMutableArray array];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"FFC26D16-3710-4922-80CB-7E53E92443E4"];
    unsigned int major = 1;
    
    NSDictionary *locations = @{@"Kegerator": @2, @"Kitchen": @3, @"Bathroom": @4 };
    for(id name in locations) {
        unsigned int minor = [locations[name] intValue];
        LocationItem *location = [[LocationItem alloc]initWithName: name
                                                uuid: uuid
                                               major: major
                                               minor: minor];
        [self.locations addObject: location];
        [self startMonitoringItem: location];
    }
}

- (CLBeaconRegion *)beaconRegionWithItem:(LocationItem *)item
{
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:item.uuid
                                                                           major:item.major
                                                                           minor:item.minor
                                                                      identifier:item.name];
    return beaconRegion;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Item" forIndexPath:indexPath];
    LocationItem *item = self.locations[indexPath.row];
    cell.item = item;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LocationItem *itemToRemove = [self.locations objectAtIndex:indexPath.row];
        [self stopMonitoringItem:itemToRemove];
        [tableView beginUpdates];
        [self.locations removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
//        [self persistItems];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LocationItem *item = [self.locations objectAtIndex:indexPath.row];
    NSURL *url = [NSURL URLWithString:@"http://192.168.0.17:3000/api"];
    NSData *responseData = [NSData dataWithContentsOfURL:url];
    NSDictionary *forms = [NSJSONSerialization JSONObjectWithData: responseData options: NSJSONReadingMutableLeaves error: nil];
    
    NSString *message = [[NSString alloc] init];
    if ([item.name isEqualToString: @"Kegerator"]){
        message = forms[@"form1"];
    } else if ([item.name isEqualToString: @"Kitchen"]) {
        message = forms[@"form2"];
    } else if ([item.name isEqualToString: @"Bathroom"]) {
        message = forms[@"form3"];
    } else {
        message = @"Something went horribly wrong";
    }
    
    UIAlertView *formAlert = [[UIAlertView alloc]
                              initWithTitle:item.name message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [formAlert show];
    //    NSString *detailMessage = [NSString stringWithFormat:@"UUID: %@\nMajor: %d\nMinor: %d", item.uuid.UUIDString, item.majorValue, item.minorValue];
    //    UIAlertView *detailAlert = [[UIAlertView alloc] initWithTitle:@"Details" message:detailMessage delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    //    [detailAlert show];
    
}


@end
