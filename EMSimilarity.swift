//
//  EMSimilarity.swift
//  SwiftSim
//
//  Created by Evan Moss on 8/1/16.
//  Copyright © 2016 Enterprising Technologies LLC. All rights reserved.
//

import Foundation

enum EMSimilarityMode {
    case Cosine
    case Tanimoto
    case Ochiai
    case JaccardIndex
    case JaccardDistance
    case Dice
    case Hamming
}

enum EMVectorSizeMismatchMode {
    case Bail
    case Truncate
}

class EMSimilarity {
    /** Similarity metric mode **/
    private var currentSimMode = [EMSimilarityMode.Cosine]
    
    /** Set the currentSimMode via push **/
    func pushCurrentSimMode(mode: EMSimilarityMode) {
        self.currentSimMode.append(mode)
    }
    
    /** Pop the currentSimMode via pop if it won't make the stack empty **/
    func popCurrentSimMode() {
        if self.currentSimMode.count > 1 {
            self.currentSimMode.popLast()
        }
    }
    
    /** Get the currently set similarity mode **/
    func getCurrentSimMode() -> EMSimilarityMode? {
        return self.currentSimMode.last
    }
    
    /** Mismatch Mode **/
    private var currentMismatchMode = [EMVectorSizeMismatchMode.Bail]
    
    /** Set the currentMismatcMode via push **/
    func pushCurrentMismatchMode(mode: EMVectorSizeMismatchMode) {
        self.currentMismatchMode.append(mode)
    }
    
    /** Pop the currentMismatchMode via pop if it won't make the stack empty **/
    func popCurrentMismatchMode() {
        if self.currentMismatchMode.count > 1 {
            self.currentMismatchMode.popLast()
        }
    }
    
    /** Get the currently set mistmatch mode **/
    func getCurrentMismatchMode() -> EMVectorSizeMismatchMode? {
        return self.currentMismatchMode.last
    }
    
    private func dot(A: [Double], B: [Double]) -> Double {
        var x: Double = 0
        for i in 0...A.count-1 {
            x += A[i] * B[i];
        }
        return x
    }
    
    private func magnitude(A: [Double]) -> Double {
        var x: Double = 0
        for elt in A {
            x += elt * elt
        }
        return sqrt(x)
    }
    
    /** Cosine similarity **/
    private func cosineSim(A: [Double], B: [Double]) -> Double {
        return dot(A, B: B) / (magnitude(A) * magnitude(B))
    }
    
    /** Tanimoto similarity **/
    private func tanimotoSim(A: [Double], B: [Double]) -> Double {
        let Amag = magnitude(A)
        let Bmag = magnitude(B)
        let AdotB = dot(A, B: B)
        return AdotB / (Amag * Amag + Bmag * Bmag - AdotB)
    }
    
    /** Ochiai similarity **/
    private func ochiaiSim(A: [Double], B: [Double]) -> Double {
        let a = Set(A)
        let b = Set(B)
        
        return Double(a.intersect(b).count) / sqrt(Double(a.count) * Double(b.count))
    }
    
    /** Jaccard index **/
    private func jaccardIndex(A: [Double], B: [Double]) -> Double {
        let a = Set(A)
        let b = Set(B)
        
        return Double(a.intersect(b).count) / Double(a.union(b).count)
    }
    
    /** Jaccard distance **/
    private func jaccardDist(A: [Double], B: [Double]) -> Double {
        return 1.0 - jaccardIndex(A, B: B)
    }
    
    /** Dice coeeficient **/
    private func diceCoef(A: [Double], B: [Double]) -> Double {
        let a = Set(A)
        let b = Set(B)
        
        return 2.0 * Double(a.intersect(b).count) / (Double(a.count) + Double(b.count))
    }
    
    /** Hamming distance **/
    private func hammingDist(A: [Double], B: [Double]) -> Double {
        var x = 0
        for i in 0...A.count-1 {
            if A[i] != B[i] {
                x += 1
            }
        }
        return Double(x)
    }
    
    /**
     * Main compute mode
     * Double types
     * Returns the similarity results or -1.0 on caught error
     */
    func compute(A: [Double], B: [Double]) -> Double {
        // look for vector size mismatch
        if A.count != B.count {
            if let mode = self.getCurrentMismatchMode() {
                switch mode {
                case .Bail:
                    return -1
                case .Truncate:
                    let a = A.count < B.count ? A : B
                    let _b = A.count < B.count ? B : A
                    var b = [Double]()
                    for i in 0...a.count-1 {
                        b.append(_b[i])
                    }
                    return compute(a, B: b)
                }
            }
            else {
                return -1
            }
        }
        
        if let mode = self.getCurrentSimMode() {
            switch mode {
            case .Cosine:
                return cosineSim(A, B: B)
            case .Tanimoto:
                return tanimotoSim(A, B: B)
            case .Ochiai:
                return ochiaiSim(A, B: B)
            case .JaccardIndex:
                return jaccardIndex(A, B: B)
            case .JaccardDistance:
                return jaccardDist(A, B: B)
            case .Dice:
                return diceCoef(A, B: B)
            case .Hamming:
                return hammingDist(A, B: B)
            }
        }
        else {
            return -1
        }
    }
}