//
//  RemoteImageDownloadable.swift
//  Pods-SDRemoteImageView_Example
//
//  Created by 류성두 on 2020/04/12.
//

import Foundation

/// Wrapper for Kingfisher compatible types. This type provides an extension point for
/// connivence methods in Kingfisher.
public struct SDRemoteImageWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

/// Represents an object type that is compatible with Kingfisher. You can use `kf` property to get a
/// value in the namespace of Kingfisher.
public protocol RemoteImageDownloadable: AnyObject { }

public extension RemoteImageDownloadable {
    /// Gets a namespace holder for Kingfisher compatible types.
    var sd: SDRemoteImageWrapper<Self> {
        get { return SDRemoteImageWrapper(self) }
        set { }
    }
}
