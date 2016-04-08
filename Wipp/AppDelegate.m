//
//  AppDelegate.m
//  Wipp
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

#import "AppDelegate.h"
#import "RegisterViewController.h"
#import "defs.h"
#import "MBProgressHUD.h"
#import "UIViewControllerAdditions.h"


MBProgressHUD *hud;

@interface AppDelegate ()<UIAlertViewDelegate>
@end

@implementation AppDelegate
@synthesize dictProfileInfo;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    // Override point for customization after application launch.
    
    // Hide status bar on splash page
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    // White status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Dark keyboard
    [[UITextField appearance] setKeyboardAppearance:UIKeyboardAppearanceDark];
    
    [NSThread sleepForTimeInterval:1];
    
    dictProfileInfo = [[NSMutableDictionary alloc]init];
    
    if(GetUserEmail == nil){
        RegisterViewController *registerViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RegisterViewController"];
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:registerViewController];
        self.window.rootViewController = navController;
    }
    
    // Facebook
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(fbAccessTokenDidChange:)
//                                                 name:FBSDKAccessTokenDidChangeNotification
//                                               object:nil];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    [FBSDKLoginButton class];
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    
    return YES;
}

#pragma mark - Facebook methods

//- (void)fbAccessTokenDidChange:(NSNotification*)notification{
//    if ([notification.name isEqualToString:FBSDKAccessTokenDidChangeNotification]) {
//        
//        FBSDKAccessToken* oldToken = [notification.userInfo valueForKey: FBSDKAccessTokenChangeOldKey];
//        FBSDKAccessToken* newToken = [notification.userInfo valueForKey: FBSDKAccessTokenChangeNewKey];
//        
////        NSLog(@"FB access token did change notification\nOLD token:\t%@\nNEW token:\t%@", oldToken.tokenString, newToken.tokenString);
//        
//        // initial token setup when user is logged in
//        if (newToken != nil && oldToken == nil) {
//            
//            // check the expiration data
//            
//            // IF token is not expired
//            // THEN log user out
//            // ELSE sync token with the server
//            
//            NSDate *nowDate = [NSDate date];
//            NSDate *fbExpirationDate = [FBSDKAccessToken currentAccessToken].expirationDate;
//            if ([fbExpirationDate compare:nowDate] != NSOrderedDescending) {
////                NSLog(@"FB token: expired");
//                
//                // this means user launched the app after 60+ days of inactivity,
//                // in this case FB SDK cannot refresh token automatically, so
//                // you have to walk user thought the initial log in with FB flow
//                
//                // for the sake of simplicity, just logging user out from Facebook here
//                [self logoutFacebook];
//            }
//            else {
//                [self syncFacebookAccessTokenWithServer];
//            }
//        }
//        
//        // change in token string
//        else if (newToken != nil && oldToken != nil
//                 && ![oldToken.tokenString isEqualToString:newToken.tokenString]) {
////            NSLog(@"FB access token string did change");
//            
//            [self syncFacebookAccessTokenWithServer];
//        }
//        
//        // moving from "logged in" state to "logged out" state
//        // e.g. user canceled FB re-login flow
//        else if (newToken == nil && oldToken != nil) {
////            NSLog(@"FB access token string did become nil");
//        }
//        
//        // upon token did change event we attempting to get FB profile info via current token (if exists)
//        // this gives us an ability to check via OG API that the current token is valid
//        [self requestFacebookUserInfo];
//    }
//}
//
//- (void)logoutFacebook {
//    if ([FBSDKAccessToken currentAccessToken]) {
//        [[FBSDKLoginManager new] logOut];
//    }
//}
//
//- (void)syncFacebookAccessTokenWithServer {
//    if (![FBSDKAccessToken currentAccessToken]) {
//        // returns if empty token
//        return;
//    }
//}
//
//- (void)requestFacebookUserInfo {
//    if (![FBSDKAccessToken currentAccessToken]) {
//        // returns if empty token
//        return;
//    }
//    
//    NSDictionary* parameters = @{@"fields": @"id, name, first_name, last_name, picture.width(100).height(100)"};
//    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
//                                                                   parameters:parameters];
//    
//    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//        if (!error) {
//            if ([result objectForKey:@"name"]) {
//                NSString *fullName = [result objectForKey:@"name"];
//                SetUserFullName(fullName);
////                nameLabel.text = fullName;
//            }
//            
//            // Profile Picture
//            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=200&height=200", [result objectForKey:@"id"]]];
//            NSString *url_string = [NSString stringWithFormat:@"%@", url];
////            [profileImg loadImageFromURL:url_string withTempImage:@"avatar"];
//            SetProfilePic(url_string);
//        }
//        else {
//            // First time an error occurs, FB SDK will attemt to recover from it automatically
//            // via FBSDKGraphErrorRecoveryProcessor (see documentation)
//            
//            // you can process an error manually, if you wish, by setting
//            // -setGraphErrorRecoveryDisabled to YES
//            
//            NSInteger statusCode = [(NSString *)error.userInfo[FBSDKGraphRequestErrorHTTPStatusCodeKey] integerValue];
//            if (statusCode == 400) {
//                // access denied
//            }
//        }
//    }];
//}

#pragma mark - Static Methods

+(AppDelegate*) getDelegate{
    return (AppDelegate *)[[UIApplication sharedApplication]delegate];
}

+(void)showMessage:(NSString *)message{
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Message"
                                                          message:message
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles: nil];
    [myAlertView show];
}

#pragma mark - ActivityIndicator methods

-(void)hideHUDForView:(UIView *)view {
    HideNetworkActivityIndicator();
    [MBProgressHUD hideHUDForView:self.window animated:YES];    //view
}

-(void)showHUDAddedTo:(UIView *)view {
    ShowNetworkActivityIndicator();
    hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];  //view
    hud.labelText = @"";
}

-(void)showHUDAddedToView:(UIView *)view message:(NSString *)message {
    [self hideHUDForView:view];
    ShowNetworkActivityIndicator();
    hud = [MBProgressHUD showHUDAddedTo:view animated:YES];  //view
    hud.labelText = message;
}

-(void)showHUDAddedToView2:(UIView *)view message:(NSString *)message {
    [self hideHUDForView:view];
    ShowNetworkActivityIndicator();
    hud = [MBProgressHUD showHUDAddedTo:view animated:YES];  //view
    hud.labelText = message;
}

-(void)showHUDAddedTo:(UIView *)view message:(NSString *)message {
    [self hideHUDForView:view];
    ShowNetworkActivityIndicator();
    hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];  //view
    hud.labelText = message;
}

-(void)hideHUDForView2:(UIView *)view {
    HideNetworkActivityIndicator();
    [MBProgressHUD hideHUDForView:view animated:YES];    //view
}

-(void)UpdateMessage:(NSString *)message {
    if(hud != nil && hud.labelText != nil)
        hud.labelText = message;
}

#pragma mark - Facebook Actions

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

#pragma mark - Validation Methods

+(BOOL)validateEmail:(NSString *)email{
    email = [email lowercaseString];
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    NSPredicate *regexPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL myStringMatchesRegex = [regexPredicate evaluateWithObject:email];
    return myStringMatchesRegex;
}

+(BOOL)isValidCharacter:(NSString*)string filterCharSet:(NSString*)set {
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:set] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filtered];
}

+(BOOL)validateMobileNum:(NSString *)mobileNum{
    NSString *mobileNumRegex = @"^(\\([0-9]{3})\\) [0-9]{3}-[0-9]{4}$";
    
    NSPredicate *regexPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileNumRegex];
    BOOL myStringMatchesRegex = [regexPredicate evaluateWithObject:mobileNum];
    return myStringMatchesRegex;
}

-(NSString*)formatNumber:(NSString*)mobileNumber{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSInteger length = [mobileNumber length];
    if(length > 10) {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
    }
    return mobileNumber;
}

+(BOOL)validateFullName:(NSString *)fullName{
    NSString *fullNameRegex = @"^[\\sa-zA-Z'-]*$";
    
    NSPredicate *regexPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", fullNameRegex];
    BOOL myStringMatchesRegex = [regexPredicate evaluateWithObject:fullName];
    return myStringMatchesRegex;
}

-(int)getLength:(NSString*)mobileNumber{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSInteger length = [mobileNumber length];
    return length;
}

-(void)userLogout{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserEmail"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserPassword"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserFullName"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"ActiveRequest"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"ActiveDrive"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"StartValue"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"DestinationValue"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"CostValue"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"CurrentLocation"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserIsDriver"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserID"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"ReservationId"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"ProfilePic"];
    
    RegisterViewController *registerViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:registerViewController];
    self.window.rootViewController = navController;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
