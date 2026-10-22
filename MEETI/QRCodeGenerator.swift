//
//  QRCodeGenerator.swift
//  MEETI
//
//  Created by cmStudent on 2026/10/04.
//

import Foundation

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct QRCodeGenerator {
    // Core Imageの描画用コンテキストは生成コストがあるため、呼び出しごとに作り直しません。
    private static let context = CIContext()

    
    static func generate(from string: String) -> UIImage? {
        let data = Data(string.utf8)
        
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        filter.correctionLevel = "M"
        
        
        guard let outputImage = filter.outputImage else { return nil }
        
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
        
    }
}
