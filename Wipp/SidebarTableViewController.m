//
//  SidebarTableViewController.m
//  Wipp
//

#import "AppDelegate.h"
#import "defs.h"
#import "SidebarTableViewController.h"
#import "SWRevealViewController.h"


@interface SidebarTableViewController (){
    AppDelegate *appDelegate;
}

@end

@implementation SidebarTableViewController {
    NSArray *menuItems;
}

- (void)viewDidLoad {
    appDelegate = [AppDelegate getDelegate];
    [super viewDidLoad];
    menuItems = @[@"title", @"home", @"rides", @"account", @"logout"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return menuItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[menuItems objectAtIndex:indexPath.row] isEqualToString:@"logout"]){
        [appDelegate userLogout];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Set the title of navigation bar by using the menu items
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    destViewController.title = [[menuItems objectAtIndex:indexPath.row] capitalizedString];
}

@end
