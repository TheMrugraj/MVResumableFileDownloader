//
//  MVFilePart.m
//  PartinionedDownloader
//
//  Created by Mrugrajsinh Vansadia on 02/05/15.
//  Copyright (c) 2015 Mrugrajsinh Vansadia. All rights reserved.
//

#import "MVFilePart.h"


@implementation MVFilePart
-(instancetype)initWithUrl:(NSURL *)aUrl andRangeFrom:(NSInteger)aFromBytes to:(NSInteger)aToBytes{
    self = [super init];
    _fromBytes = aFromBytes;
    _toBytes = aToBytes;
    _downloadUrl = aUrl;
    _tempUrl = [NSURL fileURLWithPath:[self getLocalPath]];
    return self;
}
-(NSURLRequest *)request{
    NSString *range = [NSString stringWithFormat:@"bytes=%ld-%ld",_fromBytes,_toBytes];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:_downloadUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    [req setHTTPMethod:@"GET"];
    [req setValue:range forHTTPHeaderField:@"Range"];
    return req;
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
    NSString *aStrTargetPath = [self getLocalPath];
    NSLog(@"DowloadedPart : %@",aStrTargetPath);    
    [receivedData writeToFile:aStrTargetPath atomically:YES];
    _targetUrl = [NSURL fileURLWithPath:aStrTargetPath];
    
    if([_delegate respondsToSelector:@selector(filePart:didFinishedDownloadingAtUrl:)]){
        [_delegate filePart:self didFinishedDownloadingAtUrl:_targetUrl];
    }
}

-(NSString*)getLocalPath{
    NSString *aStrTargetPath = [DocumentDir stringByAppendingPathComponent:@"Downloads"];
    if(![[NSFileManager defaultManager]fileExistsAtPath:aStrTargetPath isDirectory:0]){
        [[NSFileManager defaultManager]createDirectoryAtPath:aStrTargetPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    aStrTargetPath = [aStrTargetPath stringByAppendingPathComponent:_strIdentifier];
    return aStrTargetPath;
}

@end
