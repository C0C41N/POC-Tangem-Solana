//
//  Signer.swift
//  
//
//  Created by Andrey Chukavin on 10.01.2022.
//

import Foundation

public protocol Signer {
    var publicKey: PublicKey { get }
    func sign(message: Data, completion: @escaping (Result<Data, Error>) -> Void)
}
