//
//  AccountViewController.h
//  Wipp
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"


@interface AccountViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (strong, nonatomic) NSString *accountID;


@end
