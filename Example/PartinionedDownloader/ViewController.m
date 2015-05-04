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
    NSString *aStr = @"http://curl.io/get/7lxqt1f5/fb647b75d1fb20457829d7911f579ab1e88a4c11";//@"http://curl.io/get/mzshprl8/2d406f17312e8b13632b6360804466589afec41f"; // @"https://drscdn.500px.org/photo/101964469/m%3D2048/d8ce1c564eadc7dee434bc39d4f0ca38";//@"http://www.hdimagewallpaper.com/wp-content/uploads/2015/04/Colourful-Apples-HD-1-10167-HD-Images-Wallpapers.jpg"; //@"https://www.dropbox.com/s/m5ie72rnq86sa48/Ehsaan%20hoga.mp3?dl=1";//@"https://www.dropbox.com/s/vkyvz2eokzy3w85/Getting%20Started.pdf?dl=1";//
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
