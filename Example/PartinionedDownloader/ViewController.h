//
//  ViewController.h
//  PartinionedDownloader
//
//  Created by Mrugrajsinh Vansadia on 02/05/15.
//  Copyright (c) 2015 Mrugrajsinh Vansadia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressTwoView,*progressJG;
@property (weak, nonatomic) IBOutlet UILabel *lblNormal, *lblAccelerated;
@end

