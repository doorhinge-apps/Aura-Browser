//
//  File.swift
//  
//
//  Created by Eon Fluxor on 2/2/23.
//

import Foundation

extension URL {
    static func optional(from string: String?) -> URL? {
        guard
            let string = string,
            let url = URL(string: string),
            url.host != nil,
            url.scheme != nil
        else { return nil }

        return url
    }
}
