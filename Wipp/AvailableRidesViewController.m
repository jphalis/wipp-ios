//
//  AvailableRidesViewController.m
//

#import "AvailableRidesViewController.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "RideClass.h"
#import "SingleRideViewController.h"
#import "SWRevealViewController.h"
#import "TableViewCellRides.h"
#import "UIViewControllerAdditions.h"


@interface AvailableRidesViewController (){
    UIRefreshControl *refreshControl;
    NSMutableArray *arrRides;
}

@end

@implementation AvailableRidesViewController

- (void)viewDidLoad {
    arrRides = [[NSMutableArray alloc]init];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh)
             forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    self.title = @"Rides Needed";
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController){
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    [self getRideDetails];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

-(void)getRideDetails{
    checkNetworkReachability();
    [self setBusy:YES];
    
    NSString *urlString = [NSString stringWithFormat:@"%@", RESURL];
    NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                             timeoutInterval:60];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [_request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        if ([data length] > 0 && error == nil){
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if([JSONValue isKindOfClass:[NSDictionary class]]){
                
                if ([[JSONValue objectForKey:@"results"] isKindOfClass:[NSArray class]]){
                    NSArray *arrRideResult = [JSONValue objectForKey:@"results"];
                
                    if([JSONValue count] > 0){
                        for (int i = 0; i < arrRideResult.count; i++) {
                            NSMutableDictionary *dictResult;
                            dictResult = [[NSMutableDictionary alloc]init];
                            dictResult = [arrRideResult objectAtIndex:i];
                            RideClass *rideClass = [[RideClass alloc]init];
                            rideClass.rideId = [dictResult objectForKey:@"id"];
                            rideClass.reservation_url = [dictResult objectForKey:@"reservation_url"];
                            rideClass.user = [dictResult objectForKey:@"user"];
                            rideClass.user_phone_number = [dictResult objectForKey:@"user_phone_number"];
                            if ([dictResult objectForKey:@"driver"] == [NSNull null]){
                                rideClass.driver = @"";
                            } else {
                                rideClass.driver = [dictResult objectForKey:@"driver"];
                            }
                            if ([dictResult objectForKey:@"driver_phone_number"] == [NSNull null]){
                                rideClass.driver_phone_number = @"";
                            } else {
                                rideClass.driver_phone_number = [dictResult objectForKey:@"driver_phone_number"];
                            }
                            rideClass.status_verbose = [dictResult objectForKey:@"status_verbose"];
                            rideClass.pick_up_interval = [dictResult objectForKey:@"pick_up_interval"];
                            rideClass.start_amount = [dictResult objectForKey:@"start_amount"];
                            rideClass.final_amount = [dictResult objectForKey:@"final_amount"];
                            rideClass.start_query = [dictResult objectForKey:@"start_query"];
                            rideClass.destination_query = [dictResult objectForKey:@"destination_query"];
                            rideClass.start_long = [dictResult objectForKey:@"start_long"];
                            rideClass.start_lat = [dictResult objectForKey:@"start_lat"];
                            rideClass.end_long = [dictResult objectForKey:@"end_long"];
                            rideClass.end_lat = [dictResult objectForKey:@"end_lat"];
                            // rideClass.start_address = [dictResult objectForKey:@"start_address"];
                            // rideClass.destination_address = [dictResult objectForKey:@"destination_address"];
                            rideClass.travel_distance = [dictResult objectForKey:@"travel_distance"];
                        
                            [arrRides addObject:rideClass];
                        }
                        [self setBusy:NO];
                        [self showRides];
                    } else {
                        [refreshControl endRefreshing];
                        [self setBusy:NO];
                        // lblWaterMark.hidden = NO;
                        // lblWaterMark.text = [NSString stringWithFormat:@"%@", [JSONValue objectForKey:@"detail"]];
                    }
                } else {
                    [self setBusy:NO];
                }
            } else {
                [self setBusy:NO];
            }
        } else {
            [refreshControl endRefreshing];
            [self setBusy:NO];
            showServerError();
        }
    }];
}

-(void)startRefresh{
    if(arrRides.count > 0){
        [arrRides removeAllObjects];
    }
    [self getRideDetails];
}

-(void)showRides{
    [refreshControl endRefreshing];
    [self.tableView reloadData];
//    lblWaterMark.hidden = YES;
//    lblWaterMark.text = @"";
}

-(void)scrollToTop{
    [UIView animateWithDuration:0.2 animations:^(void){
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrRides count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TableViewCellRides *cell = [tableView dequeueReusableCellWithIdentifier:@"RideCell" forIndexPath:indexPath];
    if(arrRides.count <= 0){
        return cell;
    }
    
    RideClass *rideClass = [arrRides objectAtIndex:indexPath.row];
    cell.pickupTimeLabel.text = rideClass.pick_up_interval;
    cell.distanceLabel.text = rideClass.travel_distance;
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:(234/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
    [cell.contentView addSubview:bottomBorder];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RideClass *rideClass = [arrRides objectAtIndex:indexPath.row];
    
    SingleRideViewController *singleRideViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SingleRideViewController"];
    singleRideViewController.startValue = rideClass.start_query;
    singleRideViewController.destinationValue = rideClass.destination_query;
    singleRideViewController.costValue = [NSString stringWithFormat:@"$%@", rideClass.start_amount];
    singleRideViewController.reservationID = rideClass.rideId;
    [self.navigationController pushViewController:singleRideViewController animated:YES];
}

@end
