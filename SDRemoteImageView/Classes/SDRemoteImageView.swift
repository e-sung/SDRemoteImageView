import UIKit

/// UIImageView subclass that displays image from remote server
public class SDRemoteImageView: UIImageView {
    
    /// optional error image to show when downloading has failed
    public static var defaultErrorImage: UIImage?
    /// optional placeholder image to show while downloading image
    public static var defaultPlaceHolderImage: UIImage?
    /// DispatchQueue where Decoding should happen.
    private static let decodingQueue = DispatchQueue(label: "SDRemoteImageView Decoding Queue", qos: .userInteractive)
    
    private static var imageCache = URLCache(memoryCapacity: Int(ProcessInfo.processInfo.physicalMemory / 10),
                                             diskCapacity: 1024*1024,
                                             diskPath: nil)
    private var decodingCachedImageWorkItem: DispatchWorkItem?
    private var downloadTask: URLSessionDataTask?
    
    /**
     Fetch image data from url, downsample the data, and display it.
     - parameters:
        - url: location of the image on the server
        - placeHolderImage: image to show until downloading is finished.  default is nil
        - errorImage: image to show when something has gone wrong. default is nil
        - completionHandler: callback to notify that downloading has finished. default is nil
    
    */
    public func loadImage(from url: URL?, placeHolderImage: UIImage? = nil, errorImage: UIImage? = nil, transitionTime: TimeInterval = 0, shouldCache:Bool = true, shouldDownSample:Bool = true, completionHandler: ((Result<UIImage?, Error>) -> Void)? = nil) {
        
        downloadTask?.cancel()
        guard let url = url else {
            // shows default error image and return failure
            self.image = SDRemoteImageView.defaultErrorImage
            completionHandler?(.failure(RemoteImageViewError.unknown))
            return
        }
        
        let pointSize = frame.size
        let scale = UIScreen.main.scale
        
        if let cachedResponse = SDRemoteImageView.imageCache.cachedResponse(for: URLRequest(url: url)) {
            applyImage(from: cachedResponse,
                       shouldDownSample: shouldDownSample,
                       size: pointSize,
                       scale: scale,
                       completionHandler: completionHandler)
        }
        else {
            // show placeholder if provided
            if let placeHolderImage = placeHolderImage {
                self.image = placeHolderImage
            }
            else if let defaultPlaceHolderImage = SDRemoteImageView.defaultErrorImage {
                self.image = defaultPlaceHolderImage
            }
            downloadTask = dataTaskToDownloadImage(for: url,
                                    placeHolderImage: placeHolderImage,
                                    errorImage: errorImage,
                                    transitionTime: transitionTime,
                                    shouldCache: shouldCache,
                                    shouldDownSample: shouldDownSample,
                                    size: pointSize,
                                    scale: scale,
                                    completionHandler: completionHandler)
            downloadTask?.resume()
        }
    }
    
    private func applyImage(from cachedResponse: CachedURLResponse,
                            shouldDownSample: Bool,
                            size:CGSize, scale: CGFloat,
                            completionHandler: ((Result<UIImage?, Error>) -> Void)? = nil) {
        decodingCachedImageWorkItem?.cancel()
        decodingCachedImageWorkItem = DispatchWorkItem(block: { [weak self] in
            let data = cachedResponse.data
            let image = shouldDownSample ? self?.downsample(imageData: data, for: size, scale: scale) : UIImage(data: data)
            self?.applyImage(image, completionHandler: completionHandler)
        })
        SDRemoteImageView.decodingQueue.async(execute: decodingCachedImageWorkItem!)
    }
    
    private func dataTaskToDownloadImage(for url: URL,
                                         placeHolderImage: UIImage?,
                                         errorImage: UIImage?,
                                         transitionTime: TimeInterval,
                                         shouldCache: Bool,
                                         shouldDownSample: Bool,
                                         size: CGSize,
                                         scale: CGFloat,
                                         completionHandler: ((Result<UIImage?, Error>)->Void)? = nil) -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: url, completionHandler: { [weak self] data, response, error in
            guard let data = data, let response = response else {
                DispatchQueue.main.async {
                    self?.image = SDRemoteImageView.defaultErrorImage
                    completionHandler?(.failure(error ?? RemoteImageViewError.invalidResponse))
                }
                return
            }
            let image:UIImage? = shouldDownSample ? self?.downsample(imageData: data, for: size, scale: scale) : UIImage(data: data)
            if shouldCache {
                let cachedResponse = CachedURLResponse(response: response, data: data)
                SDRemoteImageView.imageCache.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
            }
            self?.applyImage(image, transitionTime: transitionTime, completionHandler: completionHandler )
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
    
    private func applyImage(_ image: UIImage?, transitionTime:TimeInterval = 0, completionHandler: ((Result<UIImage?, Error>) -> Void)? = nil) {
        DispatchQueue.main.async {[weak self] in
            guard let sself = self else { return }
            guard let image = image else {
                completionHandler?(.failure(RemoteImageViewError.unknown))
                sself.image = SDRemoteImageView.defaultErrorImage
                return
            }
            
            self?.alpha = 0
            self?.image = image
            UIView.animate(withDuration: transitionTime, animations: {
                self?.alpha = 1
            }, completion: { _ in
                completionHandler?(.success(image))
            })
        }
    }
    
    enum RemoteImageViewError:Error {
        case invalidResponse
        case unknown
    }
}
