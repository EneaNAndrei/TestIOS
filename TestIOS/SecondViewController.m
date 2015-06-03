//
//  SecondViewController.m
//  TestIOS
//
//  Created by Nox on 6/3/15.
//  Copyright (c) 2015 Andrei. All rights reserved.
//

#import "SecondViewController.h"

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDataIntoImageView];
}

- (void)loadDataIntoImageView {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self.personObject  valueForKey:@"lrgpicurl"]]];
            if (imgData) {
                UIImage *image = [UIImage imageWithData:imgData];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageview.image = image;
                        [self.imageview setNeedsLayout];
                    });
                }
            }
        });
}

@end
