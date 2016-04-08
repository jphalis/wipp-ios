//
//  CreateViewController.m
//  Wipp
//

#import "CreateViewController.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "MapViewController.h"
#import "SCLAlertView.h"
#import "StringUtil.h"
#import "SWRevealViewController.h"
#import "TWMessageBarManager.h"
#import "UIViewControllerAdditions.h"


#define kOFFSET_FOR_KEYBOARD 0.25


@interface CreateViewController ()<CLLocationManagerDelegate, UIActionSheetDelegate> {
    
    __weak IBOutlet UITextField *startLocationLabel;
    __weak IBOutlet UITextField *destinationLabel;
    __weak IBOutlet UITextField *payLabel;
    __weak IBOutlet UITextField *intervalLabel;
    __weak IBOutlet UIImageView *locationImg;
    
    NSArray *intervalData;
    NSString *longitudeValue;
    NSString *latitudeValue;
}
@property (strong, nonatomic) UIDatePicker *pickerView;
- (IBAction)getLocationCurrent:(id)sender;
- (IBAction)requestRide:(id)sender;
@end

@implementation CreateViewController {
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Create Reservation";
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController){
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    // Swipe right to go back to previous screen
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
    
    // Initialize location features
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    
    // Time picker
    self.pickerView = [[UIDatePicker alloc] init];
    self.pickerView.datePickerMode = UIDatePickerModeTime; // UIDatePickerModeDateAndTime
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h:mm a"];
    intervalLabel.text = [timeFormatter stringFromDate:self.pickerView.date];
    [self.pickerView addTarget:self action:@selector(updateTimeLabel:)
         forControlEvents:UIControlEventValueChanged];
    [intervalLabel setInputView:self.pickerView];
}

-(void)viewWillAppear:(BOOL)animated{
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    [super viewWillAppear:YES];
    locationImg.layer.cornerRadius = 7;
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

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TextField Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.tag == 0){
        [destinationLabel becomeFirstResponder];
        [startLocationLabel resignFirstResponder];
    } else if (textField.tag == 1){
        [payLabel becomeFirstResponder];
        [destinationLabel resignFirstResponder];
    } else if (textField.tag == 2){
        [intervalLabel becomeFirstResponder];
        [payLabel resignFirstResponder];
    } else if (textField.tag == 3){
        [intervalLabel resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    UIToolbar *keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    keyboardToolBar.tag = textField.tag;
    keyboardToolBar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *bar1 = [[UIBarButtonItem alloc]initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousTextField:)];
    bar1.tag = textField.tag;
    [bar1 setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    
    UIBarButtonItem *bar2 = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextTextField:)];
    bar2.tag = textField.tag;
    [bar2 setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    
    UIBarButtonItem *bar3 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    bar3.tag = textField.tag;
    [bar3 setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    
    UIBarButtonItem *bar4 =
    [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(resignKeyboard)];
    bar4.tag = textField.tag;
    [bar4 setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    
    [keyboardToolBar setItems: [NSArray arrayWithObjects: bar1,bar2,bar3,bar4,nil]];
    textField.inputAccessoryView = keyboardToolBar;
    
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self animateTextField:textField up:NO];
}

- (void)animateTextField:(UITextField*)textField up: (BOOL) up{
    float val;
    
    if(self.view.frame.size.height == 480){
        val = 0.75;
    } else {
        val = kOFFSET_FOR_KEYBOARD;
    }
    
    const int movementDistance = val * textField.frame.origin.y;
    const float movementDuration = 0.3f;
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)nextTextField:(UIBarButtonItem *)sender {
    if(sender.tag == 0){
        [startLocationLabel resignFirstResponder];
        [destinationLabel becomeFirstResponder];
    } else if(sender.tag == 1) {
        [destinationLabel resignFirstResponder];
        [payLabel becomeFirstResponder];
    } else if(sender.tag == 2) {
        [payLabel resignFirstResponder];
        [intervalLabel becomeFirstResponder];
    } else if(sender.tag == 3) {
        [intervalLabel resignFirstResponder];
    }
}

-(void)previousTextField:(UIBarButtonItem *)sender{
    if(sender.tag == 3){
        [intervalLabel resignFirstResponder];
        [payLabel becomeFirstResponder];
    } else if(sender.tag == 2){
        [payLabel resignFirstResponder];
        [destinationLabel becomeFirstResponder];
    } else if(sender.tag == 1){
        [destinationLabel resignFirstResponder];
        [startLocationLabel becomeFirstResponder];
    }
}

-(void)resignKeyboard {
    [startLocationLabel resignFirstResponder];
    [destinationLabel resignFirstResponder];
    [payLabel resignFirstResponder];
    [intervalLabel resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(void)clearFields{
    startLocationLabel.text = @"";
    destinationLabel.text = @"";
    payLabel.text = @"";
    intervalLabel.text = @"";
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if(textField == payLabel){
        NSString *cleanCentString = [[textField.text
                                      componentsSeparatedByCharactersInSet:
                                      [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                     componentsJoinedByString:@""];
        NSInteger centAmount = cleanCentString.integerValue;

        if (string.length > 0){
            // Digit added
            centAmount = centAmount * 10 + string.integerValue;
        } else {
            // Digit deleted
            centAmount = centAmount / 10;
        }
        // Update call amount value
        NSNumber *amount = [[NSNumber alloc] initWithFloat:(float)centAmount / 100.0f];
        
        // Write amount with currency symbols to the textfield
        NSNumberFormatter *_currencyFormatter = [[NSNumberFormatter alloc] init];
        [_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [_currencyFormatter setCurrencyCode:@"USD"];
        [_currencyFormatter setNegativeFormat:@"-¤#,##0.00"];
        textField.text = [_currencyFormatter stringFromNumber:amount];
        return NO;
    }
    return YES;
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    // NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        longitudeValue = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        latitudeValue = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
    
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
    
    // NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        // NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            startLocationLabel.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                 placemark.subThoroughfare, placemark.thoroughfare,
                                 placemark.postalCode, placemark.locality,
                                 placemark.administrativeArea,
                                 placemark.country];
        } else {
            // NSLog(@"%@", error.debugDescription);
        }
    } ];
    
}

#pragma mark - Picker view for time

-(void)updateTimeLabel:(UIDatePicker *)sender {
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h:mm a"];
    intervalLabel.text = [timeFormatter stringFromDate:self.pickerView.date];
}

#pragma mark - Submit methods

- (IBAction)getLocationCurrent:(id)sender {
    [self resignKeyboard];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Do you want to use your current location?"
                                  delegate:self
                                  cancelButtonTitle:nil // @"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Yes", @"No", nil];
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        [locationManager startUpdatingLocation];
        [locationManager requestWhenInUseAuthorization];
        startLocationLabel.enabled = NO;
        startLocationLabel.textColor = [UIColor lightGrayColor];
    } else {
        startLocationLabel.enabled = YES;
        startLocationLabel.text = @"";
        longitudeValue = nil;
        latitudeValue = nil;
    }
}

- (IBAction)requestRide:(id)sender {
    if([self validateFields]){
        [self doCreateRequest];
    }
}

-(BOOL)validateFields{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    if ([[startLocationLabel.text Trim] isEmpty]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_START_LOCATION closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([[destinationLabel.text Trim] isEmpty]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_DESTINATION closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([[payLabel.text Trim] isEmpty]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_PAYMENT closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([[intervalLabel.text Trim] isEmpty]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_PICKUP_INTERVAL closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    return YES;
}

-(void)doCreateRequest{
    checkNetworkReachability();
    [self.view endEditing:YES];
    [self setBusy:YES];
    
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    
    // Convert payment value to a float
    NSString *payAmount = [payLabel.text Trim];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    payAmount = [payAmount stringByReplacingOccurrencesOfString:formatter.internationalCurrencySymbol withString:@""];
    float fval = [formatter numberFromString:payAmount].floatValue;
    NSString *formattedNumber = [NSString stringWithFormat:@"%.02f", fval];
    
    // Check if current location or input address is being used for starting location
    if(latitudeValue && longitudeValue){
        [_params setObject:latitudeValue forKey:@"start_lat"];
        [_params setObject:longitudeValue forKey:@"start_long"];
    } else {
        [_params setObject:[startLocationLabel.text Trim] forKey:@"start_query"];
    }
    
    [_params setObject:[destinationLabel.text Trim] forKey:@"destination_query"];
    [_params setObject:formattedNumber forKey:@"start_amount"];
    [_params setObject:[intervalLabel.text Trim] forKey:@"pick_up_interval"];
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    NSString *urlStr = [NSString stringWithFormat:@"%@", CREATEURL];
    NSURL *requestURL = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setURL:requestURL];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        if ([data length] > 0 && error == nil){
            [self setBusy:NO];
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            
            if(JSONValue != nil){
                if ([JSONValue objectForKey:@"error_message"]){
                    SCLAlertView *alert = [[SCLAlertView alloc] init];
                    alert.showAnimationType = SlideInFromLeft;
                    alert.hideAnimationType = SlideOutToBottom;
                    [alert showNotice:self title:@"Notice" subTitle:[JSONValue objectForKey:@"error_message"] closeButtonTitle:@"OK" duration:0.0f];
                } else {
                    SetActiveRequest(YES);
                    MapViewController *mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
                    mapViewController.reservationID = [JSONValue objectForKey:@"id"];
                    [self.navigationController pushViewController:mapViewController animated:YES];
                }
            } else {
                showServerError();
            }
        } else {
            [self setBusy:NO];
            showServerError();
        }
        [self setBusy:NO];
    }];
}

@end
