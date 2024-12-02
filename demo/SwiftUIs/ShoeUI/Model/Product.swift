//
//  Product.swift
//  Product
//
//  Created by Jovins on 2021/8/31.
//

import SwiftUI

struct Product: Identifiable {
    
    var id: String = UUID().uuidString
    var productImage: String
    var productTitle: String
    var productPrice: String
    var productBG: Color
    var isLiked: Bool = false
    var ProductRating: Int
}

var products: [Product] = [
    Product(productImage: "p1", productTitle: "Nike Kobe Bruce ", productPrice: "$240.0", productBG: Color("ShoeBG1"), ProductRating: 4),
    Product(productImage: "p2", productTitle: "Nike Dunk Low", productPrice: "$266.0", productBG: Color("ShoeBG2"), isLiked: true, ProductRating: 3),
    Product(productImage: "p3", productTitle: "Nike Zoom Green", productPrice: "$388.0", productBG: Color("ShoeBG3"), ProductRating: 5),
    Product(productImage: "p4", productTitle: "Nike Zoom Kobe", productPrice: "$220.0", productBG: Color("ShoeBG4"), ProductRating: 4)
]
