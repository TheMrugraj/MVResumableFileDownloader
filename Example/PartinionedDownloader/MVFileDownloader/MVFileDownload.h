//
//  MVFileDownload.h
//  PartinionedDownloader
//
//  Created by indianic on 02/05/15.
//  Copyright (c) 2015 IndiaNIC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MVFilePart.h"

@protocol FileDownloadDelegate <NSObject>
-(NSString*)fileDownloadPathToSave:(NSURL*)url;
-(void)fileDownloadDidFinished:(NSURL*)url savedAt:(NSURL*)savedUrl;
-(void)fileDownloadDidFailed:(NSError*)aError;
-(void)fileDownloadDidStartd:(NSURL*)url;
-(void)fileDownloadProgress:(double)progress;
@end


@interface MVFileDownload : NSObject<FilePartDelegate,NSURLSessionDelegate>{
    NSInteger totalPartsPending;
    NSInteger overallReceivedSize;
    NSURLSession *session;
}

@property(nonatomic,readonly)   NSURL *downloadUrl;
@property(nonatomic,readonly)   NSInteger expectedSize;
@property(nonatomic,assign)     NSInteger totalFragment;
@property(nonatomic,strong)     NSMutableArray *mutArrParts;
@property(nonatomic,strong)     id <FileDownloadDelegate> delegate;
@property(nonatomic,strong)     NSString *fileName;
@property(nonatomic,readonly)   NSString *contentType;

-(instancetype)initWithURL:(NSURL*)fileUrl;

-(void)startDownload;
-(void)startDownloadWith:(NSURL*)fileUrl;
+(instancetype)startDownloadWithURL:(NSURL*)fileUrl;
-(void)pause;
@end
