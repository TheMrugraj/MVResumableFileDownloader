//
//  ViewController.m
//  PartinionedDownloader
//
//  Created by indianic on 02/05/15.
//  Copyright (c) 2015 IndiaNIC. All rights reserved.



#import "ViewController.h"
#import "MVFileDownloader.h"
@interface ViewController ()<FileDownloadDelegate>
{
    MVFileDownload *downloadTask;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ;
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)viewDidAppear:(BOOL)animated{
//@"http://clippy.indianic.net/fonts/Clippy_1.1.dmg"
    NSString *aStr = @"http://www.hdimagewallpaper.com/wp-content/uploads/2015/04/Colourful-Apples-HD-1-10167-HD-Images-Wallpapers.jpg";
    downloadTask = [MVFileDownload startDownloadWithURL:[NSURL URLWithString:aStr]];
    downloadTask.delegate =  self;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)fileDownloadDidFailed:(NSError *)aError{

}

-(void)fileDownloadDidFinished:(NSURL *)url savedAt:(NSURL *)savedUrl{

}
-(void)fileDownloadDidStartd:(NSURL *)url{

}
-(NSString *)fileDownloadPathToSave:(NSURL *)url{
    NSString *aStrPath = [DocumentDir stringByAppendingPathComponent:[url lastPathComponent]];
    return aStrPath;
}
@end
