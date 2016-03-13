//
//  MobileNumViewController.m
//

#import "defs.h"
#import "MobileNumViewController.h"
#import "GlobalFunctions.h"
#import "MapViewController.h"
#import "SCLAlertView.h"
#import "StringUtil.h"
#import "TWMessageBarManager.h"
#import "UIViewControllerAdditions.h"


#define kOFFSET_FOR_KEYBOARD 0.55


@interface MobileNumViewController (){
    __weak IBOutlet UIButton *btnSubmit;
    __weak IBOutlet UITextField *txtFullName;
    __weak IBOutlet UITextField *txtMobileNum;
    
}
- (IBAction)onBack:(id)sender;
- (IBAction)onSubmit:(id)sender;
@end

@implementation MobileNumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    txtFullName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Full Name" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    txtMobileNum.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"(XXX) XXX-XXXX" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer{
    [self.navigationController popViewControllerAnimated:YES];
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
    
    [keyboardToolBar setItems: [NSArray arrayWithObjects:
                                bar1,bar2,bar3,bar4,
                                nil]];
    
    textField.inputAccessoryView = keyboardToolBar;
    
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self animateTextField: textField up: NO];
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
    if(sender.tag == 1){
        [txtFullName resignFirstResponder];
        [txtMobileNum becomeFirstResponder];
    }
}

-(void)previousTextField:(UIBarButtonItem *)sender{
    if(sender.tag == 2){
        [txtMobileNum resignFirstResponder];
        [txtFullName becomeFirstResponder];
    }
}

-(void)resignKeyboard {
    [txtFullName resignFirstResponder];
    [txtMobileNum resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 1){
        [txtMobileNum becomeFirstResponder];
    } else {
        [txtMobileNum resignFirstResponder];
    }
    return YES;
}

-(void)clearFileds{
    txtMobileNum.text = @"";
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)pushingView:(BOOL)animation{
    MapViewController *revealViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RevealViewController"];
    [self.navigationController pushViewController:revealViewController animated:animation];
}

- (IBAction)onSubmit:(id)sender {
    if([self validateFields]){
        [self doAddMobile];
    }
}

-(void)doAddMobile{
    checkNetworkReachability();
    [self.view endEditing:YES];
    [self setBusy:YES];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    
    [_params setObject:GetUserEmail forKey:@"email"];
    [_params setObject:[txtFullName.text Trim] forKey:@"full_name"];
    [_params setObject:[txtMobileNum.text Trim] forKey:@"phone_number"];
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSString *urlStr = [NSString stringWithFormat:@"%@%ld/", PROFILEURL, (long)GetUserID];
    NSURL *requestURL = [NSURL URLWithString:urlStr];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"PUT"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    [request setURL:requestURL];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        if ([data length] > 0 && error == nil){
            [self setBusy:NO];
            
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            
            if([JSONValue isKindOfClass:[NSDictionary class]]){

                if([JSONValue allKeys].count > 3){
                    SetisUpdate(YES);
                    SetUserFullName([txtFullName.text Trim]);
                    SetMobileNum([txtMobileNum.text Trim]);
                    [self pushingView:YES];
                } else if ([JSONValue objectForKey:@"phone_number"]){
                    alert.showAnimationType = SlideInFromLeft;
                    alert.hideAnimationType = SlideOutToBottom;
                    [alert showNotice:self title:@"Notice" subTitle:VERIFICATION_MOBILE_EXISTS closeButtonTitle:@"OK" duration:0.0f];
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

-(BOOL)validateFields{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    if ([[txtMobileNum.text Trim] isEmpty]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_MOBILE closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([AppDelegate validateMobileNum:[txtMobileNum.text Trim]] == NO){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:INVALID_MOBILE closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([[txtFullName.text Trim] isEmpty]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_NAME closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([AppDelegate validateFullName:[txtFullName.text Trim]] == NO){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:INVALID_NAME closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField == txtMobileNum){
        int length = (int)[self getLength:textField.text];

        if(length == 10){
            if(range.length == 0){
                return NO;
            }
        }

        if(length == 3){
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"(%@) ",num];

            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
        } else if(length == 6){
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];

            if(range.length > 0){
                textField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
            }
        }
    }
    return YES;
}

- (NSString *)formatNumber:(NSString *)mobileNumber{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];

    int length = (int)[mobileNumber length];
    if(length > 10){
        mobileNumber = [mobileNumber substringFromIndex: length-10];
    }
    return mobileNumber;
}

- (int)getLength:(NSString *)mobileNumber{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];

    int length = (int)[mobileNumber length];
    return length;
}

@end
