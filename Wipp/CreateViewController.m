//
//  CreateViewController.m
//  Wipp
//

#import "CreateViewController.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "SCLAlertView.h"
#import "StringUtil.h"
#import "SWRevealViewController.h"
#import "TWMessageBarManager.h"
#import "UIViewControllerAdditions.h"


#define kOFFSET_FOR_KEYBOARD 0.25


@interface CreateViewController ()<CLLocationManagerDelegate, UIActionSheetDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    
    __weak IBOutlet UILabel *latitudeLabel;
    __weak IBOutlet UILabel *longitudeLabel;
    __weak IBOutlet UILabel *addressLabel;
    __weak IBOutlet UITextField *startLocationLabel;
    __weak IBOutlet UITextField *destinationLabel;
    __weak IBOutlet UITextField *payLabel;
    __weak IBOutlet UITextField *intervalLabel;
    
    NSArray *intervalData;
}
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *pickerElements;

- (IBAction)getCurrentLocation:(id)sender;
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
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
    
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    
//    UIPickerView *picker = [[UIPickerView alloc] init];
//    picker.dataSource = self;
//    picker.delegate = (id)self;
//    intervalLabel.inputView = picker;
//    intervalData = @[@"5 mins", @"10 mins", @"15 mins", @"20 mins"];
    
    
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.showsSelectionIndicator = YES;
    intervalLabel.inputView = self.pickerView;
    
    self.pickerElements = @[@"5 mins", @"10 mins", @"15 mins", @"20 mins"];
    [self pickerView:self.pickerView
        didSelectRow:0
         inComponent:0];
}

-(void)viewWillAppear:(BOOL)animated{
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
        longitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        latitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
    
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
    
    // NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        // NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            addressLabel.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                 placemark.subThoroughfare, placemark.thoroughfare,
                                 placemark.postalCode, placemark.locality,
                                 placemark.administrativeArea,
                                 placemark.country];
        } else {
            // NSLog(@"%@", error.debugDescription);
        }
    } ];
    
}

#pragma mark - Actions

- (IBAction)getCurrentLocation:(id)sender {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    [locationManager requestWhenInUseAuthorization];
}

#pragma mark - Picker view for time interval

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.pickerElements count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.pickerElements objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    intervalLabel.text = [self.pickerElements objectAtIndex:row];
}

#pragma mark - Action sheet for time interval

// need to create a button to go with function setTimeInterval

//- (IBAction)setTimeInterval:(id)sender {
//    UIActionSheet *actionSheet = [[UIActionSheet alloc]
//                                  initWithTitle:@"How long until you want to be picked up?"
//                                       delegate:self
//                              cancelButtonTitle:@"Cancel"
//                         destructiveButtonTitle:nil
//                              otherButtonTitles:@"5 mins", @"10 mins", @"15 mins", nil];
//    [actionSheet showInView:self.view];
//    actionSheet.tag = 10;
//}
//
//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if (actionSheet.tag == 10) {
//        NSLog(@"The Normal action sheet.");
//    } else {
//        NSLog(@"The Color selection action sheet.");
//    }
//    
//    NSLog(@"Index = %ld - Title = %@", (long)buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
//}
//
//-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
//    if (actionSheet.tag == 10) {
//        NSLog(@"From didDismissWithButtonIndex - Selected Color: %@", [actionSheet buttonTitleAtIndex:buttonIndex]);
//    }
//}

@end
