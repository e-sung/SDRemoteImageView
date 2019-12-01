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
    let imageURL = URL(string: "https://media.idownloadblog.com/wp-content/uploads/2019/09/iPhone-11-Pro-stock-wallpaper-via-AR72014-blue.png")!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.segmentChanged(segmentControl)
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        let shouldDownsample = sender.selectedSegmentIndex == 0
        remoteImageView.loadImage(from: imageURL, shouldDownSample: shouldDownsample,
                                  completionHandler: { [weak self] result in
                                    switch result {
                                    case let .success(image):
                                        guard let image = image else { return }
                                        self?.labelMemorySize.text = "\(image.memorySize) bytes"
                                    case .failure:
                                        self?.labelMemorySize.text = "Error!!"
                                    }
        })
    }
}

extension UIImage {
    var memorySize: Int {
        guard let cgImage = self.cgImage else { return 0 }
        return cgImage.height * cgImage.bytesPerRow
    }
}
