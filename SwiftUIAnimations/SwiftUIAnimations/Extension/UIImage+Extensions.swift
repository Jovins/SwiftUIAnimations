extension UIImage {
    public func resizeImage(newSize: CGSize, placeholderImage: UIImage? = nil) -> UIImage? {
        if __CGSizeEqualToSize(self.size, newSize) {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: newSize), with: .scaleAspectFit)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    static func imageWithTintColor(named: String, color: UIColor = UIColor.GlobalIconPrimary) -> UIImage? {
        return UIImage.init(named: named)?.withRenderingMode(.alwaysTemplate).imageMaskedAndTinted(with: color)
    }

    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }

    static func getHeroPlaceholderImage(isQandA: Bool) -> UIImage? {
        let imageNamedPrefix = isQandA ? "qandaHeroImage" : "noHeroImagPlaceholder"
        let heroPlaceholderNumber = (Int.random(in: 1...5) % (isQandA ? 4 : 5)) + 1
        return UIImage(named: "\(imageNamedPrefix)\(heroPlaceholderNumber)")
    }

    func merge(with topImage: UIImage, backgroundTargetSize: CGSize? = nil) -> UIImage? {
        let backgroundImage = self
        var backgroundSize: CGSize = size
        if let backgroundTargetSize = backgroundTargetSize {
            backgroundSize = backgroundTargetSize
        }

        UIGraphicsBeginImageContext(backgroundSize)
        let areaSize = CGRect(x: 0, y: 0, width: backgroundSize.width, height: backgroundSize.height)
        backgroundImage.draw(in: areaSize)

        topImage.draw(in: areaSize, blendMode: .normal, alpha: 1.0)

        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return mergedImage
    }

    static func circularImage(size: CGSize, color: UIColor) -> UIImage? {
        UIGraphicsImageRenderer(size: size).image { _ in
            let circleRect = CGRect(origin: .zero, size: size)
            let circlePath = UIBezierPath(ovalIn: circleRect)
            color.setFill()
            circlePath.fill()
        }
    }
}

protocol Resizable {
    mutating func resize(from originalSize: CGSize) -> CGSize
}

enum TargetWidthHeight: Resizable {
    case width(_ width: CGFloat), height(_ height: CGFloat)
    mutating func resize(from originalSize: CGSize) -> CGSize {
        switch self {
        case .width(let width):
            guard width > 0 else { return .zero }
            let height = (width * originalSize.height) / originalSize.width
            return height > 0 ? CGSize(width: width, height: height) : .zero
        case .height(let height):
            guard height > 0 else { return .zero }
            let width = (height * originalSize.width) / originalSize.height
            return width > 0 ? CGSize(width: width, height: height) : .zero
        }
    }
}
