//
//  RegisterViewController.m
//  Wipp
//

#import "AppDelegate.h"
#import "RegisterViewController.h"
#import "MainViewController.h"
#import "defs.h"
#import "ForgotViewController.h"
#import "GlobalFunctions.h"
#import "SCLAlertView.h"
#import "StringUtil.h"
#import "SVModalWebViewController.h"
#import "UIViewControllerAdditions.h"


#define kOFFSET_FOR_KEYBOARD 0.65


@interface RegisterViewController ()<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    __weak IBOutlet UILabel *pageTitle;
    __weak IBOutlet UIView *viewSignUp;
    __weak IBOutlet UIButton *btnSignupInner;
    __weak IBOutlet UIButton *btnSignInner;
    __weak IBOutlet NSLayoutConstraint *consSignupX;
    __weak IBOutlet NSLayoutConstraint *consLoginX;
    
    //Signup Txtfields
    __weak IBOutlet UITextField *txtSignupVerifyPass;
    __weak IBOutlet UITextField *txtSignupPass;
    __weak IBOutlet UITextField *txtSignupUsrName;
    __weak IBOutlet UITextField *txtSignupEmail;
    __weak IBOutlet UIButton *showSignupPass;
    __weak IBOutlet UIButton *showVerifyPass;

}
- (IBAction)doSignUp:(id)sender;
- (IBAction)onTermsClick:(id)sender;
- (IBAction)doShowSignupPass:(id)sender;
- (IBAction)doShowVerifyPass:(id)sender;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    self.automaticallyAdjustsScrollViewInsets = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    pageTitle.text = @"Register";
    UIButton *btnSel = (UIButton*)[self.view viewWithTag:1];
    UIButton *btnUel = (UIButton*)[self.view viewWithTag:2];
    [btnSel setSelected:YES];
    [btnUel setSelected:NO];
    
    btnSignupInner.layer.borderWidth = 2;
    btnSignupInner.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnSignupInner.layer.cornerRadius = 7;
    
    viewSignUp.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
    
    //Custom Placeholder Color
    UIColor *color = [UIColor whiteColor];
    txtSignupUsrName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"username" attributes:@{NSForegroundColorAttributeName: color}];
    
    txtSignupEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"email" attributes:@{NSForegroundColorAttributeName: color}];
    
    txtSignupPass.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"create password" attributes:@{NSForegroundColorAttributeName: color}];
    
    txtSignupVerifyPass.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"verify password" attributes:@{NSForegroundColorAttributeName: color}];
    
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
   
    if(textField == txtSignupUsrName){
        txtSignupUsrName.text = txtSignupUsrName.text.lowercaseString;
        BOOL isValidChar = [AppDelegate isValidCharacter:string filterCharSet:USERNAME];
        return isValidChar && length <= 30;
    }
    if(textField == txtSignupEmail){
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
    if (textField.tag == 1){
        [txtSignupEmail becomeFirstResponder];
    } else if(textField.tag == 2) {
        [txtSignupPass becomeFirstResponder];
    } else if(textField.tag == 3) {
        [txtSignupVerifyPass becomeFirstResponder];
    } else if(textField.tag == 4 ) {
        [txtSignupVerifyPass resignFirstResponder];
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
    
    if(textField == txtSignupPass){
        showSignupPass.hidden = NO;
    } else {
        showSignupPass.hidden = YES;
    }
    if(textField == txtSignupVerifyPass){
        showVerifyPass.hidden = NO;
    } else {
        showVerifyPass.hidden = YES;
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
    if(sender.tag == 1){
        [txtSignupUsrName resignFirstResponder];
        [txtSignupEmail becomeFirstResponder];
    } else if(sender.tag == 2) {
        [txtSignupEmail resignFirstResponder];
        [txtSignupPass becomeFirstResponder];
    } else if(sender.tag == 3) {
        [txtSignupPass resignFirstResponder];
        [txtSignupVerifyPass becomeFirstResponder];
    }
}

-(void)previousTextField:(UIBarButtonItem *)sender{
    if(sender.tag == 4){
        [txtSignupVerifyPass resignFirstResponder];
        [txtSignupPass becomeFirstResponder];
    } else if(sender.tag == 3){
        [txtSignupPass resignFirstResponder];
        [txtSignupEmail becomeFirstResponder];
    } else if(sender.tag == 2){
        [txtSignupEmail resignFirstResponder];
        [txtSignupUsrName becomeFirstResponder];
    }
}

-(void)resignKeyboard {
    [txtSignupUsrName resignFirstResponder];
    [txtSignupVerifyPass resignFirstResponder];
    [txtSignupPass resignFirstResponder];
    [txtSignupEmail resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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

- (IBAction)doSignUp:(id)sender{
    if ([self validateFields] == YES){
        [self doRegister];
    }
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

- (IBAction)doShowSignupPass:(id)sender {
    if (txtSignupPass){
        txtSignupPass.secureTextEntry = NO;
    }
}

- (IBAction)doShowVerifyPass:(id)sender {
    if (txtSignupVerifyPass){
        txtSignupVerifyPass.secureTextEntry = NO;
    }
}


-(void)doRegister{
    checkNetworkReachability();
    [self.view endEditing:YES];
    [self setBusy:YES];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    NSString *usname = [[txtSignupUsrName.text Trim] lowercaseString];
    NSString *params = [NSString stringWithFormat:@"{\"username\":\"%@\",\"email\":\"%@\",\"password\":\"%@\"}",usname,[txtSignupEmail.text Trim],[txtSignupPass.text Trim]];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[params length]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",SIGNUPURL]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:60];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"" forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // [urlRequest setValue:@"multipart/form-data" forHTTPHeaderField:@"enctype"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
         if ([data length] > 0 && error == nil){
             NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
             if(JSONValue != nil){
                 
                 if([[JSONValue allKeys]count] > 1){
                     
                     if([[JSONValue objectForKey:@"username"] isKindOfClass:[NSString class]]){
                         SetUserName([JSONValue objectForKey:@"username"]);
                         SetUserMail([JSONValue objectForKey:@"email"]);
                         SetUserID([[JSONValue objectForKey:@"id"]integerValue]);
                         SetUserPassword([txtSignupPass.text Trim]);
                         [self getUserId];
                         [self performSelectorInBackground:@selector(getProfileDetails) withObject:nil];
                         [self pushingView:YES];
                     } else {
                         alert.showAnimationType = SlideInFromLeft;
                         alert.hideAnimationType = SlideOutToBottom;
                         [alert showNotice:self title:@"Notice" subTitle:USER_EXISTS_ANOTHER_USER closeButtonTitle:@"OK" duration:0.0f];
                     }
                 } else {
                     if([[[JSONValue allKeys]objectAtIndex:0]isEqualToString:@"username"]){
                         alert.showAnimationType = SlideInFromLeft;
                         alert.hideAnimationType = SlideOutToBottom;
                         [alert showNotice:self title:@"Notice" subTitle:USER_EXISTS_ANOTHER_USER closeButtonTitle:@"OK" duration:0.0f];
                     } else if([[[JSONValue allKeys]objectAtIndex:0]isEqualToString:@"email"]){
                         alert.showAnimationType = SlideInFromLeft;
                         alert.hideAnimationType = SlideOutToBottom;
                         [alert showNotice:self title:@"Notice" subTitle:EMAIL_EXISTS_ANOTHER_USER closeButtonTitle:@"OK" duration:0.0f];
                     } else {
                         showServerError();
                     }
                 }
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
}

-(void)getUserId{
    
}

-(void)clearFields{
    txtSignupEmail.text = @"";
    txtSignupPass.text = @"";
    txtSignupUsrName.text = @"";
    txtSignupVerifyPass.text = @"";
}

-(BOOL)validateFields{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    if ([[txtSignupUsrName.text Trim] isEmpty]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_USERNAME closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([[txtSignupUsrName.text Trim] length] < 3){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:USERNAME_MIN_LEGTH closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([[txtSignupEmail.text Trim] isEmpty]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_EMAIL closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([AppDelegate validateEmail:[txtSignupEmail.text Trim]] == NO){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:INVALID_EMAIL closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([[txtSignupPass.text Trim] isEmpty]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_PASSWORD closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([[txtSignupVerifyPass.text Trim] isEmpty]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_CNF_PASSWORD closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([[txtSignupPass.text Trim] length] < 5 || [[txtSignupVerifyPass.text Trim] length] < 5 ){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:PASS_MIN_LEGTH closeButtonTitle:@"OK" duration:0.0f];
        return NO ;
    } else if (![[txtSignupPass.text Trim] isEqualToString:[txtSignupVerifyPass.text Trim]]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:PASS_MISMATCH closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    return YES;
}

@end
