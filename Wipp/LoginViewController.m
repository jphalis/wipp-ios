//
//  LoginViewController.m
//  Wipp
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "defs.h"
#import "ForgotViewController.h"
#import "GlobalFunctions.h"
#import "SCLAlertView.h"
#import "StringUtil.h"
#import "SVModalWebViewController.h"
#import "UIViewControllerAdditions.h"


#define kOFFSET_FOR_KEYBOARD 0.65


@interface LoginViewController ()<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    __weak IBOutlet UILabel *pageTitle;
    __weak IBOutlet UIView *viewLogin;
    __weak IBOutlet UIButton *btnSignupInner;
    __weak IBOutlet UIButton *btnSignInner;
    __weak IBOutlet NSLayoutConstraint *consSignupX;
    __weak IBOutlet NSLayoutConstraint *consLoginX;
    
    //Signin TxtFields
    __weak IBOutlet UITextField *txtLoginPass;
    __weak IBOutlet UITextField *txtLoginUsrName;
    __weak IBOutlet UIButton *showSigninPass;
}
- (IBAction)onForgot:(id)sender;
- (IBAction)doSignIn:(id)sender;
- (IBAction)doShowSigninPass:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    self.automaticallyAdjustsScrollViewInsets = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    pageTitle.text = @"Sign in";
    UIButton *btnSel = (UIButton*)[self.view viewWithTag:1];
    UIButton *btnUel = (UIButton*)[self.view viewWithTag:2];
    [btnSel setSelected:YES];
    [btnUel setSelected:NO];
    
    btnSignInner.layer.borderWidth = 2;
    btnSignInner.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnSignInner.layer.cornerRadius = 7;
    
    viewLogin.hidden = NO;
    self.navigationController.navigationBarHidden = YES;
    
    //Custom Placeholder Color
    UIColor *color = [UIColor whiteColor];
    txtLoginUsrName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"username" attributes:@{NSForegroundColorAttributeName: color}];
    
    txtLoginPass.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"password" attributes:@{NSForegroundColorAttributeName: color}];
    
    // Gradient
    UIColor *topColor = [UIColor colorWithRed:(135/255.0) green:(8/255.0) blue:(12/255.0) alpha:1.0];
    UIColor *bottomColor = [UIColor colorWithRed:(180/255.0) green:(77/255.0) blue:(62/255.0) alpha:1.0];
    CAGradientLayer *theViewGradient = [CAGradientLayer layer];
    theViewGradient.colors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    theViewGradient.frame = self.view.frame;
    [self.view.layer insertSublayer:theViewGradient atIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onForgot:(id)sender {
    [self.view endEditing:YES];
    ForgotViewController *forgotViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ForgotViewController"];
    [self.navigationController pushViewController:forgotViewController animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger length = [textField.text length] - range.length + [string length];
   
    if(textField == txtLoginUsrName){
        BOOL isValidChar = [AppDelegate isValidCharacter:string filterCharSet:USERNAME];
        return isValidChar && length <= 30;
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
    
    if(textField == txtLoginPass){
        showSigninPass.hidden = NO;
    } else {
        showSigninPass.hidden = YES;
    }
    
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
    if (txtLoginUsrName){
        [txtLoginUsrName resignFirstResponder];
        [txtLoginPass becomeFirstResponder];
    }
}

-(void)previousTextField:(UIBarButtonItem *)sender{
    if (txtLoginPass) {
        [txtLoginPass resignFirstResponder];
        [txtLoginUsrName becomeFirstResponder];
    }
}

-(void)resignKeyboard {
    [txtLoginUsrName resignFirstResponder];
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
    
    txtLoginUsrName.text = [txtLoginUsrName.text lowercaseString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *params = [NSString stringWithFormat:@"username=%@&password=%@",[txtLoginUsrName.text Trim],[txtLoginPass.text Trim]];
        
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
                         SetUserName([JSONValue objectForKey:@"user"]);
                         SetUserID([[JSONValue objectForKey:@"userid"]integerValue]);
                         SetUserToken([JSONValue objectForKey:@"token"]);
                         SetUserActive([[JSONValue objectForKey:@"userid"]integerValue]);
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
    NSString *urlString = [NSString stringWithFormat:@"%@%@/",PROFILEURL,GetUserName];
    NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                             timeoutInterval:60];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserName, GetUserPassword];
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
                 
                 SetUserName([JSONValue objectForKey:@"username"]);
                 SetUserFullName([JSONValue objectForKey:@"full_name"]);
                 NSString *profilePic;
                 if([JSONValue objectForKey:@"profile_picture"] == [NSNull null]){
                     profilePic = @"";
                 } else {
                     profilePic=[JSONValue objectForKey:@"profile_picture"];
                 }
                 SetProifilePic(profilePic);

                 [self setBusy:NO];
             } else {
                 //[self setBusy:NO];
                 //[self showMessage:SERVER_ERROR];
             }
         } else {
            // [refreshControl endRefreshing];
            // [self setBusy:NO];
             //[self showMessage:SERVER_ERROR];
         }
     }];
}

-(void)pushingView:(BOOL)animation{
    MainViewController *revealViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RevealViewController"];
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
    txtLoginUsrName.text = @"";
}

-(BOOL)validateFields{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    if ([[txtLoginUsrName.text Trim] isEmpty]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_USERNAME closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([[txtLoginUsrName.text Trim] length] < 3) {
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:USERNAME_MIN_LEGTH closeButtonTitle:@"OK" duration:0.0f];
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
