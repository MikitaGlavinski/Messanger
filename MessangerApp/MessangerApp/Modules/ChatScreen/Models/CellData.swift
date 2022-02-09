//
//  CellData.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/9/22.
//

import UIKit

protocol CellData {
    var cellHeight: CGFloat { get set }
    var showDate: Bool { get set }
}

struct ImageCellData: CellData {
    var imageViewFrame: CGRect = .zero
    var dateLabelFrame: CGRect?
    var timeLabelFrame: CGRect = .zero
    var sendStateViewFrame: CGRect = .zero
    var timeLabelText: String = ""
    var dateLabelText: String?
    var isSendStateHidden: Bool = false
    var sendStateViewBorderColor: CGColor?
    var sendStateViewBackgroundColor: UIColor?
    var cellHeight: CGFloat = 0.0
    var showDate: Bool = false
}

struct TextCellData: CellData {
    var dateLabelFrame: CGRect?
    var textMessageBackViewFrame: CGRect = .zero
    var timeLabelFrame: CGRect = .zero
    var sendStateViewFrame: CGRect = .zero
    var textViewFrame: CGRect = .zero
    var timeLabelText: String = ""
    var dateLabelText: String?
    var isSendStateHidden: Bool = false
    var textContainsOnlyEmoji: Bool = false
    var sendStateViewBorderColor: CGColor?
    var sendStateViewBackgroundColor: UIColor?
    var messageBackgroundColor: UIColor?
    var textColor: UIColor?
    var cellHeight: CGFloat = 0.0
    var showDate: Bool = false
}
