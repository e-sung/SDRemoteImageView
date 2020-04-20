//
//  RemoteImageDownloadable.swift
//  Pods-SDRemoteImageView_Example
//
//  Created by 류성두 on 2020/04/12.
//

import Foundation

public struct SDRemoteImageWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol RemoteImageDownloadable: AnyObject { }

public extension RemoteImageDownloadable {
    var sd: SDRemoteImageWrapper<Self> {
        get { return SDRemoteImageWrapper(self) }
        set { }
    }
}
