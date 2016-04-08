//
//  SingleRideViewController.m
//  Wipp
//

#import "AvailableRidesViewController.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "MapViewController.h"
#import "SCLAlertView.h"
#import "SingleRideViewController.h"
#import "SWRevealViewController.h"
#import "UIViewControllerAdditions.h"


@interface SingleRideViewController () <UIActionSheetDelegate> {
    __weak IBOutlet UILabel *startLocLabel;
    __weak IBOutlet UILabel *destinationLabel;
    __weak IBOutlet UILabel *costLabel;
    __weak IBOutlet UILabel *statusLabel;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIButton *acceptBtn;
    __weak IBOutlet UIButton *completeBtn;
    __weak IBOutlet UILabel *userRoleLabel;
    __weak IBOutlet UILabel *userFullNameLabel;
    __weak IBOutlet UILabel *phoneNumberLabel;
    __weak IBOutlet UILabel *mutualFriendsLabel;
    __weak IBOutlet UILabel *pickUpTimeLabel;
    
    NSString *requester;
    NSString *requester_phone_number;
    NSString *driver;
    NSString *driver_phone_number;
}
- (IBAction)cancelRequest:(id)sender;
- (IBAction)acceptRequest:(id)sender;
- (IBAction)completeTrip:(id)sender;

@end

@implementation SingleRideViewController
@synthesize sidebarButton, startValue, destinationValue, costValue, statusValue, reservationID, pickUpTime;

- (void)viewDidLoad {
    [self getReservationDetails];
    
    startLocLabel.text = startValue;
    destinationLabel.text = destinationValue;
    costLabel.text = costValue;
    pickUpTimeLabel.text = pickUpTime;
    statusLabel.text = statusValue;
    
    [super viewDidLoad];
    
    self.title = @"Requested Ride";

    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController){
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    [super viewWillAppear:YES];
    
    MapViewController *mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    mapViewController.reservationID = reservationID;
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

- (IBAction)cancelRequest:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Are you sure you want to cancel this reservation?"
                                  delegate:self
                                  cancelButtonTitle:nil // @"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Yes", @"No", nil];
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self doCancelRequest];
        [self setBusy:NO];
        statusLabel.text = @"Canceled";
        cancelBtn.hidden = YES;
        SetActiveRequest(NO);
        SetActiveDrive(NO);
        
        MapViewController *mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
        mapViewController.reservationID = reservationID;
        
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showSuccess:self title:@"Success" subTitle:@"Your request has been canceled." closeButtonTitle:@"OK" duration:0.0f];
        [alert alertIsDismissed:^{
            // [self.navigationController popViewControllerAnimated:YES];
            [self.navigationController pushViewController:mapViewController animated:YES];
        }];
    } else {
        return;
    }
}

-(void)doCancelRequest {
    checkNetworkReachability();
    [self setBusy:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *strURL = [NSString stringWithFormat:@"%@%@/", RESCANCELURL, reservationID];
        NSURL *url = [NSURL URLWithString:strURL];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setTimeoutInterval:60];
        [urlRequest setHTTPMethod:@"POST"];
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
        NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [plainData base64EncodedStringWithOptions:0];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
        [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            
            if ([data length] > 0 && error == nil){
                NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if(JSONValue != nil){
                    [self setBusy:NO];
                } else {
                    [self setBusy:NO];
                }
            } else {
                [self setBusy:NO];
            }
            [self setBusy:NO];
            showServerError();
        }];
    });
}

- (IBAction)acceptRequest:(id)sender {
    checkNetworkReachability();
    [self setBusy:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *strURL = [NSString stringWithFormat:@"%@%@/", RESACCEPTURL, reservationID];
        NSURL *url = [NSURL URLWithString:strURL];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setTimeoutInterval:60];
        [urlRequest setHTTPMethod:@"POST"];
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
        NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [plainData base64EncodedStringWithOptions:0];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
        [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            
            if ([data length] > 0 && error == nil){
                NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if(JSONValue != nil){
                    [self setBusy:NO];
                    SetActiveDrive(YES);
                    
                    MapViewController *mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
                    mapViewController.reservationID = reservationID;
                    
                    [[UIPasteboard generalPasteboard] setString:startLocLabel.text];
                    SCLAlertView *alert = [[SCLAlertView alloc] init];
                    alert.showAnimationType = SlideInFromLeft;
                    alert.hideAnimationType = SlideOutToBottom;
                    [alert showSuccess:self title:@"Accepted" subTitle:@"You have accepted the ride request. The pick up location has been copied to your clipboard." closeButtonTitle:@"OK" duration:0.0f];
                    [alert alertIsDismissed:^{
                        // self.navigationController popViewControllerAnimated:YES];
                        [self.navigationController pushViewController:mapViewController animated:YES];
                    }];
                    return;
                } else {
                    [self setBusy:NO];
                    showServerError();
                }
            } else {
                [self setBusy:NO];
                showServerError();
            }
            [self setBusy:NO];
        }];
    });
}

- (IBAction)completeTrip:(id)sender {
    checkNetworkReachability();
    [self setBusy:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *strURL = [NSString stringWithFormat:@"%@%@/", RESCOMPLETEURL, reservationID];
        NSURL *url = [NSURL URLWithString:strURL];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setTimeoutInterval:60];
        [urlRequest setHTTPMethod:@"POST"];
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
        NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [plainData base64EncodedStringWithOptions:0];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
        [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            
            if ([data length] > 0 && error == nil){
                NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if(JSONValue != nil){
                    SetActiveDrive(NO);
                    MapViewController *mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
                    mapViewController.reservationID = reservationID;
                    [self setBusy:NO];
                    // [self.navigationController popViewControllerAnimated:YES];
                    [self.navigationController pushViewController:mapViewController animated:YES];
                } else {
                    [self setBusy:NO];
                }
            } else {
                [self setBusy:NO];
            }
            [self setBusy:NO];
            showServerError();
        }];
    });
}

-(void)getReservationDetails {
    [self setBusy:YES];

    NSString *urlString = [NSString stringWithFormat:@"%@%@/", RESURL, reservationID];
    NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                             timeoutInterval:60];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [_request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if (error != nil){
            [self setBusy:NO];
        }
        if ([data length] > 0 && error == nil){
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if ([JSONValue isKindOfClass:[NSDictionary class]] && [JSONValue count] > 0){
                    
                if ([JSONValue objectForKey:@"start_query"] == [NSNull null]){
                    startLocLabel.text = @"";
                } else {
                    startLocLabel.text = [JSONValue objectForKey:@"start_query"];
                }
                
                if ([JSONValue objectForKey:@"destination_query"] == [NSNull null]){
                    destinationLabel.text = @"";
                } else {
                    destinationLabel.text = [JSONValue objectForKey:@"destination_query"];
                }
            
                if ([JSONValue objectForKey:@"final_amount"] == [NSNull null]){
                    costLabel.text = @"";
                } else {
                    costLabel.text = [NSString stringWithFormat:@"$%@", [JSONValue objectForKey:@"start_amount"]];
                }
                        
                if ([JSONValue objectForKey:@"user"] == [NSNull null]){
                    requester = @"";
                } else {
                    requester = [JSONValue objectForKey:@"user"];
                }
                
                if ([JSONValue objectForKey:@"user_phone_number"] == [NSNull null]){
                    requester_phone_number = @"";
                } else {
                    requester_phone_number = [JSONValue objectForKey:@"user_phone_number"];
                }
                    
                if ([JSONValue objectForKey:@"driver"] == [NSNull null]){
                    driver = @"";
                } else {
                    driver = [JSONValue objectForKey:@"driver"];
                }
                
                if ([JSONValue objectForKey:@"driver_phone_number"] == [NSNull null]){
                    driver_phone_number = @"";
                } else {
                    driver_phone_number = [JSONValue objectForKey:@"driver_phone_number"];
                }
                        
                if ([JSONValue objectForKey:@"status_verbose"] == [NSNull null]){
                    statusLabel.text = @"";
                } else {
                    statusLabel.text = [JSONValue objectForKey:@"status_verbose"];
                }
                
                if ([JSONValue objectForKey:@"pick_up_interval"] == [NSNull null]){
                    pickUpTimeLabel.text = @"";
                } else {
                    pickUpTimeLabel.text = [JSONValue objectForKey:@"pick_up_interval"];
                }
                
                
                if ([statusLabel.text isEqual: @"Pending..."]){
                    if (GetUserFullName == requester){
                        // User looking at their own pending request
                        cancelBtn.hidden = NO;
                        cancelBtn.layer.borderWidth = 3;
                        cancelBtn.layer.borderColor = [[UIColor redColor] CGColor];
                        cancelBtn.layer.cornerRadius = 7;
                    } else {
                        // Driver looking at pending request
                        acceptBtn.hidden = NO;
                        acceptBtn.layer.borderWidth = 3;
                        acceptBtn.layer.borderColor = [[UIColor greenColor] CGColor];
                        acceptBtn.layer.cornerRadius = 7;
                    }
                } else if ([statusLabel.text isEqual: @"Accepted"]){
                    if (GetUserFullName == requester){
                        // User looking at their own accepted request
                        userRoleLabel.hidden = NO;
                        userFullNameLabel.hidden = NO;
                        phoneNumberLabel.hidden = NO;
//                        mutualFriendsLabel.hidden = NO;
                        
                        userRoleLabel.text = @"Driver:";
                        userFullNameLabel.text = driver;
                        phoneNumberLabel.text = driver_phone_number;
//                        mutualFriendsLabel.text = @"";
                        
                        cancelBtn.hidden = NO;
                        cancelBtn.layer.borderWidth = 3;
                        cancelBtn.layer.borderColor = [[UIColor redColor] CGColor];
                        cancelBtn.layer.cornerRadius = 7;
                    } else {
                        // Driver looking at accepted request
                        userRoleLabel.hidden = NO;
                        userFullNameLabel.hidden = NO;
                        phoneNumberLabel.hidden = NO;
//                        mutualFriendsLabel.hidden = NO;
                        
                        userRoleLabel.text = @"Requester:";
                        userFullNameLabel.text = requester;
                        phoneNumberLabel.text = requester_phone_number;
//                        mutualFriendsLabel.text = @"";
                        
                        completeBtn.hidden = NO;
                        completeBtn.layer.borderWidth = 3;
                        completeBtn.layer.borderColor = [[UIColor greenColor] CGColor];
                        completeBtn.layer.cornerRadius = 7;
                    }
                } else if ([statusLabel.text isEqual: @"Completed"]){
                    if (GetUserFullName == requester){
                        userRoleLabel.hidden = NO;
                        userFullNameLabel.hidden = NO;
                        phoneNumberLabel.hidden = NO;
//                        mutualFriendsLabel.hidden = NO;
                        
                        // User looking at completed request
                        userRoleLabel.text = @"Driver:";
                        userFullNameLabel.text = driver;
                        phoneNumberLabel.text = driver_phone_number;
//                        mutualFriendsLabel.text = @"";
                    } else {
                        // Driver looking at completed request
                        userRoleLabel.hidden = NO;
                        userFullNameLabel.hidden = NO;
                        phoneNumberLabel.hidden = NO;
//                        mutualFriendsLabel.hidden = NO;
                        
                        userRoleLabel.text = @"Requester:";
                        userFullNameLabel.text = requester;
                        phoneNumberLabel.text = requester_phone_number;
//                        mutualFriendsLabel.text = @"";
                    }
                } else if ([statusLabel.text isEqual: @"Canceled"]){
                    if (GetUserFullName == requester){
                        // User looking at canceled request
                        if (driver){
                            userRoleLabel.hidden = NO;
                            userFullNameLabel.hidden = NO;
                            
                            userRoleLabel.text = @"Driver:";
                            userFullNameLabel.text = driver;
                        }
                    } else {
                        // Driver looking at canceled request
                        userRoleLabel.hidden = NO;
                        userFullNameLabel.hidden = NO;
                        
                        userRoleLabel.text = @"Requester:";
                        userFullNameLabel.text = requester;
                    }
                } else {
                    // Someone is seeing things that shouldn't be
                }
                [self setBusy:NO];
            } else {
                [self setBusy:NO];
            }
        } else {
            [self setBusy:NO];
            showServerError();
        }
    }];
}

@end
