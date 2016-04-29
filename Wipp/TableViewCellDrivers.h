//
//  TableViewCellDrivers.h
//

#import <UIKit/UIKit.h>

#import "SDIAsyncImageView.h"


@interface TableViewCellDrivers : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *driverNameLabel;
@property (weak, nonatomic) IBOutlet SDIAsyncImageView *driverProPic;


@end
