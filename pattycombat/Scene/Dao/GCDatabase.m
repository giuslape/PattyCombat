//
//  GCDatabase.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 07/03/12.
//  Copyright (c) 2012 Fratello. All rights reserved.
//

#import "GCDatabase.h"


NSString * pathForFile(NSString *filename) {
    
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory
            stringByAppendingPathComponent:filename];
}


id loadData(NSString * filename) {
    
    NSString *filePath = pathForFile(filename);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        NSData *data = [[NSData alloc]
                         initWithContentsOfFile:filePath];
        
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]
                                          initForReadingWithData:data];
        
        id retval = [unarchiver decodeObjectForKey:@"Data"];
        [unarchiver finishDecoding];
        return retval;
    }
    return nil;
}
void saveData(id theData, NSString *filename) {
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]
                                  initForWritingWithMutableData:data];
    
    [archiver encodeObject:theData forKey:@"Data"];
    [archiver finishEncoding];
    
    [data writeToFile:pathForFile(filename) atomically:YES];
}
