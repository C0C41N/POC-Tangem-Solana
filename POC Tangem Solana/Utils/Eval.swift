//
//  Eval.swift
//  POC Tangem Solana
//
//  Created by Ali M. on 06/10/2024.
//

public class Eval<T, U> {
    let success: Bool
    let value: T?
    let error: U?
    
    init(success: Bool, value: T? = nil, error: U? = nil) {
        self.success = success
        self.value = value
        self.error = error
    }
    
    static func success(_ value: T) -> Eval {
        return Eval(success: true, value: value)
    }
    
    static func failure(_ error: U) -> Eval {
        return Eval(success: false, error: error)
    }
}
