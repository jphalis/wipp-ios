//
//  AccountViewController.m
//  Wipp
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

#import "AccountViewController.h"
#import "AvailableRidesViewController.h"
#import "defs.h"
#import "DriverSignupViewController.h"
#import "GlobalFunctions.h"
#import "SDIAsyncImageView.h"
#import "SWRevealViewController.h"
#import "UIViewControllerAdditions.h"
#import "UIImageView+WebCache.h"


@interface AccountViewController (){

    __weak IBOutlet UILabel *nameLabel;
    __weak IBOutlet UILabel *universityLabel;
    __weak IBOutlet SDIAsyncImageView *profileImg;
    __weak IBOutlet UIButton *drivePromptLabel;
    __weak IBOutlet UIButton *fbSyncBtn;

}

- (IBAction)doDriverSignup:(id)sender;

@end

@implementation AccountViewController

@synthesize accountID;

- (void)viewDidLoad {
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fbAccessTokenDidChange:)
                                                 name:FBSDKAccessTokenDidChangeNotification
                                               object:nil];
    [self getProfileDetails];
    
    [super viewDidLoad];
    
    self.title = GetUserFullName;

    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController){
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    // Handle clicks on the Facebook button
    [fbSyncBtn
     addTarget:self
     action:@selector(fbSyncBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    [self requestFacebookUserInfo];
    
    [super viewWillAppear:YES];
    [profileImg loadImageFromURL:GetProfilePic withTempImage:@"avatar"];
    profileImg.layer.cornerRadius = profileImg.frame.size.width / 2;
    profileImg.layer.masksToBounds = YES;
    nameLabel.text = GetUserFullName;
    universityLabel.text = GetUniversity;
    
    fbSyncBtn.layer.cornerRadius = 7;
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

-(void)startRefresh{
    [self getProfileDetails];
}

- (IBAction)doDriverSignup:(id)sender {
//    DriverSignupViewController *driverSignupViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DriverSignupViewController"];
//    [self.navigationController pushViewController:driverSignupViewController animated:YES];
    
    AvailableRidesViewController *availableRidesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AvailableRidesViewController"];
    [self.navigationController pushViewController:availableRidesViewController animated:YES];
}

-(void)getProfileDetails{
    checkNetworkReachability();
    [self setBusy:YES];
    
    NSString *accountId;
    
    if ([NSString stringWithFormat:@"%ld", (long)GetUserID] == accountID){
        accountId = [NSString stringWithFormat:@"%ld", (long)GetUserID];
    } else if (accountID == nil){
        accountId = [NSString stringWithFormat:@"%ld", (long)GetUserID];
    } else {
        accountId = accountID;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/", PROFILEURL, accountId];
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
            
            if(JSONValue != nil){
                universityLabel.text = [JSONValue objectForKey:@"university"];
                
                if ([JSONValue objectForKey:@"profile_picture"] == [NSNull null]){
                    profileImg.image = [UIImage imageNamed:@"avatar"];
                } else {
                    [profileImg loadImageFromURL:[JSONValue objectForKey:@"profile_picture"] withTempImage:@"avatar"];
                    if (GetProfilePic == nil) {
                        SetProfilePic([JSONValue objectForKey:@"profile_picture"]);
                    }
                }
                SetUserIsDriver([[JSONValue objectForKey:@"is_driver"]boolValue]);
                [self setBusy:NO];
            } else {
                [self setBusy:NO];
                showServerError();
            }
        } else {
            [self setBusy:NO];
            showServerError();
        }
    }];
}

-(void)fbSyncBtnClicked{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
//             NSLog(@"Process error");
         } else if (result.isCancelled) {
//             NSLog(@"Cancelled");
         } else {
             // NSLog(@"Logged in");
             FBSDKGraphRequest *requestMe = [[FBSDKGraphRequest alloc]initWithGraphPath:@"me" parameters:@{@"fields": @"name, first_name, last_name, id"}];
             FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
             [connection addRequest:requestMe completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 
                 if(result){
//                     if ([result objectForKey:@"email"]) {
//                         NSLog(@"Email: %@",[result objectForKey:@"email"]);
//                     }
//                     if ([result objectForKey:@"first_name"]) {
//                         NSLog(@"First Name : %@",[result objectForKey:@"first_name"]);
//                     }
//                     if ([result objectForKey:@"last_name"]) {
//                         NSLog(@"Last Name : %@",[result objectForKey:@"last_name"]);
//                     }
//                     if ([result objectForKey:@"id"]) {
//                         NSLog(@"User id : %@",[result objectForKey:@"id"]);
//                     }
                     
                     // Full name
                     if ([result objectForKey:@"name"]) {
                         NSString *fullName = [result objectForKey:@"name"];
                         SetUserFullName(fullName);
                         nameLabel.text = fullName;
                     }
                     
                     // Profile Picture
                     NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=200&height=200", [result objectForKey:@"id"]]];
                     NSString *url_string = [NSString stringWithFormat:@"%@", url];
                     [profileImg loadImageFromURL:url_string withTempImage:@"avatar"];
                     SetProfilePic(url_string);
                 }
                 
             }];
             [connection start];
         }
     }];
}

- (void)fbAccessTokenDidChange:(NSNotification*)notification{
    if ([notification.name isEqualToString:FBSDKAccessTokenDidChangeNotification]) {
        
        FBSDKAccessToken *oldToken = [notification.userInfo valueForKey: FBSDKAccessTokenChangeOldKey];
        FBSDKAccessToken *newToken = [notification.userInfo valueForKey: FBSDKAccessTokenChangeNewKey];
        
//        NSLog(@"FB access token did change notification\nOLD token:\t%@\nNEW token:\t%@", oldToken.tokenString, newToken.tokenString);
        
        // initial token setup when user is logged in
        if (newToken != nil && oldToken == nil) {
            
            // check the expiration data
            
            // IF token is not expired
            // THEN log user out
            // ELSE sync token with the server
            
            NSDate *nowDate = [NSDate date];
            NSDate *fbExpirationDate = [FBSDKAccessToken currentAccessToken].expirationDate;
            if ([fbExpirationDate compare:nowDate] != NSOrderedDescending) {
//                NSLog(@"FB token: expired");
                
                // this means user launched the app after 60+ days of inactivity,
                // in this case FB SDK cannot refresh token automatically, so
                // you have to walk user thought the initial log in with FB flow
                
                // for the sake of simplicity, just logging user out from Facebook here
                [self logoutFacebook];
            } else {
                [self syncFacebookAccessTokenWithServer];
                fbSyncBtn.hidden = YES;
            }
        }
        
        // change in token string
        else if (newToken != nil && oldToken != nil
                 && ![oldToken.tokenString isEqualToString:newToken.tokenString]) {
//                    NSLog(@"FB access token string did change");
            
            [self syncFacebookAccessTokenWithServer];
            fbSyncBtn.hidden = YES;
        }
        
        // moving from "logged in" state to "logged out" state
        // e.g. user canceled FB re-login flow
        else if (newToken == nil && oldToken != nil) {
//            NSLog(@"FB access token string did become nil");
        }
        
        // upon token did change event we attempting to get FB profile info via current token (if exists)
        // this gives us an ability to check via OG API that the current token is valid
        [self requestFacebookUserInfo];
    }
}

- (void)logoutFacebook {
    if ([FBSDKAccessToken currentAccessToken]) {
        [[FBSDKLoginManager new] logOut];
    }
}

- (void)syncFacebookAccessTokenWithServer {
    if (![FBSDKAccessToken currentAccessToken]) {
        return;
    }
}

- (void)requestFacebookUserInfo {
    if (![FBSDKAccessToken currentAccessToken]) {
        return;
    }
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, first_name, last_name, picture.width(200).height(200)"}];
    
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            if ([result objectForKey:@"name"]) {
                NSString *fullName = [result objectForKey:@"name"];
                SetUserFullName(fullName);
                nameLabel.text = fullName;
            }
            
            // Profile Picture
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=200&height=200", [result objectForKey:@"id"]]];
            NSString *url_string = [NSString stringWithFormat:@"%@", url];
            [profileImg loadImageFromURL:url_string withTempImage:@"avatar"];
            SetProfilePic(url_string);

            fbSyncBtn.hidden = YES;
        } else {
            NSInteger statusCode = [(NSString *)error.userInfo[FBSDKGraphRequestErrorHTTPStatusCodeKey] integerValue];
            if (statusCode == 400) {
                // access denied
            }
        }
    }];
}

@end
