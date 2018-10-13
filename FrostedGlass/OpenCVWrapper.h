//
//  OpenCVWrapper.h
//  FrostedGlass
//
//  Created by Tim Winters on 6/9/17.
//  Copyright © 2017 Tim Winters. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface OpenCVWrapper : NSObject
+(UIImage *) process:(UIImage *)image;
@end
