//
//  SingleRideViewController.h
//  Wipp
//

#import <UIKit/UIKit.h>


@interface SingleRideViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) NSString *startValue;
@property (strong, nonatomic) NSString *destinationValue;
@property (strong, nonatomic) NSString *costValue;
@property (strong, nonatomic) NSString *statusValue;

@end
