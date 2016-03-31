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
    locationManager.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    if(GetActiveRequest || GetActiveDrive){
        requestBtn.hidden = YES;
        requestBtn.enabled = NO;
        
        statusBtn.hidden = NO;
        statusBtn.enabled = YES;
        
        [self checkReservationStatus];
        [self initializeTimer];
    } else {
        requestBtn.hidden = NO;
        requestBtn.enabled = YES;
        
        statusBtn.hidden = YES;
        statusBtn.enabled = NO;
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse
        ) {
        [locationManager requestWhenInUseAuthorization];
    } else {
        [locationManager startUpdatingLocation];
    }
    locationManager.distanceFilter = kCLDistanceFilterNone;
    // locationManager.distanceFilter = 250;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    self.mapView.showsUserLocation = YES;
    [mapView setMapType:MKMapTypeStandard];
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
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
        NSString *urlString = [NSString stringWithFormat:@"%@%@/", RESURL, GetReservationId];
        
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
                
                status = [JSONValue objectForKey:@"status_verbose"];
                if ([status isEqual: @"Negotiating"]){
                    cost = [JSONValue objectForKey:@"final_amount"];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([status isEqual: @"Pending"]){
                        return;
                    } else if ([status isEqual: @"Negotiating"]){
                        [statusBtn setTitle:status forState:UIControlStateNormal];
                        // change text of cost label
                    } else if ([status isEqual: @"Accepted"]){
                        [statusBtn setTitle:status forState:UIControlStateNormal];
                        [self performSelectorOnMainThread:@selector(stopTimer) withObject:nil waitUntilDone:YES];
                    } else if ([status isEqual: @"Completed"]){
                        [statusBtn setTitle:status forState:UIControlStateNormal];
                        SetActiveRequest(NO);
                        SetActiveDrive(NO);
                        [self performSelectorOnMainThread:@selector(stopTimer) withObject:nil waitUntilDone:YES];
                    } else if ([status isEqual: @"Canceled"]){
                        [statusBtn setTitle:status forState:UIControlStateNormal];
                        SetActiveRequest(NO);
                        SetActiveDrive(NO);
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
    [locationManager stopUpdatingLocation];
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
    // point.subtitle = @"subtitle can go here";
    
    [self.mapView addAnnotation:point];
}

- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)locationServiceStatus {
    
    switch (locationServiceStatus) {
        case kCLAuthorizationStatusNotDetermined: {
            // NSLog(@"User still thinking..");
        } break;
        case kCLAuthorizationStatusDenied: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location services not authorized"
                                                            message:@"This app needs you to authorize locations services to work."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            [locationManager startUpdatingLocation];
        } break;
        default:
            break;
    }
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

- (IBAction)onStatusClick:(id)sender {
    SingleRideViewController *singleRideViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SingleRideViewController"];
    [self.navigationController pushViewController:singleRideViewController animated:YES];
}

- (IBAction)onRequest:(id)sender {
    CreateViewController *createViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateViewController"];
    [self.navigationController pushViewController:createViewController animated:YES];
}
@end
