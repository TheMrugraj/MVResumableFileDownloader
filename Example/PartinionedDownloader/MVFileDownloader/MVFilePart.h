//
//  MVFilePart.h
//  PartinionedDownloader
//
//  Created by Mrugrajsinh Vansadia on 02/05/15.
//  Copyright (c) 2015 Mrugrajsinh Vansadia. All rights reserved.
//

#import <Foundation/Foundation.h>
#define DocumentDir NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject

@protocol FilePartDelegate <NSObject>
-(void)filePart:(id)part didFinishedDownloadingAtUrl:(NSURL*)strUrl;
@end


@interface MVFilePart : NSObject<NSURLConnectionDataDelegate>
{
    NSMutableData *receivedData;
    NSOutputStream *outputStream;
    NSURLConnection *connection;
}
@property(nonatomic,strong)     NSURLSession *session;
@property(nonatomic,strong)     id <FilePartDelegate> delegate;
@property(nonatomic,strong)     NSMutableURLRequest *mutRequest;
@property(nonatomic,readonly)   NSInteger   fromBytes,toBytes;
@property(nonatomic,readonly)   NSURL       *downloadUrl;
@property(nonatomic,strong)     NSURL       *targetUrl;
@property(nonatomic,strong)     NSURL       *tempUrl;
@property(nonatomic,strong)     NSString    *strIdentifier;
@property(nonatomic,strong)     NSData      *resumeData;


@property(nonatomic,strong)NSURLSessionTask *task;
@property(nonatomic,assign)NSInteger taskId;

-(instancetype)initWithUrl:(NSURL*)url andRangeFrom:(NSInteger)aFromBytes to:(NSInteger)aToBytes;
-(NSURLRequest*)request;
-(void)startDownlaoding;
-(NSString*)getLocalPath;
@end
