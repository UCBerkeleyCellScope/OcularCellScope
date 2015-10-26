//
//  RetinalStitcherInterface.m
//  Ocular Cellscope
//
//  Created by Frankie Myers on 3/7/15.
//  Copyright (c) 2015 UC Berkeley Fletcher Lab. All rights reserved.
//
//  This Obj-C++ class includes the C++ stitcher code plus a Obj-C accessor method at the bottom.
//  (obviously kludgy right now)

#import "RetinalStitcherInterface.h"
#import "UIImage+Resize.h"

#import <opencv2/highgui/ios.h> //FBM

@implementation RetinalStitcherInterface //FBM

// C++ stitcher class below (importing this caused linker errors, so I just copied pasted :P)
//--------------------------------------

#include <iostream>
#include <string>
#include <vector>
#include <stdio.h>
#include <iostream>
#include <sstream>

#include <opencv2/core/core.hpp>
#include <opencv2/video/tracking.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/features2d/features2d.hpp>
#include <opencv2/nonfree/nonfree.hpp>
#include <opencv2/legacy/legacy.hpp>
#include <opencv2/stitching/detail/motion_estimators.hpp>


using namespace std;
using namespace cv;
using namespace cv::detail;

// Scale parameter
const float scale = 0.25;

#define RAD2DEG(x) x * 180 / (float)CV_PI

const char *fileName;

Mat match(const Mat &centerImage, Mat &stitchedImage, const Mat &mask);


Point2f rotPoint(const Mat &R, const Point2f &p)
{
    Point2f rp;
    rp.x = (float)(R.at<double>(0, 0)*p.x + R.at<double>(0, 1)*p.y + R.at<double>(0, 2));
    rp.y = (float)(R.at<double>(1, 0)*p.x + R.at<double>(1, 1)*p.y + R.at<double>(1, 2));
    return rp;
}

/* Helper functions */
void decomposeAffine(float &s, float &theta, float &m, const Mat &R) {
    theta = (float)atan(R.at<double>(1, 0) / R.at<double>(0, 0));
    s = (float)sqrt(R.at<double>(0, 0)*R.at<double>(0, 0) + R.at<double>(1, 0)*R.at<double>(1, 0));
    m = (float)((R.at<double>(0,1) + R.at<double>(1,0)) / R.at<double>(0, 0));
}

Mat rotMatrix(float &theta) {
    Mat R(2, 3, CV_64F);
    R.at<double>(0, 0) =  cos(theta);
    R.at<double>(0, 1) = -sin(theta);
    R.at<double>(1, 0) =  sin(theta);
    R.at<double>(1, 1) =  cos(theta);
    
    R.at<double>(0, 2) = 0;
    R.at<double>(1, 2) = 0;
    
    return R;
}

/* Unused */
Mat correctGamma( Mat& img, double gamma ) {
    double inverse_gamma = 1.0 / gamma;
    
    Mat lut_matrix(1, 256, CV_8UC1 );
    uchar * ptr = lut_matrix.ptr();
    for( int i = 0; i < 256; i++ )
        ptr[i] = (int)( pow( (double) i / 255.0, inverse_gamma ) * 255.0 );
    
    Mat result;
    LUT( img, lut_matrix, result );
    
    return result;
}

void transformPoint(Point2f &p, const Mat &H) {
    cv::Mat src(3, 1, CV_64F);
    
    src.at<double>(0, 0) = (double)p.x;
    src.at<double>(1, 0) = (double)p.y;
    src.at<double>(2, 0) = 1.0;
    
    Mat dst = H * src;
    //dst /= dst.at<double>(2);
    
    p.x = (float)dst.at<double>(0, 0);
    p.y = (float)dst.at<double>(1, 0);
}

cv::Rect getProjectedArea(const int rows, const int cols, const Mat &H1) {
    Point2f p;
    Point2f tl, br;
    
    tl.x = std::numeric_limits<float>::max();
    tl.y = std::numeric_limits<float>::max();
    br.x = -std::numeric_limits<float>::max();
    br.y = -std::numeric_limits<float>::max();
    
    Mat H = H1.clone();
    H.at<double>(0, 2) = 0;
    H.at<double>(1, 2) = 0;
    
    // Top-Left
    p.x = -cols/2.f; p.y = -rows/2.f;
    //p.x = 0; p.y = 0;
    transformPoint(p, H);
    tl.x = std::min(tl.x, p.x);	tl.y = std::min(tl.y, p.y);
    br.x = std::max(br.x, p.x);	br.y = std::max(br.y, p.y);
    
    // Top-Right
    p.x = cols/2.f; p.y = -rows/2.f;
    //p.x = cols; p.y = 0;
    transformPoint(p, H);
    tl.x = std::min(tl.x, p.x);	tl.y = std::min(tl.y, p.y);
    br.x = std::max(br.x, p.x);	br.y = std::max(br.y, p.y);
    
    // Bottom-Right
    p.x = cols/2.f; p.y = rows/2.f;
    //p.x = cols; p.y = rows;
    transformPoint(p, H);
    tl.x = std::min(tl.x, p.x);	tl.y = std::min(tl.y, p.y);
    br.x = std::max(br.x, p.x);	br.y = std::max(br.y, p.y);
    
    // Bottom-Left
    p.x = -cols/2.f; p.y = rows/2.f;
    //p.x = 0; p.y = rows;
    transformPoint(p, H);
    tl.x = std::min(tl.x, p.x);	tl.y = std::min(tl.y, p.y);
    br.x = std::max(br.x, p.x);	br.y = std::max(br.y, p.y);
    
    tl = Point2f(floor(tl.x), floor(tl.y)) + Point2f(cols/2.f, rows/2.f);
    br = Point2f(ceil(br.x), ceil(br.y)) + Point2f(cols/2.f, rows/2.f);
    
    Point2f tr((float)H1.at<double>(0, 2), (float)H1.at<double>(1, 2) );
    
    // We let tl - tl to show that the corner after rotation now is [0, 0] + translation
    return cv::Rect(tl - tl + tr, Point2f(br.x + 1, br.y + 1) - tl + tr);
}

/* Output */
const char *imagesName[] = {"Center", "Top", "Bottom", "Left", "Right"};

/* Main class */
class RetinaStitcher {
private:
    Mat getGreenChannel(const Mat &image) {
        if(image.empty())
            return Mat();
        
        Mat bgr[3]; //since the images include an alpha channel, this needs to be 4 rather than 3
        
        split(image, bgr);
        
        return bgr[1];
    }
    
    Mat undistortImage(const Mat &uncorrectedImage, const Mat &distCoeff) {
        if(uncorrectedImage.empty())
            return Mat();
        
        Mat cameraMatrix = cv::Mat::eye(3, 3, CV_64FC1);
        
        cameraMatrix.at<double>(0, 2) = uncorrectedImage.cols / 2 ; //center of frame (x)
        cameraMatrix.at<double>(1, 2) = uncorrectedImage.rows / 2 ; //center of frame (y)
        cameraMatrix.at<double>(0, 0) = 1.0; //scale factor (1.0)
        cameraMatrix.at<double>(1, 1) = 1.0; //scale factor (1.0)
        
        // undistort this image
        Mat correctedImage;
        undistort(uncorrectedImage, correctedImage, cameraMatrix, distCoeff);
        
        return correctedImage;
    }
    
    void preprocess() {
        // cv::Ptr<cv::CLAHE> clahe = cv::createCLAHE(2.0, Size(8, 8));
        for( size_t i = 0; i < 5; ++i) {
            if(m_greenChannels[i].empty())
                continue;
            
            normalize(m_greenChannels[i], m_greenChannels[i], 0, 255, NORM_MINMAX, CV_8UC1);
            
            // Unfortunately our images don't respond well to CLAHE contrast enhancement
            // A lot of lectures using it with better results
            // Google: retinal fundus clahe
            
            // Contrast enhancement using CLAHE
            //clahe->apply(image, image);
            // Reduce the noise due to CLAHE processing
            //medianBlur(image, image, 3);
        }
    }
    
    void rotateImages() {
        for( size_t i = 1; i < 5; ++i) {
            // Skeep unseted images
            if(m_transform[i].empty())
                continue;
            
            /* Rotate images */
            Mat H = m_transform[i].clone();
            H.at<double>(0, 2) = 0;
            H.at<double>(1, 2) = 0;
            warpAffine(m_images[i], m_images_r[i], H, m_sizes[i], INTER_LINEAR, BORDER_CONSTANT);
            warpAffine(m_circularMask, m_maskes_r[i], H, m_sizes[i], INTER_NEAREST, BORDER_CONSTANT);
            
            // Original image, no more used
            m_images[i].release();
        }
    }
    
    void blendImages() {
        int dx, dy;
        
        m_stitchedRetina.create(m_stitchedImageArea.size(), m_images[0].type());
        
        /* Float variance of stitched image, for accumulation */
        Mat stitchedRetinaF32;
        /* Sum of accumulated images */
        Mat blendMaskSum;
        
        dx = m_corners[0].x - m_stitchedImageArea.x;
        dy = m_corners[0].y - m_stitchedImageArea.y;
        
        cv::Rect roi(dx, dy,  m_images[0].cols, m_images[0].rows);
        m_images[0].copyTo(m_stitchedRetina(roi), m_circularMask);
        
        m_stitchedRetina.convertTo(stitchedRetinaF32, CV_32FC3);
        // in OpenCV addition and division is done by channel
        // Thats why we need 3 chennels in mask sum
        blendMaskSum.create(m_stitchedImageArea.size(), CV_32FC3);
        blendMaskSum(roi).setTo(Scalar(1., 1., 1.), m_circularMask);
        
        /* Transformed Image & Mask */
        for( size_t i = 1; i < 5; ++i) {
            // Skeep unseted images
            if(m_transform[i].empty())
                continue;
            
            dx = m_corners[i].x - m_stitchedImageArea.x;
            dy = m_corners[i].y - m_stitchedImageArea.y;
            cv::Rect roi(dx, dy, m_sizes[i].width, m_sizes[i].height);
            
            add(m_images_r[i], stitchedRetinaF32(roi), stitchedRetinaF32(roi), m_maskes_r[i]);
            add(Scalar(1., 1., 1.), blendMaskSum(roi), blendMaskSum(roi), m_maskes_r[i]);
            
            // Release, no more used
            m_images_r[i].release();
            m_maskes_r[i].release();
        }
        
        // Don't care about zero division OpenCv handle it
        stitchedRetinaF32 /= blendMaskSum;
        
        // Or even just stay on CV_32FC3
        stitchedRetinaF32.convertTo(m_stitchedRetina, CV_8UC3);
    }
    
    /* Print Affine matrix informations */
    void printMatrixInfo(int idx) {
        Mat H = m_transform[idx];
        
        if(H.empty())
            cerr << "\tFailed to match." << endl;
        else {
            float s, theta, m;
            decomposeAffine(s, theta, m, H);
            
            cout << " \tTranslation: [" << H.at<double>(0, 2) << ", " << H.at<double>(1, 2) << "]" << endl;
            cout << " \tRoation: " << theta << endl;
            cout << " \tScale: " << s << endl;
            cout << " \tSkew: " << m << endl;
        }
    }
    
    /* Variables */
    /* Indices: Center = 0, Top = 1, Bottom = 2, Left = 3, Right = 4 */
    /* Original Images */
    Mat m_images[5];
    /* Scaled Images, green channels */
    Mat m_images_s[5];
    Mat m_greenChannels[5];
    /* Rotated Images, Masks */
    Mat m_images_r[5];
    Mat m_maskes_r[5];
    /* Affine matrices */
    Mat m_transform[5];
    /* Alpha circular mask Original & Scaled */
    Mat m_circularMask, m_circularMask_s;
    
    /* New Corners & Sizes after Rotation & translation */
    vector<cv::Point> m_corners;
    vector<cv::Size>  m_sizes;
    
    /* Stitched image size */
    cv::Rect m_stitchedImageArea;
    /* Stitched images */
    Mat m_stitchedRetina;
    
public:
    Mat stitchRetina(Mat &centerImage, Mat &topImage,
                     Mat &bottomImage,
                     Mat &leftImage,
                     Mat &rightImage,
                     Mat distCoeff) {
        
        /* Initialize data */
        m_corners.resize(5);
        m_sizes.resize(5);
        
        m_images[0] = centerImage;
        m_images[1] = topImage;
        m_images[2] = bottomImage;
        m_images[3] = leftImage;
        m_images[4] = rightImage;
        
        /* Undistord images */
        for(size_t i = 0; i < 5; ++i)
            m_images[i] = undistortImage(m_images[i], distCoeff);
        
        /* Set circular alpha mask */
        /* Center is the image centroid */
        /* Radius is the image height / 2 */
        m_circularMask.create(m_images[0].size(), CV_8UC1);
        m_circularMask.setTo(0);
        circle(m_circularMask, cv::Point(m_images[0].cols/2, m_images[0].rows/2), m_images[0].rows/2 - 1, Scalar(255, 255, 255), -1);
        
        /* Remove images background */
        for(size_t i = 0; i < 5; ++i)
            m_images[i].setTo(0, m_circularMask == 0);
        
        /* Optional, Gaussian Filter, to remove noise */
        /* Is better to do it in original sizes */
        /*
         GaussianBlur(centerImage, centerImage, Size(), 0.8);
         if(!topImage.empty()) GaussianBlur(topImage, topImage, Size(), 0.8);
         if(!bottomImage.empty()) GaussianBlur(bottomImage, bottomImage, Size(), 0.8);
         if(!leftImage.empty()) GaussianBlur(leftImage, leftImage, Size(), 0.8);
         if(!rightImage.empty()) GaussianBlur(rightImage, rightImage, Size(), 0.8);
         */
        
        /* Resize images. */
        /* To minimize compuation time and memory usage, we will find the rotation and translation */
        /* on the reduced images */
        for(size_t i = 0; i < 5; ++i)
            if(!m_images[i].empty()) resize(m_images[i], m_images_s[i], cv::Size(), scale, scale);
        
        resize(m_circularMask, m_circularMask_s, cv::Size(), scale, scale);
        
        /* Get green channels						*/
        /* Green channel:							*/
        /*  Had more contrast than the blue channel */
        /*  Had lower noise than the red channel    */
        for( size_t i = 0; i < 5; ++i)
            m_greenChannels[i] = getGreenChannel(m_images_s[i]);
        
        
        /* Preprocess images */
        /* Normalize + enhance contrast + median filter */
        preprocess();
        
        
        /* Set center image default parameters */
        m_transform[0] = Mat();	// Empty matix, no rotation will be made
        for( size_t i = 0; i < 5; ++i )
            m_sizes[i] = m_images[i].size();
        
        /* We use for matching a reduced mask, same as circular but with smaller radius (Estimated at 120 pixels in original size) */
        /* We have false positive matches on the retina boudary */
        /* A false ilumination due to the flash */
        Mat reducedMask;
        reducedMask.create(m_circularMask_s.size(), m_circularMask_s.type());
        reducedMask.setTo(0);
        circle(reducedMask, cv::Point(m_circularMask_s.cols/2, m_circularMask_s.rows/2),
               m_circularMask_s.rows/2 - (int)(120.*scale), Scalar(255, 255, 255), -1);
        
        /* Get image to image transformations */
        /* Top -> Center, Bottom -> Center, Left -> Center, Right -> Center */
        for( size_t i = 1; i < 5; ++i ) {
            if( m_greenChannels[i].empty() )
                continue;
            
            cout << imagesName[i] << " -> " << imagesName[0] << endl;
            
            m_transform[i] = match(m_greenChannels[0], m_greenChannels[i], reducedMask);
            printMatrixInfo(i);
        }
        
        /* Release memory of green channels, no more used */
        for( size_t i = 0; i < 5; ++i )
            m_greenChannels[i].release();
        
        /* Reduced mask, no more used */
        reducedMask.release();
        
        cout << "Blending..." << endl;
        
        /* Set the transformed images Corners & Sizes  */
        for( int i = 1; i <= 4; ++i) {
            //Skeep faulty matches or unseted images.
            if(m_transform[i].empty())
                continue;
            
            cv::Rect newArea = getProjectedArea(m_sizes[i].height, m_sizes[i].width, m_transform[i]);
            
            m_corners[i] = newArea.tl();
            m_sizes[i] = newArea.size();
        }
        
        /* Set stiched image size */
        /* Corners & Sizes with 0, 0 will not affect final result */
        m_stitchedImageArea = resultRoi(m_corners, m_sizes);
        
        /* Apply rotation */
        rotateImages();
        
        /* Simple blender */
        blendImages();
        
        cout << "Blending (Ok)" << endl;
        
        return m_stitchedRetina;
    }
};

/*
 int main( int argc, char** argv )
 {
 fileName = NULL;
 
 Mat centerImage, topImage, bottomImage, leftImage, rightImage;
 Mat distCoeff;
 
 // Load program arguments
 for (int i = 1; i < argc; ++i) {
 //Load center image
 if (string(argv[i]) == "-c") {
 centerImage = imread(argv[i + 1], CV_LOAD_IMAGE_COLOR);
 i++;
 }
 //Load top image
 else if (string(argv[i]) == "-t") {
 topImage = imread(argv[i + 1], CV_LOAD_IMAGE_COLOR);
 i++;
 }
 //Load bottom image
 else if (string(argv[i]) == "-b") {
 bottomImage = imread(argv[i + 1], CV_LOAD_IMAGE_COLOR);
 i++;
 }
 //Load left image
 else if (string(argv[i]) == "-l") {
 leftImage = imread(argv[i + 1], CV_LOAD_IMAGE_COLOR);
 i++;
 }
 //Load right image
 else if (string(argv[i]) == "-r") {
 rightImage = imread(argv[i + 1], CV_LOAD_IMAGE_COLOR);
 i++;
 }
 //Load distortion coefficients
 else if (string(argv[i]) == "-d") {
 distCoeff = cv::Mat::zeros(8, 1, CV_64FC1);
 
 distCoeff.at<double>(0, 0) = atof(argv[i + 1]);
 distCoeff.at<double>(1, 0) = atof(argv[i + 2]);
 distCoeff.at<double>(2, 0) = atof(argv[i + 3]);
 distCoeff.at<double>(3, 0) = atof(argv[i + 4]);
 
 i += 4;
 }
 else if (string(argv[i]) == "-n") {
 fileName = argv[i+1];
 i++;
 }
 }
 
 if(centerImage.empty()) {
 cerr << "Please provide the center retina image." << endl;
 exit(-1);
 }
 
 //if the user did not input distortion parameters, set them to zero
 if (distCoeff.empty() ) {
 distCoeff = cv::Mat::zeros(8, 1, CV_64FC1);
 
 distCoeff.at<double>(0, 0) = 0;
 distCoeff.at<double>(1, 0) = 0;
 distCoeff.at<double>(2, 0) = 0;
 distCoeff.at<double>(3, 0) = 0;
 }
 
 RetinaStitcher stitcher;
 Mat stitchedRetina = stitcher.stitchRetina(centerImage, topImage, bottomImage,
 leftImage, rightImage, distCoeff);
 
 string fName;
 if(fileName == NULL)
 fName = "stitchedRetina";
 else
 fName = fileName;
 
 fName += ".jpg";
 imwrite(fName, stitchedRetina);
 
 
 waitKey(0);
 
 return 0;
 }
 */

Mat match(const Mat &centerImage, Mat &stitchedImage, const Mat &mask) {
    vector<cv::detail::ImageFeatures> features(2);
    
    /* Get SURF keypoints with their features */
    SURF finder;
    finder(stitchedImage, mask, features[0].keypoints, features[0].descriptors);
    finder(centerImage, mask, features[1].keypoints, features[1].descriptors);
    
    features[0].img_idx = 0;
    features[0].img_size = stitchedImage.size();
    
    features[1].img_idx = 1;
    features[1].img_size = centerImage.size();
    
    vector<MatchesInfo> pairwise_matches;
    /* SURF match ratio parameter can be set to 0.65 but since we have much noisy */
    /* images we retain also lower matches accuracy */
    BestOf2NearestMatcher matcher(false, 0.6f);
    matcher(features, pairwise_matches);
    matcher.collectGarbage();
    
    /* DEBUG */
    /* Show Image to Image matches */
    
    //Mat imgMatch;
    //drawMatches(stitchedImage, features[0].keypoints, centerImage, features[1].keypoints, pairwise_matches[1].matches, imgMatch);
    //imwrite("matches.jpg", imgMatch);
    
    
    /* pairwise_matches[1]  is for 0->1 matches */
    if( pairwise_matches[1].matches.empty() ) {
        //std::cerr << "No Matches" << std::endl;
        return Mat();
    }
    
    const std::vector<DMatch> &matches = pairwise_matches[1].matches;
    vector<Point2f> queryPoints, trainPoints;
    for(size_t j = 0; j < matches.size(); ++j) {
        cv::Point srcPoint = features[0].keypoints[ matches[j].queryIdx ].pt,
        dstPoint = features[1].keypoints[ matches[j].trainIdx ].pt;
        
        queryPoints.push_back(srcPoint);
        trainPoints.push_back(dstPoint);
    }
    
    Mat R = estimateRigidTransform(queryPoints, trainPoints, false);
    
    /* Scale back translation to original size */
    if(!R.empty()) {
        R.at<double>(0, 2) /= scale;
        R.at<double>(1, 2) /= scale;
    }
    
    return R;
}


//-----------------------------------------------



- (UIImage*) stitch
{
    //seems we're unable to handle full sized images with the 5S (not enough memory)
    self.centerImage = [self.centerImage resizedImageWithScaleFactor:1.5];
    self.topImage = [self.topImage resizedImageWithScaleFactor:1.5];
    self.bottomImage = [self.bottomImage resizedImageWithScaleFactor:1.5];
    self.leftImage = [self.leftImage resizedImageWithScaleFactor:1.5];
    self.rightImage = [self.rightImage resizedImageWithScaleFactor:1.5];
    
    cv::Mat centerMat, topMat, bottomMat, leftMat, rightMat;
    
    UIImageToMat(self.centerImage, centerMat);
    UIImageToMat(self.topImage, topMat);
    UIImageToMat(self.bottomImage, bottomMat);
    UIImageToMat(self.leftImage, leftMat);
    UIImageToMat(self.rightImage, rightMat);
    
    cvtColor(centerMat, centerMat, CV_RGBA2RGB, 3);
    cvtColor(topMat, topMat, CV_RGBA2RGB, 3);
    cvtColor(bottomMat, bottomMat, CV_RGBA2RGB, 3);
    cvtColor(leftMat, leftMat, CV_RGBA2RGB, 3);
    cvtColor(rightMat, rightMat, CV_RGBA2RGB, 3);
    
    self.centerImage = nil;
    self.topImage = nil;
    self.bottomImage = nil;
    self.leftImage = nil;
    self.rightImage = nil;
    
    cv::Mat distCoeff = cv::Mat::zeros(8, 1, CV_64FC1);
        
    distCoeff.at<double>(0, 0) = 0;
    distCoeff.at<double>(1, 0) = 0;
    distCoeff.at<double>(2, 0) = 0;
    distCoeff.at<double>(3, 0) = 0;
    
    RetinaStitcher stitcher;
    cv::Mat stitchedRetina = stitcher.stitchRetina(centerMat, topMat, bottomMat,
                                               leftMat, rightMat, distCoeff);
    
    UIImage* stitchedImage = MatToUIImage(stitchedRetina);
    
    //imwrite("stitchedRetina.jpg", stitchedRetina);
    
    stitchedRetina.release();
    

    //return self.centerImage;
    return stitchedImage;
    
}


@end
