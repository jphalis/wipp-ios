//
//  LoginViewController.m
//  Wipp
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MapViewController.h"
#import "defs.h"
#import "ForgotViewController.h"
#import "GlobalFunctions.h"
#import "SCLAlertView.h"
#import "StringUtil.h"
#import "SVModalWebViewController.h"
#import "UIViewControllerAdditions.h"


#define kOFFSET_FOR_KEYBOARD 0.65


@interface LoginViewController ()<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    __weak IBOutlet UIView *viewLogin;
    __weak IBOutlet UIButton *btnSignInner;
    __weak IBOutlet NSLayoutConstraint *consLoginX;
    
    //Signin TxtFields
    __weak IBOutlet UITextField *txtLoginEmail;
    __weak IBOutlet UITextField *txtLoginPass;
    __weak IBOutlet UIButton *showSigninPass;
}
- (IBAction)onBack:(id)sender;
- (IBAction)onForgot:(id)sender;
- (IBAction)doSignIn:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    self.automaticallyAdjustsScrollViewInsets = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    UIButton *btnSel = (UIButton*)[self.view viewWithTag:1];
    UIButton *btnUel = (UIButton*)[self.view viewWithTag:2];
    [btnSel setSelected:YES];
    [btnUel setSelected:NO];
    
    btnSignInner.layer.borderWidth = 2;
    btnSignInner.layer.borderColor = [[UIColor colorWithRed:255.0/255 green:131.0/255 blue:0.0/255 alpha:1.0] CGColor];
    btnSignInner.layer.cornerRadius = 7;
    
    viewLogin.hidden = NO;
    self.navigationController.navigationBarHidden = YES;
    
    //Custom Placeholder Color
    UIColor *color = [UIColor whiteColor];
    txtLoginEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    
    txtLoginPass.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onForgot:(id)sender {
    [self.view endEditing:YES];
    ForgotViewController *forgotViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ForgotViewController"];
    [self.navigationController pushViewController:forgotViewController animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger length = [textField.text length] - range.length + [string length];
   
    if(textField == txtLoginEmail){
        BOOL isValidChar = [AppDelegate isValidCharacter:string filterCharSet:EMAIL];
        return isValidChar && length <= 80;
    }
    return YES;
}

//TextField Delegate Methods

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.tag == 5){
        [txtLoginPass becomeFirstResponder];
    } else if (textField.tag == 6){
        [txtLoginPass resignFirstResponder];
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
    if (txtLoginEmail){
        [txtLoginEmail resignFirstResponder];
        [txtLoginPass becomeFirstResponder];
    }
}

-(void)previousTextField:(UIBarButtonItem *)sender{
    if (txtLoginPass) {
        [txtLoginPass resignFirstResponder];
        [txtLoginEmail becomeFirstResponder];
    }
}

-(void)resignKeyboard {
    [txtLoginEmail resignFirstResponder];
    [txtLoginPass resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)doSignIn:(id)sender{
    checkNetworkReachability();
    if ([self validateFields] == YES){
        [self doLogin];
    }
}

-(void)doLogin{
    [self.view endEditing:YES];
    [self setBusy:YES];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    txtLoginEmail.text = [txtLoginEmail.text lowercaseString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *params = [NSString stringWithFormat:@"email=%@&password=%@",[txtLoginEmail.text Trim],[txtLoginPass.text Trim]];
        
        NSMutableData *bodyData = [[NSMutableData alloc] initWithData:[params dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[bodyData length]];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",LOGINURL]];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setTimeoutInterval:60];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [urlRequest setValue:@"multipart/form-data" forHTTPHeaderField:@"enctype"];
        [urlRequest setHTTPBody:bodyData];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self setBusy:NO];

                 if ([data length] > 0 && error == nil){
                     NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                     
                     if([[JSONValue objectForKey:@"userid"]integerValue]>0){
                         SetUserID([[JSONValue objectForKey:@"userid"]integerValue]);
                         SetUserToken([JSONValue objectForKey:@"token"]);
                         SetUserEmail([txtLoginEmail.text Trim]);
                         SetUserPassword([txtLoginPass.text Trim]);
                         [self performSelectorInBackground:@selector(getProfileDetails) withObject:nil];
                         [self pushingView:YES];
                     } else {
                         alert.showAnimationType = SlideInFromLeft;
                         alert.hideAnimationType = SlideOutToBottom;
                         [alert showNotice:self title:@"Notice" subTitle:JSONValue[@"non_field_errors"][0] closeButtonTitle:@"OK" duration:0.0f];
                     }
                 } else {
                     showServerError();
                     [self setBusy:NO];
                 }
             });
         }];
    });
}

-(void)getProfileDetails{
    NSString *urlString = [NSString stringWithFormat:@"%@%ld/", PROFILEURL, (long)GetUserID];
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
       
             if([JSONValue isKindOfClass:[NSDictionary class]]){
                 
                 if([JSONValue allKeys].count == 1 && [JSONValue objectForKey:@"detail"]){
                     [self setBusy:NO];
                     return;
                 }
            
                 SetUserEmail([JSONValue objectForKey:@"email"]);
                 SetUserFullName([JSONValue objectForKey:@"full_name"]);

                 [self setBusy:NO];
             } else {
                 [self setBusy:NO];
             }
         } else {
             [self setBusy:NO];
         }
     }];
}

-(void)pushingView:(BOOL)animation{
    MapViewController *revealViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RevealViewController"];
    [self.navigationController pushViewController:revealViewController animated:animation];
}

- (IBAction)onTermsClick:(id)sender{
    if([sender tag] == 22){
        checkNetworkReachability();
        
        // Opens TERMSURL in a modal view
        SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:[NSString stringWithFormat:@"%@",TERMSURL]];
        [self presentViewController:webViewController animated:YES completion:NULL];
        
        // Opens TERMSURL in Safari
        // [[UIApplication sharedApplication]openURL:[NSURL URLWithString:TERMSURL]];
    } else {
        checkNetworkReachability();
        
        // Opens PRIVACYURL in a modal view
        SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:[NSString stringWithFormat:@"%@",PRIVACYURL]];
        [self presentViewController:webViewController animated:YES completion:NULL];
        
        // Opens PRIVACYURL in Safari
        // [[UIApplication sharedApplication]openURL:[NSURL URLWithString:PRIVACYURL]];
    }
}

- (IBAction)doShowSigninPass:(id)sender {
    if(viewLogin.hidden == NO){
        if (txtLoginPass){
            txtLoginPass.secureTextEntry = NO;
        }
    } else {
        return;
    }
}

-(void)clearFields{
    txtLoginPass.text = @"";
    txtLoginEmail.text = @"";
}

-(BOOL)validateFields{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    if ([[txtLoginEmail.text Trim] isEmpty]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_EMAIL closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([[txtLoginPass.text Trim] isEmpty]) {
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_PASSWORD closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([[txtLoginPass.text Trim] length] < 5 ) {
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:PASS_MIN_LEGTH closeButtonTitle:@"OK" duration:0.0f];
        return NO ;
    }
    return YES;
}

@end
