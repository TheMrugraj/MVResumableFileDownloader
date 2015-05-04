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

+(instancetype)startDownloadWithURL:(NSURL *)fileUrl{
    if(!instance){
        instance = [[MVFileDownload alloc]initWithURL:fileUrl];
    }
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
    
    if([_delegate respondsToSelector:@selector(fileDownloadDidStartd:)]){
        [_delegate fileDownloadDidStartd:_downloadUrl];
    }
    
    _mutArrParts = [NSMutableArray array];
    
    NSError *aError = [self getHeaderDetailsForUrl:_downloadUrl];
    if(aError){
        [_delegate fileDownloadDidFailed:aError];
        return;
    }
    
    
    
    NSInteger intFragment = _expectedSize/4;
    totalPartsPending = 0;
    
    for (int i=0; i<4; i++) {
        MVFilePart *aFilePart = [[MVFilePart alloc]initWithUrl:_downloadUrl andRangeFrom:i*intFragment==0?0:(i*intFragment)+1 to:(i*intFragment)+intFragment];
        aFilePart.delegate = self;
        NSString *aStrId = [NSString stringWithFormat:@"Part%d",i];
        aFilePart.strIdentifier = aStrId;
        [aFilePart startDownlaoding];
        totalPartsPending ++;
        [_mutArrParts addObject:aFilePart];

    }
    
}


-(NSError*)getHeaderDetailsForUrl:(NSURL*)url{
    NSError *aError;
    NSMutableURLRequest *aRequest = [NSMutableURLRequest requestWithURL:url];
    [aRequest setHTTPMethod:@"HEAD"];
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
        NSData *aDataPart = [NSData dataWithContentsOfURL:part.targetUrl];
        [aData appendData:aDataPart];
    }
    [aData writeToFile:aStrPath atomically:YES];
    
    if([_delegate respondsToSelector:@selector(fileDownloadDidFinished:savedAt:)]){
        [_delegate fileDownloadDidFinished:_downloadUrl savedAt:[NSURL fileURLWithPath:aStrPath]];
    }
}

#pragma mark - FilePart Delegates

-(void)filePart:(MVFilePart*)part didFinishedDownloadingAtUrl:(NSURL *)strUrl{
    totalPartsPending--;
    if(totalPartsPending==0){
        [self compileParts];
    }
}
@end
