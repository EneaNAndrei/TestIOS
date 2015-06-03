//
//  ViewController.h
//  TestIOS
//
//  Created by Nox on 6/3/15.
//  Copyright (c) 2015 Andrei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSDictionary *allPeopleDictionary;

@property (nonatomic,strong) NSMutableArray *peopleValues;

@end

