#include "GripPipeline.h"
/**
 * Initializes a GripPipeline.
 */
#define BLUE cv::Scalar( 255,0,0)
cv::Scalar color = BLUE;
namespace grip {
    
    GripPipeline::GripPipeline() {
    }
    /**
     * Runs an iteration of the Pipeline and updates outputs.
     *
     * Sources need to be set before calling this method.
     *
     */
    void GripPipeline::process(cv::Mat source0){
        //Step HSL_Threshold0:
        //input
        cv::Mat hslThresholdInput = source0;
        double hslThresholdHue[] = {30, 145};
        double hslThresholdSaturation[] = {0.0, 255};
        double hslThresholdLuminance[] = {25, 255};
        hslThreshold(hslThresholdInput, hslThresholdHue, hslThresholdSaturation, hslThresholdLuminance, this->hslThresholdOutput);
        //Step Find_Contours0:
        //input
        cv::Mat findContoursInput = hslThresholdOutput;
        bool findContoursExternalOnly = false;  // default Boolean
        findContours(findContoursInput, findContoursExternalOnly, this->findContoursOutput);
        //Step Convex_Hulls0:
        //input
        std::vector<std::vector<cv::Point> > convexHullsContours = findContoursOutput;
        convexHulls(convexHullsContours, this->convexHullsOutput);
        //Step Filter_Contours0:
        //input
        std::vector<std::vector<cv::Point> > filterContoursContours = convexHullsOutput;
        
        drawing = this->hslThresholdOutput.clone();
        cv::cvtColor(drawing, drawing, CV_GRAY2BGR);

        double filterContoursMinArea = 500; // default Double
        double filterContoursMinPerimeter = 0;  // default Double
        double filterContoursMinWidth = 0.0; // default Double
        double filterContoursMaxWidth = 1000;  // default Double
        double filterContoursMinHeight = 0.0;  // default Double
        double filterContoursMaxHeight = 1000;  // default Double
        double filterContoursSolidity[] = {0.0, 100.0};
        double filterContoursMaxVertices = 1.0E7;  // default Double
        double filterContoursMinVertices = 0;  // default Double
        double filterContoursMinRatio = 2/6;  // default Double
        double filterContoursMaxRatio = 3/5;  // default Double
        filterContours(filterContoursContours, filterContoursMinArea, filterContoursMinPerimeter, filterContoursMinWidth, filterContoursMaxWidth, filterContoursMinHeight, filterContoursMaxHeight, filterContoursSolidity, filterContoursMaxVertices, filterContoursMinVertices, filterContoursMinRatio, filterContoursMaxRatio, this->contours);
        
        std::vector<std::vector<cv::Point> > contours_poly( contours.size() );
        std::vector<cv::Rect> boundRect( contours.size() );
        
        std::vector<cv::Moments> mu(contours.size() );
        for( int i = 0; i < contours.size(); i++ )
        {
            mu[i] = cv::moments( contours[i], false );
            cv::approxPolyDP(cv::Mat(contours[i]), contours_poly[i], 3, true );
            boundRect[i] = cv::boundingRect(cv::Mat(contours_poly[i]) );
        }
        
        if (contours.size()){
            cv::Point2f tl, br;
                tl = boundRect[0].tl();
                br = boundRect[contours.size()-1].br();
                rectangle(drawing, tl, br, color);
            targetCoords =cv::Point((tl.x + br.x) / 2, (tl.y + br.y)/2);
                circle( drawing, targetCoords, 4, color, -1, 8, 0 );
            

        }

    }
    
    /**
     * This method is a generated getter for the output of a HSL_Threshold.
     * @return Mat output from HSL_Threshold.
     */
    cv::Mat* GripPipeline::gethslThresholdOutput(){
        return &(this->hslThresholdOutput);
    }
    /**
     * This method is a generated getter for the output of a Find_Contours.
     * @return ContoursReport output from Find_Contours.
     */
    std::vector<std::vector<cv::Point> >* GripPipeline::getfindContoursOutput(){
        return &(this->findContoursOutput);
    }
    /**
     * This method is a generated getter for the output of a Convex_Hulls.
     * @return ContoursReport output from Convex_Hulls.
     */
    std::vector<std::vector<cv::Point> >* GripPipeline::getconvexHullsOutput(){
        return &(this->convexHullsOutput);
    }
    /**
     * This method is a generated getter for the output of a Filter_Contours.
     * @return ContoursReport output from Filter_Contours.
     */
    std::vector<std::vector<cv::Point> >* GripPipeline::getfilterContoursOutput(){
        return &(this->contours);
    }
    
    cv::Mat* GripPipeline::getContourImage(){
        return &(this->drawing);
    }
    cv::Point* GripPipeline::getTargetCoords()
    {
        return &(this->targetCoords);
    }
    /**
     * Segment an image based on hue, saturation, and luminance ranges.
     *
     * @param input The image on which to perform the HSL threshold.
     * @param hue The min and max hue.
     * @param sat The min and max saturation.
     * @param lum The min and max luminance.
     * @param output The image in which to store the output.
     */
    //void hslThreshold(Mat *input, double hue[], double sat[], double lum[], Mat *out) {
    void GripPipeline::hslThreshold(cv::Mat &input, double hue[], double sat[], double lum[], cv::Mat &out) {
        cv::cvtColor(input, out, cv::COLOR_BGR2HLS);
        cv::inRange(out, cv::Scalar(hue[0], lum[0], sat[0]), cv::Scalar(hue[1], lum[1], sat[1]), out);
    }
    
    /**
     * Finds contours in an image.
     *
     * @param input The image to find contours in.
     * @param externalOnly if only external contours are to be found.
     * @param contours vector of contours to put contours in.
     */
    void GripPipeline::findContours(cv::Mat &input, bool externalOnly, std::vector<std::vector<cv::Point> > &contours) {
        std::vector<cv::Vec4i> hierarchy;
        contours.clear();
        int mode = externalOnly ? cv::RETR_EXTERNAL : cv::RETR_LIST;
        int method = cv::CHAIN_APPROX_SIMPLE;
        cv::findContours(input, contours, hierarchy, mode, method);
    }
    
    /**
     * Compute the convex hulls of contours.
     *
     * @param inputContours The contours on which to perform the operation.
     * @param outputContours The contours where the output will be stored.
     */
    void GripPipeline::convexHulls(std::vector<std::vector<cv::Point> > &inputContours, std::vector<std::vector<cv::Point> > &outputContours) {
        std::vector<std::vector<cv::Point> > hull (inputContours.size());
        outputContours.clear();
        for (size_t i = 0; i < inputContours.size(); i++ ) {
            cv::convexHull(cv::Mat((inputContours)[i]), hull[i], false);
        }
        outputContours = hull;
    }
    
    
    /**
     * Filters through contours.
     * @param inputContours is the input vector of contours.
     * @param minArea is the minimum area of a contour that will be kept.
     * @param minPerimeter is the minimum perimeter of a contour that will be kept.
     * @param minWidth minimum width of a contour.
     * @param maxWidth maximum width.
     * @param minHeight minimum height.
     * @param maxHeight  maximimum height.
     * @param solidity the minimum and maximum solidity of a contour.
     * @param minVertexCount minimum vertex Count of the contours.
     * @param maxVertexCount maximum vertex Count.
     * @param minRatio minimum ratio of width to height.
     * @param maxRatio maximum ratio of width to height.
     * @param output vector of filtered contours.
     */
    void GripPipeline::filterContours(std::vector<std::vector<cv::Point> > &inputContours, double minArea, double minPerimeter, double minWidth, double maxWidth, double minHeight, double maxHeight, double solidity[], double maxVertexCount, double minVertexCount, double minRatio, double maxRatio, std::vector<std::vector<cv::Point> > &output) {
        std::vector<cv::Point> hull;
        output.clear();
        for (std::vector<cv::Point> contour: inputContours) {
            cv::Rect bb = boundingRect(contour);
            if (bb.width < minWidth || bb.width > maxWidth) continue;
            if (bb.height < minHeight || bb.height > maxHeight) continue;
            double area = cv::contourArea(contour);
            if (area < minArea) continue;
            if (arcLength(contour, true) < minPerimeter) continue;
            cv::convexHull(cv::Mat(contour, true), hull);
            double solid = 100 * area / cv::contourArea(hull);
            if (solid < solidity[0] || solid > solidity[1]) continue;
            if (contour.size() < minVertexCount || contour.size() > maxVertexCount)	continue;
            double ratio = bb.width / bb.height;
            if (ratio < minRatio || ratio > maxRatio) continue;
            output.push_back(contour);
        }
    }
    
    
    
    
} // end grip namespace

