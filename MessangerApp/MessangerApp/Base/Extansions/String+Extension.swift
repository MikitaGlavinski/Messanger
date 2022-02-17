//
//  String+Extension.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/31/22.
//

import UIKit

extension String {
    func estimatedSize(width: CGFloat, height: CGFloat, font: UIFont) -> CGRect {
        let size = CGSize(width: width, height: height)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: self).boundingRect(with: size, options: options, attributes: [.font: font], context: nil)
        return estimatedFrame
    }
    
    var isSingleEmoji: Bool { count == 1 && containsEmoji }
    
    var containsEmoji: Bool { contains { $0.isEmoji } }
    
    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }
    
    var emojiString: String { emojis.map { String($0) }.reduce("", +) }
    
    var emojis: [Character] { filter { $0.isEmoji } }
    
    var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
    
    enum MimeType {
        static var image: String { "image/jpeg" }
        static var video: String { "video/quicktime" }
    }
    
    enum Titles {
        static var chats: String { "Chats" }
        static var updating: String { "updating..." }
        static var photo: String { "Photo" }
        static var video: String { "Video" }
        static var cancel: String { "Cancel" }
        static var photoLibrary: String { "Photo library" }
        static var camera: String { "Camera" }
        static var pickMedia: String { "Pick Media" }
        static var error: String { "Error" }
        static var ok: String { "Ok" }
        static var delete: String { "Delete" }
        static var options: String { "Options" }
    }
}

extension Character {
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }
    
    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }
    
    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}
