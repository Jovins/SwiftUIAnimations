//
//  FuncUtils.swift
//  SwiftUI-2048
//
//  Created by Jovins on 2021/7/27.
//

func bind<T, U>(_ x: T, _ closure: (T) -> U) -> U {
    return closure(x)
}
