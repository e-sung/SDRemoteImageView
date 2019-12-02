//
//  ViewController.swift
//  RemoteImageView
//
//  Created by e-sung on 12/01/2019.
//  Copyright (c) 2019 e-sung. All rights reserved.
//

import UIKit
import SDRemoteImageView

class ViewController: UIViewController {

    @IBOutlet var remoteImageView: SDRemoteImageView!
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var labelMemorySize: UILabel!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    let imageURL = URL(string: "https://raw.githubusercontent.com/e-sung/SDRemoteImageView/master/sampleImage.jpg")!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.segmentChanged(segmentControl)
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        let shouldDownsample = sender.selectedSegmentIndex == 0
        loadingIndicator.startAnimating()
        remoteImageView.loadImage(from: imageURL, shouldDownSample: shouldDownsample,
                                  completionHandler: { [weak self] result in
                                    self?.loadingIndicator.stopAnimating()
                                    switch result {
                                    case let .success(image):
                                        guard let image = image else { return }
                                        self?.labelMemorySize.text = "\(image.memorySizeInKB) KB"
                                    case .failure:
                                        self?.labelMemorySize.text = "Error!!"
                                    }
        })
    }
}

extension UIImage {
    var memorySizeInKB: Int {
        guard let cgImage = self.cgImage else { return 0 }
        return (cgImage.height * cgImage.bytesPerRow) / 1024
    }
}
