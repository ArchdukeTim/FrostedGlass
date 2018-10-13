//
//  OpenCVWrapper.m
//  FrostedGlass
//
//  Created by Tim Winters on 6/9/17.
//  Copyright © 2017 Tim Winters. All rights reserved.
//


#import "OpenCVWrapper.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "GripPipeline.h"






using namespace std;
using namespace grip;
GripPipeline gp;
int imageCount = 0;
cv::Mat* images = new cv::Mat[3];
cv::Mat imageMat, cropped, returnImage;

struct Target
{
    int x;
    int y;
} target;

@implementation OpenCVWrapper
+(UIImage *) process:(UIImage *)image
{
    // Transform Image
    cv::Mat imageMat, grayMat, cannyMat;
    UIImageToMat(image, imageMat);
    //cv::cvtColor(imageMat, grayMat, cv::COLOR_BGR2GRAY);
    //cv::Canny(grayMat, cannyMat, 60, 60*3);
    gp.process(imageMat);
    return MatToUIImage(*gp.getContourImage());
}
@end
