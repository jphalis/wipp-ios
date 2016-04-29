//
//  DriverSelectionViewController.m
//

#import "AccountViewController.h"
#import "DriverSelectionViewController.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "RideClass.h"
#import "SingleRideViewController.h"
#import "TableViewCellDrivers.h"
#import "UIViewControllerAdditions.h"


@interface DriverSelectionViewController (){
    NSString *driverID;
}

@end

@implementation DriverSelectionViewController

@synthesize reservationID, arrDrivers;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Select Driver";
}

-(void)viewWillAppear:(BOOL)animated{
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    if(arrDrivers.count > 0){
        [self scrollToTop];
    }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrDrivers count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TableViewCellDrivers *cell = [tableView dequeueReusableCellWithIdentifier:@"DriverCell" forIndexPath:indexPath];

    if(arrDrivers.count <= 0){
        return cell;
    }
    
    NSMutableDictionary *dictDriver = [arrDrivers objectAtIndex:indexPath.row];
    cell.driverNameLabel.text = [dictDriver objectForKey:@"driver__full_name"];
    [cell.driverProPic loadImageFromURL:[dictDriver objectForKey:@"driver__profile_picture"] withTempImage:@"avatar"];
    // cell.driverProPic.layer.cornerRadius = cell.driverProPic.frame.size.width / 2;
    cell.driverProPic.layer.cornerRadius = 7;
    cell.driverProPic.layer.masksToBounds = YES;
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:(234/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
    [cell.contentView addSubview:bottomBorder];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dictDriverDeatil = [arrDrivers objectAtIndex:indexPath.row];
    int userId = [[dictDriverDeatil objectForKey:@"driver__id"]intValue];
    driverID = [NSString stringWithFormat:@"%d", userId];
    
    [self acceptDriver];
}

-(void)scrollToTop{
    [UIView animateWithDuration:0.2 animations:^(void){
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }];
}

- (void)acceptDriver{
    checkNetworkReachability();
    [self setBusy:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *strURL = [NSString stringWithFormat:@"%@%@/%@/", DRIVERFOUNDURL, reservationID, driverID];
        NSURL *url = [NSURL URLWithString:strURL];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setTimeoutInterval:60];
        [urlRequest setHTTPMethod:@"POST"];
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
        NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [plainData base64EncodedStringWithOptions:0];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
        [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            
            if ([data length] > 0 && error == nil){
                NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if(JSONValue != nil){
                    [self setBusy:NO];
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [self setBusy:NO];
                    showServerError();
                }
            } else {
                [self setBusy:NO];
                showServerError();
            }
            [self setBusy:NO];
        }];
    });
}

@end
