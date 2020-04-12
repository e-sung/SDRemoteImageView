//
//  File.swift
//  SDRemoteImageView
//
//  Created by 류성두 on 2020/04/12.
//

import Foundation
import UIKit

extension UIImageView: RemoteImageDownloadable { }

public extension SDRemoteImageWrapper where Base: UIImageView {
    /**
     Fetch image data from url, downsample the data, and display it.
     - parameters:
        - url: location of the image on the server
        - placeHolderImage: image to show until downloading is finished.  default is nil
        - errorImage: image to show when something has gone wrong. default is nil
        - completionHandler: callback to notify that downloading has finished. default is nil
    
    */
    func loadImage(from url: URL?, placeHolderImage: UIImage? = nil, errorImage: UIImage? = nil, transitionTime: TimeInterval = 0, shouldCache:Bool = true, shouldDownSample:Bool = true, completionHandler: (@escaping (Result<UIImage, Error>) -> Void) = { _ in }) {
        base.image = placeHolderImage
        let baseHash = base.hash
        let imageLoader = imageProcessors[baseHash] ?? SDRemoteImageLoader()
        imageProcessors[baseHash] = imageLoader

        imageLoader.loadImage(from: url, placeHolderImage: placeHolderImage, errorImage: errorImage, imageSize: base.frame.size, shouldCache: shouldCache, shouldDownSample: shouldDownSample) { [weak base] result in
            switch result {
            case let .success(image):
                base?.applyImage(image)
            case let .failure(error):
                print(error.localizedDescription)
            }
            DispatchQueue.main.async {
                completionHandler(result)
                imageProcessors.removeValue(forKey: baseHash)
            }
        }
    }
}

fileprivate var imageProcessors:[Int:SDRemoteImageLoader] = [:]

fileprivate extension UIImageView {
    func applyImage(_ image: UIImage?, transitionTime:TimeInterval = 0.4, completionHandler: ((Result<UIImage?, Error>) -> Void)? = nil) {
        DispatchQueue.main.async {[weak self] in
            guard let image = image else {
                completionHandler?(.failure(RemoteImageViewError.unknown))
                self?.image = SDRemoteImageLoader.defaultErrorImage
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
}
