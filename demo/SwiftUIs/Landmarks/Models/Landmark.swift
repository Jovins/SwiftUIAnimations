//
//  Landmark.swift
//  Landmarks
//
//  Created by Jovins on 2021/7/22.
//

import SwiftUI
import CoreLocation

struct Landmark: Hashable, Codable, Identifiable {
    
    var id: Int
    var name: String
    var imageName: String
    var coordinates: Coordinates
    var state: String
    var park: String
    var category: Category
    var isFavorite: Bool
    
    var locationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
    
    func image(forSize size: Int) -> Image {
        ImageStore.shared.image(name: imageName, size: size)
    }
}

enum Category: String, CaseIterable, Codable, Hashable {
    case featured = "Featured"
    case lakes = "Lakes"
    case rivers = "Rivers"
    case mountains = "Mountains"
}

struct Coordinates: Hashable, Codable {
    var latitude: Double
    var longitude: Double
}
