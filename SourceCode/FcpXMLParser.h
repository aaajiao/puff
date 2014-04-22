//
//  GetFcpTimeMarks.h
//  getTimeMarks
//
//  Created by Elvis on 14-3-14.
//  Copyright (c) 2014年 Elvis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"

@interface FcpXMLParser : NSObject
-(NSMutableArray *) loadXML:(NSString *)xmlFileName;
@end
