import UIKit

/// UIImageView subclass that displays image from remote server
public class SDRemoteImageView: UIImageView {
    
    /// optional error image to show when downloading has failed
    public static var defaultErrorImage: UIImage?
    /// optional placeholder image to show while downloading image
    public static var defaultPlaceHolderImage: UIImage?
    /// DispatchQueue where Decoding should happen.
    public static let decodingQueue = DispatchQueue(label: "SDRemoteImageView Decoding Queue", qos: .userInteractive)
    
    /**
     Fetch image data from url, downsample the data, and display it.
     - parameters:
        - url: location of the image on the server
        - placeHolderImage: image to show until downloading is finished.  default is nil
        - errorImage: image to show when something has gone wrong. default is nil
        - completionHandler: callback to notify that downloading has finished. default is nil
    
    */
    public func loadImage(from url: URL?, placeHolderImage: UIImage? = nil, errorImage: UIImage? = nil, shouldCache:Bool = true, shouldDownSample:Bool = true, completionHandler: @escaping (Result<UIImage?, Error>) -> Void) {
        guard let url = url else {
            // shows default error image and return failure
            self.image = SDRemoteImageView.defaultErrorImage
            completionHandler(.failure(RemoteImageViewError.unknown))
            return
        }
        
        let pointSize = frame.size
        let scale = UIScreen.main.scale
        
        if let cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url)) {
            applyImage(from: cachedResponse,
                       shouldDownSample: shouldDownSample,
                       size: pointSize,
                       scale: scale,
                       completionHandler: completionHandler)
        }
        else {
            // show placeholder if provided
            self.image = placeHolderImage ?? SDRemoteImageView.defaultPlaceHolderImage
            dataTaskToDownloadImage(for: url,
                                    placeHolderImage: placeHolderImage,
                                    errorImage: errorImage,
                                    shouldCache: shouldCache,
                                    shouldDownSample: shouldDownSample,
                                    size: pointSize,
                                    scale: scale,
                                    completionHandler: completionHandler)
                .resume()
        }
    }
    
    private func applyImage(from cachedResponse: CachedURLResponse,
                            shouldDownSample: Bool,
                            size:CGSize, scale: CGFloat,
                            completionHandler: @escaping(Result<UIImage?, Error>) -> Void) {
        SDRemoteImageView.decodingQueue.async { [weak self] in
            let data = cachedResponse.data
            let image = shouldDownSample ? self?.downsample(imageData: data, for: size, scale: scale) : UIImage(data: data)
            self?.applyImage(image, completionHandler: completionHandler)
        }
    }
    
    private func dataTaskToDownloadImage(for url: URL,
                                         placeHolderImage: UIImage?,
                                         errorImage: UIImage?,
                                         shouldCache: Bool,
                                         shouldDownSample: Bool,
                                         size: CGSize,
                                         scale: CGFloat,
                                         completionHandler: @escaping(Result<UIImage?, Error>)->Void) -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: url, completionHandler: { [weak self] data, response, error in
            guard let data = data, let response = response else {
                self?.image = SDRemoteImageView.defaultErrorImage
                completionHandler(.failure(error ?? RemoteImageViewError.invalidResponse))
                return
            }
            let image:UIImage? = shouldDownSample ? self?.downsample(imageData: data, for: size, scale: scale) : UIImage(data: data)
            if shouldCache {
                let cachedResponse = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
            }
            self?.applyImage(image, completionHandler: completionHandler )
        })
    }
    
    private func downsample(imageData: Data, for size: CGSize, scale:CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary // prevent immediate dataBuffer decoding
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else { return UIImage() }
        let maxDimensionInPixels = max(size.width, size.height) * scale
        let downsampleOptions =
            [kCGImageSourceCreateThumbnailFromImageAlways: true,
             kCGImageSourceShouldCacheImmediately: true, //  decode dataBuffer to create imageBuffer when creating `thumbNail`
             kCGImageSourceCreateThumbnailWithTransform: true,
             kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return UIImage() }
        return UIImage(cgImage: downsampledImage)
    }
    
    private func applyImage(_ image: UIImage?, completionHandler: @escaping (Result<UIImage?, Error>) -> Void) {
        guard let image = image else {
            completionHandler(.failure(RemoteImageViewError.unknown))
            self.image = SDRemoteImageView.defaultErrorImage
            return
        }
        DispatchQueue.main.async {[weak self] in
            guard let sself = self else { return }
            UIView.transition(with: sself,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: {
                                sself.image = image
                                completionHandler(.success(image))
            }
            , completion: nil)
        }
    }
    
    enum RemoteImageViewError:Error {
        case invalidResponse
        case unknown
    }
}
