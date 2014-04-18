//
//  GetFcpTimeMarks.m
//  getTimeMarks
//
//  Created by Elvis on 14-3-14.
//  Copyright (c) 2014年 Elvis. All rights reserved.
//

#import "FcpXMLParser.h"

@interface FcpXMLParser()

@property (strong,nonatomic) NSMutableArray *timeMarks;


@end

@implementation FcpXMLParser


-(NSMutableArray *)loadXML:(NSString *)xmlFileName {
    NSError *error = nil;
    self.timeMarks =  [[NSMutableArray alloc]init ];
    TBXML *tbxml = [[TBXML alloc]initWithXMLFile:xmlFileName error:&error];
    if (error) {
        NSLog( @"%@ %@",[error localizedDescription], [error userInfo]);
    } else {
        if (tbxml.rootXMLElement) {
            [self traverseXMLElement:tbxml.rootXMLElement];
            NSLog(@"%@",self.timeMarks);
            [self insertUpfront:25 in:self.timeMarks];
            NSLog(@"%@",self.timeMarks);
        }
    }
    
    return self.timeMarks;
}


-(void)traverseXMLElement:(TBXMLElement *)element {
    do {
        //        NSLog(@"%@",[TBXML elementName:element]);
        TBXMLAttribute *attribute  = element->firstAttribute;
        while (attribute) {
            if ([[TBXML elementName:element]isEqualToString:@"marker"] && [[TBXML attributeName:attribute] isEqualToString:@"start"]) {
                NSString *curString =   [TBXML attributeValue:attribute];
                //                curString = [curString substringToIndex:[curString length]-1];
                NSArray *curStringArray = [curString componentsSeparatedByString:@"/"];
                int baseNum = [[curStringArray objectAtIndex:0] intValue];
                int tmpTimeMark = 0;
                switch ([curStringArray count]) {
                    case 1:
                        tmpTimeMark = baseNum*25;
                        
                        break;
                    case 2:
                        tmpTimeMark = baseNum *25 / [[curStringArray objectAtIndex:1] intValue];
                        break;
                    default:
                        break;
                }
                [self.timeMarks addObject:[[NSNumber alloc] initWithInt:tmpTimeMark]];
//                NSLog(@"%@ %d", curString, tmpTimeMark);
                
            }
            attribute =  attribute->next;
        }
        if (element->firstChild) {
            [self traverseXMLElement:element->firstChild];
        }
        
    } while ((element= element->nextSibling));
}

-(void) insertUpfront:(int)time in:(NSMutableArray *)timeMarks {
    NSMutableArray *tmpTimeMarks = [self.timeMarks copy];
    [self.timeMarks removeAllObjects];
    for (int i = 0; i<[tmpTimeMarks count]; i++) {
        if (i%2==0) {
            int upFrontTimeMark = [[tmpTimeMarks objectAtIndex:i] intValue]-time ;
            if (i>0) {
                if (upFrontTimeMark<=[[tmpTimeMarks objectAtIndex:i-1] intValue]) {
                    upFrontTimeMark =[[tmpTimeMarks objectAtIndex:i-1] intValue]+1;
                }

            }
            [self.timeMarks addObject:[[NSNumber alloc] initWithInt:upFrontTimeMark]];
        }
    [self.timeMarks addObject:[tmpTimeMarks objectAtIndex:i]];
    }
}

@end
