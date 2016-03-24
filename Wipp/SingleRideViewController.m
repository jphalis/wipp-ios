//
//  SingleRideViewController.m
//  Wipp
//

#import "AvailableRidesViewController.h"
#import "defs.h"
#import "GlobalFunctions.h"
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
    __weak IBOutlet UILabel *requesterLabel;
    __weak IBOutlet UILabel *userLabel;
    __weak IBOutlet UILabel *driverTitleLabel;
    __weak IBOutlet UILabel *driverLabel;
    
    NSString *resIDForUse;
}
- (IBAction)cancelRequest:(id)sender;
- (IBAction)acceptRequest:(id)sender;
- (IBAction)completeTrip:(id)sender;

@end

@implementation SingleRideViewController
@synthesize sidebarButton, startValue, destinationValue, costValue, statusValue, reservationID;

- (void)viewDidLoad {
    if (startValue){
        startLocLabel.text = startValue;
    } else {
        startLocLabel.text = GetStartValue;
    }
    if (destinationValue){
        destinationLabel.text = destinationValue;
    } else {
        destinationLabel.text = GetDestinationValue;
    }
    if (costValue){
        costLabel.text = costValue;
    } else {
        costLabel.text = GetCostValue;
    }
    if (statusValue){
        statusLabel.text = statusValue;
    }
    
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
    [self getReservationDetails];
    
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    [super viewWillAppear:YES];
    
    
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
        costLabel.text = @"$0.00";
        statusLabel.text = @"Canceled";
        cancelBtn.hidden = YES;
        cancelBtn.enabled = NO;
        SetActiveRequest(NO);
        SetActiveDrive(NO);
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showSuccess:self title:@"Success" subTitle:@"Your request has been canceled." closeButtonTitle:@"OK" duration:0.0f];
        [alert alertIsDismissed:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        return;
    }
}

-(void)doCancelRequest {
    checkNetworkReachability();
    [self setBusy:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *strURL = [NSString stringWithFormat:@"%@%@/", RESCANCELURL, resIDForUse];
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
        NSString *strURL = [NSString stringWithFormat:@"%@%@/", RESACCEPTURL, resIDForUse];
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
                    SetReservationId(resIDForUse);
                    [[UIPasteboard generalPasteboard] setString:startLocLabel.text];
                    SCLAlertView *alert = [[SCLAlertView alloc] init];
                    alert.showAnimationType = SlideInFromLeft;
                    alert.hideAnimationType = SlideOutToBottom;
                    [alert showSuccess:self title:@"Accepted" subTitle:@"You have accepted the ride request. The pick up location has been copied to your clipboard." closeButtonTitle:@"OK" duration:0.0f];
                    [alert alertIsDismissed:^{
                        [self.navigationController popViewControllerAnimated:YES];
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
        NSString *strURL = [NSString stringWithFormat:@"%@%@/", RESCOMPLETEURL, resIDForUse];
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
                    [self setBusy:NO];
                    [self.navigationController popViewControllerAnimated:YES];
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
    
    if (reservationID){
        resIDForUse = reservationID;
    } else {
        resIDForUse = GetReservationId;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@/", RESURL, resIDForUse];
    NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                             timeoutInterval:60];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [_request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if(error != nil){
            [self setBusy:NO];
        }
        if ([data length] > 0 && error == nil){
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if([JSONValue isKindOfClass:[NSDictionary class]] && [JSONValue count] > 0){
                    
                if([JSONValue objectForKey:@"start_address"] == [NSNull null]){
                    startLocLabel.text = @"";
                } else {
                    startLocLabel.text = [JSONValue objectForKey:@"start_address"];
                }
                
                if([JSONValue objectForKey:@"destination_address"] == [NSNull null]){
                    destinationLabel.text = @"";
                } else {
                    destinationLabel.text = [JSONValue objectForKey:@"destination_address"];
                }
            
                if([JSONValue objectForKey:@"final_amount"] == [NSNull null]){
                    costLabel.text = @"";
                } else {
                    costLabel.text = [NSString stringWithFormat:@"$%@", [JSONValue objectForKey:@"start_amount"]];
                }
                        
                if([JSONValue objectForKey:@"user"] == [NSNull null]){
                    userLabel.text = @"";
                } else {
                    userLabel.text = [JSONValue objectForKey:@"user"];
                }
                    
                if([JSONValue objectForKey:@"driver"] == [NSNull null]){
                    driverLabel.text = @"";
                } else {
                    driverLabel.text = [JSONValue objectForKey:@"driver"];
                }
                        
                if([JSONValue objectForKey:@"status_verbose"] == [NSNull null]){
                    statusLabel.text = @"";
                } else {
                    statusLabel.text = [JSONValue objectForKey:@"status_verbose"];
                }
                
                if (GetActiveRequest){
                    cancelBtn.hidden = NO;
                    cancelBtn.enabled = YES;
                    cancelBtn.layer.borderWidth = 3;
                    cancelBtn.layer.borderColor = [[UIColor redColor] CGColor];
                    cancelBtn.layer.cornerRadius = 7;
                    
                    acceptBtn.hidden = YES;
                    acceptBtn.enabled = NO;
                    
                    completeBtn.hidden = YES;
                    completeBtn.enabled = NO;
                    
                    requesterLabel.hidden = YES;
                    userLabel.hidden = YES;
                    driverTitleLabel.hidden = YES;
                    driverLabel.hidden = YES;
                } else if (GetUserIsDriver && [statusLabel.text isEqual: @"Pending..."] && (GetUserFullName != userLabel.text)){
                    acceptBtn.hidden = NO;
                    acceptBtn.enabled = YES;
                    acceptBtn.layer.borderWidth = 3;
                    acceptBtn.layer.borderColor = [[UIColor greenColor] CGColor];
                    acceptBtn.layer.cornerRadius = 7;
                    
                    cancelBtn.hidden = YES;
                    cancelBtn.enabled = NO;
                    
                    completeBtn.hidden = YES;
                    completeBtn.enabled = NO;
                    
                    requesterLabel.hidden = YES;
                    userLabel.hidden = YES;
                    driverTitleLabel.hidden = YES;
                    driverLabel.hidden = YES;
                } else if ([statusLabel.text isEqual: @"Accepted"] && !GetActiveDrive){
                    cancelBtn.hidden = NO;
                    cancelBtn.enabled = YES;
                    
                    acceptBtn.hidden = YES;
                    acceptBtn.enabled = NO;
                    
                    completeBtn.hidden = YES;
                    completeBtn.enabled = NO;
                    
                    requesterLabel.hidden = NO;
                    userLabel.hidden = NO;
                    driverTitleLabel.hidden = NO;
                    driverLabel.hidden = NO;
                } else if ([statusLabel.text isEqual: @"Accepted"] && GetActiveDrive){
                    completeBtn.hidden = NO;
                    completeBtn.enabled = YES;
                    completeBtn.layer.borderWidth = 3;
                    completeBtn.layer.borderColor = [[UIColor greenColor] CGColor];
                    completeBtn.layer.cornerRadius = 7;
                    
                    cancelBtn.hidden = YES;
                    cancelBtn.enabled = NO;
                    
                    acceptBtn.hidden = YES;
                    acceptBtn.enabled = NO;
                    
                    requesterLabel.hidden = NO;
                    userLabel.hidden = NO;
                    driverTitleLabel.hidden = NO;
                    driverLabel.hidden = NO;
                } else if ([statusLabel.text isEqual: @"Completed"] || [statusLabel.text isEqual: @"Canceled"]){
                    cancelBtn.hidden = YES;
                    cancelBtn.enabled = NO;
                    
                    acceptBtn.hidden = YES;
                    acceptBtn.enabled = NO;
                    
                    completeBtn.hidden = YES;
                    completeBtn.enabled = NO;
                    
                    requesterLabel.hidden = NO;
                    userLabel.hidden = NO;
                    driverTitleLabel.hidden = NO;
                    driverLabel.hidden = NO;
                } else {
                    cancelBtn.hidden = YES;
                    cancelBtn.enabled = NO;
                    
                    acceptBtn.hidden = YES;
                    acceptBtn.enabled = NO;
                    
                    completeBtn.hidden = YES;
                    completeBtn.enabled = NO;
                    
                    requesterLabel.hidden = YES;
                    userLabel.hidden = YES;
                    driverTitleLabel.hidden = YES;
                    driverLabel.hidden = YES;
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
