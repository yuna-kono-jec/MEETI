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
    
    static func generate(from string: String) -> UIImage? {
        let data = Data(string.utf8)
        
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        filter.correctionLevel = "M"
        
        let context = CIContext()
        
        guard let outputImage = filter.outputImage else { return nil }
        
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
        
    }
}
