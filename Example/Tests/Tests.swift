import XCTest
import SDRemoteImageView

class Tests: XCTestCase {
    
    func test1DownSampling() {
        let networkFetchCondition = XCTestExpectation(description: "Network Fetch")
        // This is an example of a functional test case.
        let imageURL = URL(string: "https://raw.githubusercontent.com/e-sung/SDRemoteImageView/master/sampleImage.jpg")
        let givenFrame = CGRect(x: 0, y: 0, width: 200, height: 150)
        let resoution = UIScreen.main.scale
        let sut = SDRemoteImageView(frame: givenFrame)
        sut.loadImage(from: imageURL, completionHandler: { result in
            do {
                let image = try result.get()
                let bytesPerRow = image?.cgImage?.bytesPerRow ?? 0
                let imageHeight = image?.cgImage?.height ?? 0
                let imageSize = bytesPerRow * imageHeight
                
                
                XCTAssert(imageSize == Int(givenFrame.width * resoution * givenFrame.height * resoution * 4))
            }
            catch {
                XCTFail()
            }
            networkFetchCondition.fulfill()
        })
        wait(for: [networkFetchCondition], timeout: 10)
    }
    
    func test2NoDownSampling() {
        let networkFetchCondition = XCTestExpectation(description: "Network Fetch")
        // size of contents of image is 1920 * 1440
        let imageURL = URL(string: "https://raw.githubusercontent.com/e-sung/SDRemoteImageView/master/sampleImage.jpg")
        let givenFrame = CGRect(x: 0, y: 0, width: 200, height: 150)
        let sut = SDRemoteImageView(frame: givenFrame)
        sut.loadImage(from: imageURL, shouldDownSample: false, completionHandler: { result in
            do {
                let image = try result.get()
                let bytesPerRow = image?.cgImage?.bytesPerRow ?? 0
                let imageHeight = image?.cgImage?.height ?? 0
                let imageSize = bytesPerRow * imageHeight
                XCTAssert(imageSize == 1920 * 1440 * 4)
            }
            catch {
                XCTFail()
            }
            networkFetchCondition.fulfill()
        })
        wait(for: [networkFetchCondition], timeout: 10)
    }

}
