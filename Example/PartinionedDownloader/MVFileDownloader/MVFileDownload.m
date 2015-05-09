//
//  MVFileDownload.m
//  PartinionedDownloader
//
//  Created by indianic on 02/05/15.
//  Copyright (c) 2015 IndiaNIC. All rights reserved.
//

#import "MVFileDownload.h"

MVFileDownload *instance=nil;

@implementation MVFileDownload

+(instancetype)startDownloadWithURL:(NSURL*)fileUrl delegate:(id<FileDownloadDelegate>)delegate{
    if(!instance){
        instance = [[MVFileDownload alloc]initWithURL:fileUrl];
    }
    instance.delegate =delegate;
    instance.totalFragment = 4;
    [instance startDownload];
    return instance;
}


-(instancetype)initWithURL:(NSURL *)fileUrl{
    if(!self)
        self = [super init];
    
    instance =  self;
    _downloadUrl = fileUrl;
    return self;
}


-(void)startDownloadWith:(NSURL *)fileUrl{
    _downloadUrl =  fileUrl;
    [instance startDownload];
}


-(void)startDownload{
    
    _totalFragment = (_totalFragment<=0?1:_totalFragment);
        if(!_mutArrParts){
        _mutArrParts = [NSMutableArray array];
    }
    
    NSError *aError = [self getHeaderDetailsForUrl:_downloadUrl];
    if(aError){
        [_delegate fileDownloadDidFailed:aError];
        return;
    }
    
    if([_delegate respondsToSelector:@selector(fileDownloadDidStartd:)]){
        [_delegate fileDownloadDidStartd:_downloadUrl];
    }

    
    
    NSInteger intFragment = _expectedSize/_totalFragment;

    
    session = [self methodForNSURLSession];
    
    if(_mutArrParts && _mutArrParts.count>0){
        for (MVFilePart *aFilePart in _mutArrParts){
            NSURLSessionDownloadTask *sessionDownloadTask= (NSURLSessionDownloadTask*)aFilePart.task;
            [sessionDownloadTask resume];
        }
    }else{
        totalPartsPending = 0; // Initialize Counter of parts
        for (int i=0; i<_totalFragment; i++) {
            MVFilePart *aFilePart = [[MVFilePart alloc]initWithUrl:_downloadUrl andRangeFrom:i*intFragment==0?0:(i*intFragment)+1 to:(i*intFragment)+intFragment];
            aFilePart.strIdentifier = [NSString stringWithFormat:@"%@-%d",_fileName,i];
            aFilePart.delegate = self;        
            NSURLSessionDownloadTask *sessionDownloadTask;
            
            if(aFilePart.resumeData){
                NSData *aDataToResume = aFilePart.resumeData;
                sessionDownloadTask = [session downloadTaskWithResumeData:aDataToResume];
            }else{
                sessionDownloadTask = [session downloadTaskWithRequest:[aFilePart request]];
            }
            aFilePart.task =  sessionDownloadTask;
            [sessionDownloadTask resume];
            totalPartsPending ++;
            [_mutArrParts addObject:aFilePart];
        }
    }
    
}


-(NSError*)getHeaderDetailsForUrl:(NSURL*)url{
    NSError *aError;
    NSMutableURLRequest *aRequest = [NSMutableURLRequest requestWithURL:url];
    [aRequest setHTTPMethod:@"HEAD"];
    [aRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    NSHTTPURLResponse *aResponse;
    [NSURLConnection sendSynchronousRequest:aRequest returningResponse:&aResponse error:&aError];
    
    if(aError){
        return aError;
    }
    
    _expectedSize =  aResponse.expectedContentLength;
    _contentType = aResponse.MIMEType;
    _fileName =  [aResponse suggestedFilename];
    
    if(_expectedSize<=0){
        return [NSError errorWithDomain:@"No file found" code:200 userInfo:aResponse.allHeaderFields];
    }
    
    if(aResponse.statusCode>=400)
        return [NSError errorWithDomain:@"Failed to download" code:aResponse.statusCode userInfo:aResponse.allHeaderFields];
    
    return nil;
}


-(void)compileParts{
    NSString *aStrPath;
    if([_delegate respondsToSelector:@selector(fileDownloadPathToSave:)]){
        aStrPath = [_delegate fileDownloadPathToSave:_downloadUrl];
    }else{
        aStrPath = [DocumentDir stringByAppendingPathComponent:_fileName?_fileName:@"DownloadedFile"];
    }
    
    NSMutableData *aData = [NSMutableData data];
    for (MVFilePart *part in _mutArrParts) {
        NSLog(@"Part Path : %@",part.targetUrl);
        NSData *aDataPart = [NSData dataWithContentsOfURL:part.targetUrl];
        [aData appendData:aDataPart];
        [[NSFileManager defaultManager]removeItemAtURL:part.targetUrl error:nil];
    }
    [_mutArrParts removeAllObjects];
    [aData writeToFile:aStrPath atomically:YES];
    
    if([_delegate respondsToSelector:@selector(fileDownloadDidFinished:savedAt:)]){
        [_delegate fileDownloadDidFinished:_downloadUrl savedAt:[NSURL fileURLWithPath:aStrPath]];
    }
    [session finishTasksAndInvalidate];
}

-(void)pause{
    for (MVFilePart *part in _mutArrParts) {
        NSLog(@"Part Path : %@",part.targetUrl);
        NSURLSessionDownloadTask *aTask = (NSURLSessionDownloadTask*)part.task;
        [aTask suspend];
    }

}


#pragma mark - FilePart Delegates

-(void)filePart:(MVFilePart*)part didFinishedDownloadingAtUrl:(NSURL *)strUrl{
    totalPartsPending--;
    if(totalPartsPending==0){
        [self compileParts];
    }
}


#pragma mark - URL Session Delegates

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    // Calculate Progress
    overallReceivedSize+=downloadTask.countOfBytesReceived;
    
    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    double overallProgress = (double)overallReceivedSize/(double)_expectedSize;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Downloaded %ld : %lf",downloadTask.taskIdentifier,progress);
        if([_delegate respondsToSelector:@selector(fileDownloadProgress:)]){
            [_delegate fileDownloadProgress:overallProgress/(1.0)];
        }
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    MVFilePart *downloadedTask = [self partForTask:downloadTask];
    NSString *strNewPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:[location lastPathComponent]];
    [[NSFileManager defaultManager]moveItemAtURL:location toURL:[NSURL fileURLWithPath:strNewPath] error:nil];
    
    downloadedTask.targetUrl = [NSURL fileURLWithPath:strNewPath];
    [self filePart:downloadedTask didFinishedDownloadingAtUrl:downloadedTask.targetUrl];
}



-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
    [_delegate fileDownloadDidFailed:error];
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if(error){
        [_delegate fileDownloadDidFailed:error];
    }
}


#pragma mark - MISC Methods

-(MVFilePart*)partForTask:(NSURLSessionTask*)taskToCheck{
    NSUInteger index = [_mutArrParts indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        MVFilePart *aObject = obj;
        if(aObject.task == taskToCheck){
            return YES;
        }
        return NO;
    }];
    
    if(index!=NSNotFound){
        return [_mutArrParts objectAtIndex:index];
    }
    return nil;
}

- (NSURLSession*) methodForNSURLSession{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.HTTPMaximumConnectionsPerHost = 4;
    NSURLSession *aSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    // data tasks
    return aSession;
}


@end
