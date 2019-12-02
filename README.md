# SDRemoteImageView


## Introduction

Images are biggest factor for memory footprint. To make minimal footprint while dealing with images, you should use technique called `downsampling` when possible.

This subclass of UIImageView fetches image data from remote server, and apply `downsampling` on that data, and then display it, resulting in minimal memory footprint.

If you run the sample project, you can find that downsampled version of image takes much less memory when decoded into image buffer.

## Demo

![SDRemoteImageView Demo](demo.gif)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

This project has zero depdencies other than Foundation and UIKit

## Installation

SDRemoteImageView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SDRemoteImageView'
```

## Author

e-sung, dev.esung@gmail.com

## License

SDRemoteImageView is available under the MIT license. See the LICENSE file for more info.
