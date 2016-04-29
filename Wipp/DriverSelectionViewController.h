//
//  DriverSelectionViewController.h
//  

#import <UIKit/UIKit.h>


@interface DriverSelectionViewController : UITableViewController

@property (strong, nonatomic) NSString *reservationID;
@property (strong, nonatomic) NSMutableArray *arrDrivers;

@end
