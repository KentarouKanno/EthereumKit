//
//  EIP155Signer.swift
//  EthereumKit
//
//  Created by yuzushioh on 2018/03/02.
//  Copyright © 2018 yuzushioh. All rights reserved.
//

import SMP
import CryptoSwift

public struct EIP155Signer {
    
    private let chainID: Int
    
    public init(chainID: Int) {
        self.chainID = chainID
    }
    
    public func hash(signTransaction: SignTransaction) -> Data {
        guard let data = encode(signTransaction: signTransaction) else {
            fatalError("Failded to RLP hash \(signTransaction)")
        }
        return Data(bytes: SHA3(variant: .keccak256).calculate(for: data.bytes))
    }
    
    public func encode(signTransaction: SignTransaction) -> Data? {
        return RLP.encode([
            signTransaction.nonce,
            signTransaction.gasPrice,
            signTransaction.gasLimit,
            signTransaction.to.data,
            signTransaction.value,
            signTransaction.data,
            chainID, 0, 0 // EIP155
        ])
    }
    
    public func calculateRSV(signiture: Data) -> (r: Data, s: Data, v: Data) {
        return (
            r: signiture[..<32],
            s: signiture[32..<64],
            v: Data([signiture[64] + UInt8(35) + UInt8(chainID) + UInt8(chainID)])
        )
    }
}