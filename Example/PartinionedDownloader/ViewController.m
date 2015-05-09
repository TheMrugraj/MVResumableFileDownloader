//
//  ViewController.m
//  PartinionedDownloader
//
//  Created by indianic on 02/05/15.
//  Copyright (c) 2015 IndiaNIC. All rights reserved.



#import "ViewController.h"
#import "MVFileDownloader.h"

#define aStrUrl @"https://www.dropbox.com/s/m5ie72rnq86sa48/Ehsaan%20hoga.mp3?dl=1"//@"http://clippy.indianic.net/fonts/Clippy_1.1.dmg" //@"https://www.dropbox.com/s/ffbm0e20de5614k/Laadki_-_Sachin-Jigar_-_Coke_Studio_MTV_Season_4%28MyMp3Song.Com%29.mp3?dl=1"//
@interface ViewController ()<FileDownloadDelegate,FilePartDelegate>
{
    MVFileDownload *downloadTask;
    NSURLConnection *connection;
    NSMutableData *receivedData,*jgData;
    
    NSInteger expectedSize;
    NSInteger expectedForJG;
    
    NSDate *startTime;
    

}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ;
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)viewDidAppear:(BOOL)animated{
////@"http://clippy.indianic.net/fonts/Clippy_1.1.dmg"
//    NSString *aStr = @"https://www.dropbox.com/s/ffbm0e20de5614k/Laadki_-_Sachin-Jigar_-_Coke_Studio_MTV_Season_4%28MyMp3Song.Com%29.mp3?dl=1";//@"https://www.dropbox.com/s/m5ie72rnq86sa48/Ehsaan%20hoga.mp3?dl=1";//// @"http://www.hdimagewallpaper.com/wp-content/uploads/2015/04/Colourful-Apples-HD-1-10167-HD-Images-Wallpapers.jpg"; //
    downloadTask = [MVFileDownload startDownloadWithURL:[NSURL URLWithString:aStrUrl] delegate:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(void)fileDownloadDidFailed:(NSError *)aError{
    NSLog(@"ERROR: %@",aError);
}
-(void)fileDownloadDidFinished:(NSURL *)url savedAt:(NSURL *)savedUrl{
    NSDate *aDate = [NSDate date];
    NSTimeInterval timeInterval = [aDate timeIntervalSinceDate:startTime];
    _lblAccelerated.text = [NSString stringWithFormat:@"Completed in %f",timeInterval];
    NSLog(@"*********************************************************************");
    NSLog(@"Downloading Finished: %@",savedUrl);
    NSLog(@"*********************************************************************");
}
-(void)fileDownloadDidStartd:(NSURL *)url{
    startTime= [NSDate date];
    [self startDownlaoding];
}

-(NSString *)fileDownloadPathToSave:(NSURL *)url{
    NSString *aStrPath = [DocumentDir stringByAppendingPathComponent:[url lastPathComponent]];
    return aStrPath;
}

-(void)fileDownloadProgress:(double)progress{
    _progressView.progress = progress;
}

#pragma mark - Actions

-(IBAction)btnStopAction:(id)sender{
    [downloadTask pause];
}

-(IBAction)btnStartAction:(id)sender{
    [downloadTask startDownload];
}

-(void)startDownlaoding{
    NSMutableURLRequest *_mutRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:aStrUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    [_mutRequest setHTTPMethod:@"GET"];
    connection = [[NSURLConnection alloc]initWithRequest:_mutRequest delegate:self startImmediately:YES];
}

#pragma mark - Connection Delegates
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if(!receivedData){
        receivedData = [NSMutableData data];        
    }
    [receivedData appendData:data];
    _progressTwoView.progress = (double)receivedData.length/(double)expectedSize;
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    expectedSize = response.expectedContentLength;
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    _progressTwoView.progress = 1.0;
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:startTime];
    _lblNormal.text = [NSString stringWithFormat:@"Completed in %f",timeInterval];
}


@end
