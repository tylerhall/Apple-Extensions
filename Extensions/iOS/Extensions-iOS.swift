import UIKit

extension UIColor {
    public static func hex(_ str: String?) -> UIColor? {
        guard let hex = str, (hex.count == 6) || (hex.count == 7) else { return nil }
        
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIBezierPath {
    var points: [CGPoint]? {
        var bezierPoints = NSMutableArray()
        let path = cgPath
        path.apply(info: &bezierPoints) { info, element in
            guard let resultingPoints = info?.assumingMemoryBound(to: NSMutableArray.self) else { return }

            let points = element.pointee.points
            let type = element.pointee.type

            switch type {
            case .moveToPoint:
                resultingPoints.pointee.add([NSNumber(value: Float(points[0].x)), NSNumber(value: Float(points[0].y))])

            case .addLineToPoint:
                resultingPoints.pointee.add([NSNumber(value: Float(points[0].x)), NSNumber(value: Float(points[0].y))])

            case .addQuadCurveToPoint:
                resultingPoints.pointee.add([NSNumber(value: Float(points[0].x)), NSNumber(value: Float(points[0].y))])
                resultingPoints.pointee.add([NSNumber(value: Float(points[1].x)), NSNumber(value: Float(points[1].y))])

            case .addCurveToPoint:
                resultingPoints.pointee.add([NSNumber(value: Float(points[0].x)), NSNumber(value: Float(points[0].y))])
                resultingPoints.pointee.add([NSNumber(value: Float(points[1].x)), NSNumber(value: Float(points[1].y))])
                resultingPoints.pointee.add([NSNumber(value: Float(points[2].x)), NSNumber(value: Float(points[2].y))])

            case .closeSubpath:
                break
            @unknown default:
                fatalError()
            }
        }

        var points = [CGPoint]()
        for p in bezierPoints {
            let arr = p as! [NSNumber]
            points.append(CGPoint(x: arr[0] as! CGFloat, y: arr[1] as! CGFloat))
        }

        return points
    }

    static func pathFromPoints(_ points: [CGPoint]) -> UIBezierPath? {
        guard let firstPoint = points.first else { return nil }
        
        let path = UIBezierPath()

        path.move(to: firstPoint)

        for i in 1..<points.count {
            path.addLine(to: points[i])
        }

        path.close()

        return path
    }

    static func pathFromPoint(_ point: CGPoint, width: CGFloat = 1) -> UIBezierPath {
        let pixelRect = CGRect(origin: point, size: CGSize(width: width, height: width))
        return UIBezierPath(rect: pixelRect)
    }
}

extension UIImage {
    static func resizedImage(at url: URL, for size: CGSize) -> UIImage? {
        guard let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil) else { return nil }
        guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else { return nil }

        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: image.bitsPerComponent,
                                bytesPerRow: image.bytesPerRow,
                                space: CGColorSpaceCreateDeviceRGB(), // image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        context?.interpolationQuality = .high
        context?.draw(image, in: CGRect(origin: .zero, size: size))

        guard let scaledImage = context?.makeImage() else { print("bad image"); return nil }

        return UIImage(cgImage: scaledImage)
    }
}

extension UIView {
    var localCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }

    func pinEdges(to other: UIView, offset: CGFloat = 0) {
        leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: offset).isActive = true
        trailingAnchor.constraint(equalTo: other.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: other.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: other.bottomAnchor).isActive = true
    }
}
