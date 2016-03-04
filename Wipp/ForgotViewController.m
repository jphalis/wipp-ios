////
////  ForgotViewController.m
////
//
//#import "defs.h"
//#import "ForgotViewController.h"
//#import "GlobalFunctions.h"
//#import "SCLAlertView.h"
//#import "StringUtil.h"
//#import "TWMessageBarManager.h"
//
//
//@interface ForgotViewController (){
//    __weak IBOutlet UIButton *btnSubmit;
//    __weak IBOutlet UITextField *txtEmail;
//}
//- (IBAction)onBack:(id)sender;
//- (IBAction)onSubmit:(id)sender;
//@end
//
//@implementation ForgotViewController
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
//    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
//    [self.view addGestureRecognizer:viewRight];
//}
//
//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:YES];
//    
//    txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"email" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
//    
//    btnSubmit.layer.borderWidth = 2;
//    btnSubmit.layer.borderColor = [[UIColor whiteColor] CGColor];
//    btnSubmit.layer.cornerRadius = 7;
//    
//    // Gradient
//    UIColor *topColor = [UIColor colorWithRed:(59/255.0) green:(200/255.0) blue:(129/255.0) alpha:1.0];
//    UIColor *bottomColor = [UIColor colorWithRed:(74/255.0) green:(155/255.0) blue:(230/255.0) alpha:1.0];
//    CAGradientLayer *theViewGradient = [CAGradientLayer layer];
//    theViewGradient.colors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
//    theViewGradient.frame = self.view.bounds;
////    theViewGradient.startPoint = CGPointMake(0.0, 0.5);
////    theViewGradient.endPoint = CGPointMake(1.0, 0.5);
//    [self.view.layer insertSublayer:theViewGradient atIndex:0];
//}
//
//-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer{
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
///*
//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}
//*/
//
//- (IBAction)onBack:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
//- (IBAction)onSubmit:(id)sender {
//    if([self validateFields]){
//        [self doSubmit];
//    }
//}
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self.view endEditing:YES];
//}
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [txtEmail resignFirstResponder];
//    return YES;
//}
//
//-(BOOL)validateFields{
//    SCLAlertView *alert = [[SCLAlertView alloc] init];
//    
//    if ([[txtEmail.text Trim] isEmpty]){
//        alert.showAnimationType = SlideInFromLeft;
//        alert.hideAnimationType = SlideOutToBottom;
//        [alert showNotice:self title:@"Notice" subTitle:EMPTY_EMAIL closeButtonTitle:@"OK" duration:0.0f];
//        return NO;
//    }else if ([AppDelegate validateEmail:[txtEmail.text Trim]] == NO){
//        alert.showAnimationType = SlideInFromLeft;
//        alert.hideAnimationType = SlideOutToBottom;
//        [alert showNotice:self title:@"Notice" subTitle:INVALID_EMAIL closeButtonTitle:@"OK" duration:0.0f];
//        return NO;
//    }
//    return YES;
//}
//
//-(void)clearFileds{
//    txtEmail.text = @"";
//}
//
//-(void)doSubmit{
//    checkNetworkReachability();
//    [self.view endEditing:YES];
//    [self setBusy:YES];
//    
//    SCLAlertView *alert = [[SCLAlertView alloc] init];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSString *params = [NSString stringWithFormat:@"email=%@",[txtEmail.text Trim]];
//        NSMutableData *bodyData = [[NSMutableData alloc] initWithData:[params dataUsingEncoding:NSUTF8StringEncoding]];
//        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[bodyData length]];
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",FORGOTPASSURL]];
//        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
//        [urlRequest setTimeoutInterval:60];
//        [urlRequest setHTTPMethod:@"POST"];
//        [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
//        [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
//        [urlRequest setValue:@"multipart/form-data" forHTTPHeaderField:@"enctype"];
//        [urlRequest setHTTPBody:bodyData];
//
//        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 [self setBusy:NO];
//                                
//                 if ([data length] > 0 && error == nil){
//                     NSDictionary * JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//
//                     if([JSONValue isKindOfClass:[NSDictionary class]]){
//                         if([[JSONValue objectForKey:@"success"]isEqualToString:@"Password reset e-mail has been sent."]){
//                             alert.showAnimationType = SlideInFromLeft;
//                             alert.hideAnimationType = SlideOutToBottom;
//                             [alert showSuccess:self title:@"Success" subTitle:PASS_SENT closeButtonTitle:@"Done" duration:0.0f];
//                         } else {
//                             alert.showAnimationType = SlideInFromLeft;
//                             alert.hideAnimationType = SlideOutToBottom;
//                             [alert showNotice:self title:@"Notice" subTitle:PASS_FAILURE closeButtonTitle:@"OK" duration:0.0f];
//                         }
//                         [self clearFileds];
//                     } else {
//                         showServerError();
//                     }
//                 } else {
//                     showServerError();
//                     [self setBusy:NO];
//                 }
//             });
//        }];
//    });
//}
//
//@end
