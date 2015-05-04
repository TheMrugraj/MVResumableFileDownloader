//
//  MVFilePart.m
//  PartinionedDownloader
//
//  Created by indianic on 02/05/15.
//  Copyright (c) 2015 IndiaNIC. All rights reserved.
//

#import "MVFilePart.h"


@implementation MVFilePart
-(instancetype)initWithUrl:(NSURL *)aUrl andRangeFrom:(NSInteger)aFromBytes to:(NSInteger)aToBytes{
    self = [super init];
    _fromBytes = aFromBytes;
    _toBytes = aToBytes;
    _downloadUrl = aUrl;
    return self;
}
-(void)startDownlaoding{

    NSString *range = [NSString stringWithFormat:@"bytes=%ld-%ld",_fromBytes,_toBytes];
    NSLog(@"***********************************************");
    NSLog(@"Downloading : %@",_downloadUrl);
    NSLog(@"Range : %@",range);
    NSLog(@"***********************************************");
    
    _mutRequest = [NSMutableURLRequest requestWithURL:_downloadUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    [_mutRequest setHTTPMethod:@"GET"];
    [_mutRequest setValue:range forHTTPHeaderField:@"Range"];

//    NSError *aErr;
//    NSURLResponse *response;
//    NSData *aMutData = [NSURLConnection sendSynchronousRequest:_mutRequest returningResponse:&response error:&aErr];


    connection = [[NSURLConnection alloc]initWithRequest:_mutRequest delegate:self startImmediately:YES];
}

-(void)clearAll{
    
}

#pragma mark - Connection Delegates
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if(!receivedData){
        receivedData = [NSMutableData data];
    }
    [receivedData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{

}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{

}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *aStrTargetPath = [DocumentDir stringByAppendingPathComponent:@"Downloads"];
    if(![[NSFileManager defaultManager]fileExistsAtPath:aStrTargetPath isDirectory:0]){
        [[NSFileManager defaultManager]createDirectoryAtPath:aStrTargetPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    aStrTargetPath = [aStrTargetPath stringByAppendingPathComponent:_strIdentifier];
    NSLog(@"DowloadedPart : %@",aStrTargetPath);    
    [receivedData writeToFile:aStrTargetPath atomically:YES];
    _targetUrl = [NSURL fileURLWithPath:aStrTargetPath];
    
    if([_delegate respondsToSelector:@selector(filePart:didFinishedDownloadingAtUrl:)]){
        [_delegate filePart:self didFinishedDownloadingAtUrl:_targetUrl];
    }
}

@end
