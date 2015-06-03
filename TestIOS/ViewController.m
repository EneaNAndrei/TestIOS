//
//  ViewController.m
//  TestIOS
//
//  Created by Nox on 6/3/15.
//  Copyright (c) 2015 Andrei. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "SecondViewController.h"

NSString *const JSONURLToDownloadString = @"https://s3-us-west-2.amazonaws.com/wirestorm/assets/response.json";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaults];
    [self callJSONAsynchronously];
   
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)fetchedData:(NSData *)response {
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:response
                          options:kNilOptions
                          error:&error];
    [self savePeopleFromDictionary:json];
    [self fetchFromCoreData];
    [self.tableView reloadData];
}

- (void)callJSONAsynchronously {
    NSURL *JSONURLToDownload = [NSURL URLWithString:JSONURLToDownloadString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        JSONURLToDownload];
        [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
    });
}

- (void)setupDefaults {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.managedObjectContext = [appDelegate managedObjectContext];
}

- (void)savePeopleFromDictionary:(NSDictionary *)peopleDictionary {
    for (NSDictionary *singlePersonDictionary in peopleDictionary) {
        NSManagedObject *newContact;
        
        newContact = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
        
        [newContact setValue:[singlePersonDictionary objectForKey:@"name"] forKey:@"name"];
        [newContact setValue:[singlePersonDictionary objectForKey:@"position"] forKey:@"position"];
        [newContact setValue:[singlePersonDictionary objectForKey:@"smallpic"] forKey:@"smallpicurl"];
        [newContact setValue:[singlePersonDictionary objectForKey:@"lrgpic"] forKey:@"lrgpicurl"];
        
        NSLog(@"newContact %@", newContact);
    }
    
    NSError *error;
    [self.managedObjectContext save:&error];
    if (!error) {
        NSLog(@"person saved");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.peopleValues count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *testIOSItendifier = @"TestIOSIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:testIOSItendifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:testIOSItendifier];
    }
    
   
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[self.peopleValues objectAtIndex:indexPath.row] valueForKey:@"smallpicurl"]]];
        if (imgData) {
            UIImage *image = [UIImage imageWithData:imgData];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UITableViewCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                    if (updateCell) {
                        updateCell.imageView.image = image;
                        [updateCell setNeedsLayout];
                    }
                });
            }
        }
    });
    
    cell.textLabel.text = [[self.peopleValues objectAtIndex:indexPath.row] valueForKey:@"name"];
    cell.detailTextLabel.text = [[self.peopleValues objectAtIndex:indexPath.row] valueForKey:@"position"];
    return cell;
}

- (void)fetchFromCoreData {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    self.peopleValues = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSLog(@"allpeople %@", [[self.peopleValues objectAtIndex:0] valueForKey:@"position"]);
//    NSLog(@"propleValueshere %@", [[self.peopleValues objectAtIndex:0] objectForKey:@"name"]);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"SecondViewControllerSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"SecondViewControllerSegue"]) {
        UITableViewCell *cell = (UITableViewCell *) sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSDictionary *peopleObject =[self.peopleValues objectAtIndex:[indexPath row]];
        NSLog(@"%@", peopleObject);
        SecondViewController *secondVC = [segue destinationViewController];
        secondVC.personObject = peopleObject;
    }
}


@end
