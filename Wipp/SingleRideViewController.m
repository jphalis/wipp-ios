//
//  SingleRideViewController.m
//  Wipp
//

#import "defs.h"
#import "GlobalFunctions.h"
#import "SingleRideViewController.h"
#import "SWRevealViewController.h"
#import "UIViewControllerAdditions.h"


@interface SingleRideViewController () <UIActionSheetDelegate> {
    __weak IBOutlet UILabel *startLocLabel;
    __weak IBOutlet UILabel *destinationLabel;
    __weak IBOutlet UILabel *costLabel;
    __weak IBOutlet UILabel *statusLabel;
    __weak IBOutlet UIButton *cancelBtn;
}
- (IBAction)cancelRequest:(id)sender;

@end

@implementation SingleRideViewController
@synthesize sidebarButton, startValue, destinationValue, costValue, statusValue;

- (void)viewDidLoad {
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
    
    if(GetActiveRequest){
        cancelBtn.layer.borderWidth = 3;
        cancelBtn.layer.borderColor = [[UIColor redColor] CGColor];
        cancelBtn.layer.cornerRadius = 7;
    } else {
        cancelBtn.hidden = YES;
        cancelBtn.enabled = NO;
    }
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
    checkNetworkReachability();
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *strURL = [NSString stringWithFormat:@"%@%ld/", RESCANCELURL, (long)GetReservationId];
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
                    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                                  initWithTitle:@"Are you sure you want to canel this reservation?"
                                                  delegate:self
                                                  cancelButtonTitle:nil // @"Cancel"
                                                  destructiveButtonTitle:nil
                                                  otherButtonTitles:@"Yes", @"No", nil];
                    [actionSheet showInView:self.view];
                } else {
                     showServerError();
                }
                [self setBusy:NO];
            } else {
                [self setBusy:NO];
                showServerError();
            }
            [self setBusy:NO];
        }];
    });
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        costLabel.text = @"$0.00";
        statusLabel.text = @"Canceled";
        cancelBtn.hidden = YES;
        cancelBtn.enabled = NO;
        SetActiveRequest(NO);
    } else {
        return;
    }
}

@end
