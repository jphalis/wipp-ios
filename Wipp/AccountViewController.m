//
//  AccountViewController.m
//  Wipp
//

#import "AccountViewController.h"
#import "defs.h"
#import "DriverSignupViewController.h"
#import "GlobalFunctions.h"
#import "SDIAsyncImageView.h"
#import "SWRevealViewController.h"
#import "UIViewControllerAdditions.h"
#import "UIImageView+WebCache.h"


@interface AccountViewController (){

    __weak IBOutlet UILabel *nameLabel;
    __weak IBOutlet SDIAsyncImageView *profileImg;
    __weak IBOutlet UIButton *drivePromptLabel;

}

- (IBAction)doDriverSignup:(id)sender;

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [self getProfileDetails];
    
    [super viewDidLoad];
    
    self.title = GetUserFullName;

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
    profileImg.layer.cornerRadius = profileImg.frame.size.width / 2;
    profileImg.layer.masksToBounds = YES;
    nameLabel.text = GetUserFullName;
    
    if (GetUserIsDriver){
        drivePromptLabel.hidden = YES;
        drivePromptLabel.enabled = NO;
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

-(void)startRefresh{
    [self getProfileDetails];
}

- (IBAction)doDriverSignup:(id)sender {
    DriverSignupViewController *driverSignupViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DriverSignupViewController"];
    [self.navigationController pushViewController:driverSignupViewController animated:YES];
}

-(void)getProfileDetails{
    checkNetworkReachability();
    [self setBusy:YES];
    
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
            
            if(JSONValue != nil){
                if ([JSONValue objectForKey:@"profile_picture"] == [NSNull null]){
                    profileImg.image = [UIImage imageNamed:@"avatar"];
                } else {
                    [profileImg loadImageFromURL:[JSONValue objectForKey:@"profile_picture"] withTempImage:@"avatar"];
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

@end
