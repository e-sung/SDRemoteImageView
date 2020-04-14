//
//  SDImageLoader.swift
//  SDRemoteImageView
//
//  Created by 류성두 on 2020/04/12.
//

import Foundation

public class SDRemoteImageLoader {
    public static var shared = SDRemoteImageLoader()
    /// optional error image to show when downloading has failed
    public static var defaultErrorImage: UIImage?
    /// optional placeholder image to show while downloading image
    public static var defaultPlaceHolderImage: UIImage?
    /// DispatchQueue where Decoding should happen.
    static let decodingQueue = DispatchQueue(label: "SDRemoteImageView Decoding Queue", qos: .userInteractive)

    public static var imageCache = URLCache(memoryCapacity: Int(ProcessInfo.processInfo.physicalMemory / 100),
                                             diskCapacity: 1024*1024,
                                             diskPath: nil)
    private var decodingCachedImageWorkItem: DispatchWorkItem?
    private var session = URLSession.shared
    private var downloadTask: URLSessionDataTask?
    
    /**
     Fetch image data from url, downsample the data, and display it.
     - parameters:
        - url: location of the image on the server
        - placeHolderImage: image to show until downloading is finished.  default is nil
        - errorImage: image to show when something has gone wrong. default is nil
        - completionHandler: callback to notify that downloading has finished. default is nil
    
    */
    public func loadImage(from url: URL?, placeHolderImage: UIImage? = nil, errorImage: UIImage? = nil, imageSize:CGSize, shouldCache:Bool = true, shouldDownSample:Bool = true, completionHandler: @escaping ((Result<UIImage, Error>) -> Void)) {
        guard let url = url else {
            completionHandler(.failure(RemoteImageViewError.unknown))
            return
        }
        
        let scale = UIScreen.main.scale
        
        if let cachedResponse = Self.imageCache.cachedResponse(for: URLRequest(url: url)) {
            decodingCachedImageWorkItem?.cancel()
            decodingCachedImageWorkItem = DispatchWorkItem(block: { [weak self] in
                let image = shouldDownSample ? self?.downsample(imageData: cachedResponse.data, for: imageSize, scale: scale) : UIImage(data: cachedResponse.data)
                if let image = image {
                    completionHandler(.success(image))
                }
                else {
                    if shouldDownSample {
                        completionHandler(.failure(RemoteImageViewError.downSampleFailure))
                    }
                    else {
                        completionHandler(.failure(RemoteImageViewError.invalidResponse))
                    }
                }
            })
            Self.decodingQueue.async(execute: decodingCachedImageWorkItem!)
        }
        else {
            downloadTask?.cancel()
            downloadTask = dataTaskToDownloadImage(for: url,
                                    placeHolderImage: placeHolderImage,
                                    errorImage: errorImage,
                                    shouldCache: shouldCache,
                                    shouldDownSample: shouldDownSample,
                                    size: imageSize,
                                    scale: scale,
                                    completionHandler: completionHandler)
            downloadTask?.resume()
        }
    }
    
    private func dataTaskToDownloadImage(for url: URL,
                                         placeHolderImage: UIImage?,
                                         errorImage: UIImage?,
                                         shouldCache: Bool,
                                         shouldDownSample: Bool,
                                         size: CGSize,
                                         scale: CGFloat,
                                         completionHandler: @escaping ((Result<UIImage, Error>)->Void)) -> URLSessionDataTask {
        return session.dataTask(with: url, completionHandler: { [weak self] data, response, error in
            guard let data = data, let response = response else {
                DispatchQueue.main.async {
                    completionHandler(.failure(error ?? RemoteImageViewError.invalidResponse))
                }
                return
            }
            if shouldCache {
                let cachedResponse = CachedURLResponse(response: response, data: data)
                Self.imageCache.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
            }
            if let image = self?.downsample(imageData: data, for: size, scale: scale) {
                completionHandler(Result.success(image))
            }
            else {
                completionHandler(.failure(RemoteImageViewError.unknown))
            }
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
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            assertionFailure()
            return UIImage()
        }
        return UIImage(cgImage: downsampledImage)
    }
}
