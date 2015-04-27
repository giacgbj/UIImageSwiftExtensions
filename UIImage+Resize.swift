//
//  UIImage+Resize.swift
//
//  Created by Trevor Harmon on 08/05/09.
//  Swift port by Giacomo Boccardo on 03/18/15.
//
//  Free for personal or commercial use, with or without modification
//  No warranty is expressed or implied.
//

public extension UIImage {
    
    // Returns a copy of this image that is cropped to the given bounds.
    // The bounds will be adjusted using CGRectIntegral.
    // This method ignores the image's imageOrientation setting.
    public func croppedImage(bounds: CGRect) -> UIImage {
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(self.CGImage, bounds)
        return UIImage(CGImage: imageRef)!
    }
    
    public func thumbnailImage(thumbnailSize: Int, transparentBorder borderSize:Int, cornerRadius:Int, interpolationQuality quality:CGInterpolationQuality) -> UIImage {
        var resizedImage = self.resizedImageWithContentMode(.ScaleAspectFill, bounds: CGSizeMake(CGFloat(thumbnailSize), CGFloat(thumbnailSize)), interpolationQuality: quality)
 
        // Crop out any part of the image that's larger than the thumbnail size
        // The cropped rect must be centered on the resized image
        // Round the origin points so that the size isn't altered when CGRectIntegral is later invoked
        let cropRect = CGRectMake(
            round((resizedImage.size.width - CGFloat(thumbnailSize))/2),
            round((resizedImage.size.height - CGFloat(thumbnailSize))/2),
            CGFloat(thumbnailSize),
            CGFloat(thumbnailSize)
        )
        
        let croppedImage = resizedImage.croppedImage(cropRect)
        let transparentBorderImage = borderSize != 0 ? croppedImage.transparentBorderImage(borderSize) : croppedImage
        
        return transparentBorderImage.roundedCornerImage(cornerSize: cornerRadius, borderSize: borderSize)
    }
    
    // Returns a rescaled copy of the image, taking into account its orientation
    // The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
    public func resizedImage(newSize: CGSize, interpolationQuality quality: CGInterpolationQuality) -> UIImage {
        var drawTransposed: Bool
        
        switch(self.imageOrientation) {
            case .Left, .LeftMirrored, .Right, .RightMirrored:
                drawTransposed = true
            default:
                drawTransposed = false
        }
        
        return self.resizedImage(
            newSize,
            transform: self.transformForOrientation(newSize),
            drawTransposed: drawTransposed,
            interpolationQuality: quality
        )
    }
    
    public func resizedImageWithContentMode(contentMode: UIViewContentMode, bounds: CGSize, interpolationQuality quality: CGInterpolationQuality) -> UIImage {
        let horizontalRatio = bounds.width / self.size.width
        let verticalRatio = bounds.height / self.size.height
        var ratio: CGFloat = 1

        switch(contentMode) {
            case .ScaleAspectFill:
                ratio = max(horizontalRatio, verticalRatio)
            case .ScaleAspectFit:
                ratio = min(horizontalRatio, verticalRatio)
            default:
                fatalError("Unsupported content mode \(contentMode)")
        }

        let newSize: CGSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio)
        return self.resizedImage(newSize, interpolationQuality: quality)
    }
    
    private func normalizeBitmapInfo(bI: CGBitmapInfo) -> CGBitmapInfo {
        var alphaInfo: CGBitmapInfo = bI & CGBitmapInfo.AlphaInfoMask
        
        if alphaInfo == CGBitmapInfo(CGImageAlphaInfo.Last.rawValue) {
            alphaInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
        }

        if alphaInfo == CGBitmapInfo(CGImageAlphaInfo.First.rawValue) {
            alphaInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedFirst.rawValue)
        }

        var newBI: CGBitmapInfo = bI & ~CGBitmapInfo.AlphaInfoMask;

        newBI |= alphaInfo;

        return newBI
    }
    
    private func resizedImage(newSize: CGSize, transform: CGAffineTransform, drawTransposed transpose: Bool, interpolationQuality quality: CGInterpolationQuality) -> UIImage {
        let newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height))
        let transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width)
        let imageRef: CGImageRef = self.CGImage

        // Build a context that's the same dimensions as the new size
        let bitmap: CGContextRef = CGBitmapContextCreate(
            nil,
            Int(newRect.size.width),
            Int(newRect.size.height),
            CGImageGetBitsPerComponent(imageRef),
            0,
            CGImageGetColorSpace(imageRef),
            normalizeBitmapInfo(CGImageGetBitmapInfo(imageRef))
        )

        // Rotate and/or flip the image if required by its orientation
        CGContextConcatCTM(bitmap, transform)

        // Set the quality level to use when rescaling
        CGContextSetInterpolationQuality(bitmap, quality)

        // Draw into the context; this scales the image
        CGContextDrawImage(bitmap, transpose ? transposedRect: newRect, imageRef)

        // Get the resized image from the context and a UIImage
        let newImageRef: CGImageRef = CGBitmapContextCreateImage(bitmap)
        return UIImage(CGImage: newImageRef)!
    }
    
    private func transformForOrientation(newSize: CGSize) -> CGAffineTransform {
        var transform: CGAffineTransform = CGAffineTransformIdentity
        
        switch (self.imageOrientation) {
            case .Down, .DownMirrored:
                // EXIF = 3 / 4
                transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            case .Left, .LeftMirrored:
                // EXIF = 6 / 5
                transform = CGAffineTransformTranslate(transform, newSize.width, 0)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            case .Right, .RightMirrored:
                // EXIF = 8 / 7
                transform = CGAffineTransformTranslate(transform, 0, newSize.height)
                transform = CGAffineTransformRotate(transform, -CGFloat(M_PI_2))
            default:
                break
        }
        
        switch(self.imageOrientation) {
            case .UpMirrored, .DownMirrored:
                // EXIF = 2 / 4
                transform = CGAffineTransformTranslate(transform, newSize.width, 0)
                transform = CGAffineTransformScale(transform, -1, 1)
            case .LeftMirrored, .RightMirrored:
                // EXIF = 5 / 7
                transform = CGAffineTransformTranslate(transform, newSize.height, 0)
                transform = CGAffineTransformScale(transform, -1, 1)
            default:
                break
        }
        
        return transform
    }
}
