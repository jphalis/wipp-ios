//
//  MapViewController.m
//  Wipp
//

#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>

#import "CreateViewController.h"
#import "defs.h"
#import "MapViewController.h"
#import "SingleRideViewController.h"
#import "SWRevealViewController.h"


@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate> {
    __weak IBOutlet UIButton *requestBtn;
    __weak IBOutlet UIButton *statusBtn;
    
    NSTimer *timer;
    NSString *status;
    NSString *cost;
}
- (IBAction)onStatusClick:(id)sender;
- (IBAction)onRequest:(id)sender;
@end

@implementation MapViewController {
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

@synthesize mapView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Wipp";

    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController){
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    self.mapView.delegate = self;
    locationManager = [[CLLocationManager alloc] init];
    #ifdef __IPHONE_8_0
        if(IS_OS_8_OR_LATER) {
            [locationManager requestWhenInUseAuthorization];
        }
    #endif
    [locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    [mapView setMapType:MKMapTypeStandard];
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    if(GetActiveRequest){
        requestBtn.hidden = YES;
        requestBtn.enabled = NO;
        
        statusBtn.hidden = NO;
        statusBtn.enabled = YES;
        
        [self initializeTimer];
    } else {
        requestBtn.hidden = NO;
        requestBtn.enabled = YES;
        
        statusBtn.hidden = YES;
        statusBtn.enabled = NO;
    }
    
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)initializeTimer{
    if ([timer isValid]) {
        [timer invalidate], timer = nil;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:7 target:self selector:@selector(checkReservationStatus) userInfo:nil repeats:YES];
}

-(void)checkReservationStatus{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlString = [NSString stringWithFormat:@"%@%ld/", RESURL, (long)GetReservationId];
        
        NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                                 timeoutInterval:60];
        
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
        NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [plainData base64EncodedStringWithOptions:0];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
        [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
        [_request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            if ([data length] > 0 && error == nil){
                NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                
                NSString *statusVerbose = [JSONValue objectForKey:@"status_verbose"];
                
                if ([JSONValue isKindOfClass:[NSDictionary class]]){
                    if ([statusVerbose isEqual: @"Pending"]){
                        status = @"Ride status: Pending...";
                    } else if ([statusVerbose isEqual: @"Negotiating"]){
                        status = @"Ride status: Negotiating";
                        cost = [JSONValue objectForKey:@"final_amount"];
                    } else if ([statusVerbose isEqual: @"Accepted"]){
                        status = @"Ride status: Accepted";
                    } else if ([statusVerbose isEqual: @"Completed"]){
                        status = @"Ride status: Completed";
                    } else if ([statusVerbose isEqual: @"Canceled"]){
                        status = @"Ride status: Canceled";
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([statusVerbose isEqual: @"Pending"]){
                        return;
                    } else if ([statusVerbose isEqual: @"Negotiating"]){
                        [statusBtn setTitle:status forState:UIControlStateNormal];
                        // change text of cost label
                    } else if ([statusVerbose isEqual: @"Accepted"]){
                        [statusBtn setTitle:status forState:UIControlStateNormal];
                        // bring up single ride view and show driver info
                    } else if ([statusVerbose isEqual: @"Completed"]){
                        [statusBtn setTitle:status forState:UIControlStateNormal];
                        SetActiveRequest(NO);
                        [self performSelectorOnMainThread:@selector(stopTimer) withObject:nil waitUntilDone:YES];
                    } else if ([statusVerbose isEqual: @"Canceled"]){
                        [statusBtn setTitle:status forState:UIControlStateNormal];
                        SetActiveRequest(NO);
                        [self performSelectorOnMainThread:@selector(stopTimer) withObject:nil waitUntilDone:YES];
                    }
                });
            }
        }];
    });
}

- (void)stopTimer {
    [timer invalidate];
    timer = nil;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 900, 900);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    // Add an annotation
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = userLocation.coordinate;
    point.title = @"Current Location";
//    point.subtitle = @"subtitle can go here";
    
    [self.mapView addAnnotation:point];
}

- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude];
}

- (NSString *)deviceLat {
    return [NSString stringWithFormat:@"%f", locationManager.location.coordinate.latitude];
}

- (NSString *)deviceLon {
    return [NSString stringWithFormat:@"%f", locationManager.location.coordinate.longitude];
}

- (NSString *)deviceAlt {
    return [NSString stringWithFormat:@"%f", locationManager.location.altitude];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)locationStatus {
    if (locationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [locationManager startUpdatingLocation];
    } else if (locationStatus == kCLAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location services not authorized"
                                                        message:@"This app needs you to authorize locations services to work."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        return;
//        NSLog(@"Wrong location status");
    }
}

- (IBAction)onStatusClick:(id)sender {
    SingleRideViewController *singleRideViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SingleRideViewController"];
    [self.navigationController pushViewController:singleRideViewController animated:YES];
}

- (IBAction)onRequest:(id)sender {
    CreateViewController *createViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateViewController"];
    [self.navigationController pushViewController:createViewController animated:YES];
}
@end
