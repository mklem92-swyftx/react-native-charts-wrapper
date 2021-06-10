//
//  BalloonMarker.swift
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 19/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//  https://github.com/danielgindi/Charts/blob/1788e53f22eb3de79eb4f08574d8ea4b54b5e417/ChartsDemo/Classes/Components/BalloonMarker.swift
//  Edit: Added textColor

import Foundation;

import Charts;

import SwiftyJSON;

open class HighlightMarker: MarkerView {
    open var color: UIColor?
    open var arrowSize = CGSize(width: 15, height: 11)
    open var font: UIFont?
    open var primaryColor: UIColor?
    open var secondaryColor: UIColor?
    open var minimumSize = CGSize()


    fileprivate var insets = UIEdgeInsets(top: 5.0,left: 10.0, bottom: 5.0,right: 10.0)

    fileprivate var primaryTextNs: NSString?
    fileprivate var secondaryTextNs: NSString?

    fileprivate var _labelSize: CGSize = CGSize()
    fileprivate var _size: CGSize = CGSize()
    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
    fileprivate var _primaryDrawAttributes = [NSAttributedString.Key: Any]()
    fileprivate var _secondaryDrawAttributes = [NSAttributedString.Key: Any]()


  public init(color: UIColor, font: UIFont, primaryColor: UIColor, secondaryColor: UIColor, textAlign: NSTextAlignment) {
        super.init(frame: CGRect.zero);
        self.color = color
        self.font = font
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = textAlign
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }



    open override func draw(context: CGContext, point: CGPoint) {
        if (primaryTextNs == nil || primaryTextNs?.length == 0) {
            return
        }

        context.saveGState()

        let chart = super.chartView
        let width = _size.width
        var xOffset = -width / 2

        let reactNativeMarginSize = 30
        let marginSize = CGFloat.init(reactNativeMarginSize / 2)
        if ((point.x + xOffset).isLess(than: marginSize)) {
            xOffset = -(point.x - marginSize)
        } else if (chart != nil && (chart!.bounds.width - marginSize).isLess(than: point.x + width + xOffset)) {
            xOffset = -(width - (chart!.bounds.width - marginSize - point.x))
        }

        let newPoint = CGPoint(x: point.x + xOffset, y: point.y)
        var rect = CGRect(origin: newPoint, size: _size)

        rect.origin.y -= rect.origin.y


        let path1 = UIBezierPath(roundedRect: rect, cornerRadius: 5)
        context.addPath(path1.cgPath)
        context.setFillColor((color?.cgColor)!)
        context.fillPath()

        UIGraphicsPushContext(context)

        let secondarySize = secondaryTextNs?.size(withAttributes: _primaryDrawAttributes)
        if (secondarySize != nil) {
            secondaryTextNs?.draw(at: CGPoint(x: newPoint.x + insets.left, y: rect.origin.y + insets.bottom), withAttributes: _secondaryDrawAttributes)
        }

        primaryTextNs?.draw(at: CGPoint(x: newPoint.x + insets.left + (secondaryTextNs!.isEqual(to: "") ? 0 : secondarySize!.width + 5), y: rect.origin.y + insets.bottom), withAttributes: _primaryDrawAttributes)

        UIGraphicsPopContext()

        context.restoreGState()
    }

    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {

        var primaryText : String;
        var secondaryText : String = "";

        if let candleEntry = entry as? CandleChartDataEntry {
            primaryText = candleEntry.close.description
        } else {
            primaryText = entry.y.description
        }

        if let object = entry.data as? JSON {
            if object["marker"].exists() {
                primaryText = object["marker"]["text"].stringValue
                if (object["marker"]["secondaryText"].exists()) {
                    secondaryText = object["marker"]["secondaryText"].stringValue
                }

                if highlight.stackIndex != -1 && object["marker"].array != nil {
                    primaryText = object["marker"].arrayValue[highlight.stackIndex].stringValue
                }
            }
        }

        primaryTextNs = primaryText as NSString
        secondaryTextNs = secondaryText as NSString

        _primaryDrawAttributes.removeAll()
        _primaryDrawAttributes[NSAttributedString.Key.font] = self.font
        _primaryDrawAttributes[NSAttributedString.Key.paragraphStyle] = _paragraphStyle
        _primaryDrawAttributes[NSAttributedString.Key.foregroundColor] = self.primaryColor
        _primaryDrawAttributes[NSAttributedString.Key.strokeWidth] = -3

        _secondaryDrawAttributes.removeAll()
        _secondaryDrawAttributes[NSAttributedString.Key.font] = self.font
        _secondaryDrawAttributes[NSAttributedString.Key.paragraphStyle] = _paragraphStyle
        _secondaryDrawAttributes[NSAttributedString.Key.foregroundColor] = self.secondaryColor

        let primarySize = primaryTextNs?.size(withAttributes: _primaryDrawAttributes)
        let secondarySize = secondaryTextNs?.size(withAttributes: _secondaryDrawAttributes)
        _labelSize = primarySize != nil ? CGSize(width: primarySize!.width + secondarySize!.width, height: primarySize!.height) : CGSize.zero
        _size.width = _labelSize.width + self.insets.left + self.insets.right + (secondaryText != "" ? 5 : 0) // 5 represents size from the margin between the labels
        _size.height = _labelSize.height + self.insets.top + self.insets.bottom
        _size.width = max(minimumSize.width, _size.width)
        _size.height = max(minimumSize.height, _size.height)
    }
}

