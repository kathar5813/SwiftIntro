//
//  ResolutionPool.swift
//  Swinject
//
//  Created by Yoichi Tagaya on 7/28/15.
//  Copyright (c) 2015 Swinject Contributors. All rights reserved.
//

import Foundation

internal struct ResolutionPool {
    fileprivate static let maxDepth = 200
    
    fileprivate var pool = [ServiceKey: Any]()
    fileprivate var depth: Int = 0
    fileprivate var pendingCompletions: [()->()] = []
    
    internal subscript(key: ServiceKey) -> Any? {
        get { return pool[key] }
        set { pool[key] = newValue }
    }
    
    internal mutating func incrementDepth() {
        guard depth < ResolutionPool.maxDepth else {
            fatalError("Infinite recursive call for circular dependency has been detected. " +
                       "To avoid the infinite call, 'initCompleted' handler should be used to inject circular dependency.")
        }
        depth += 1
    }
    
    internal mutating func decrementDepth() {
        assert(depth > 0, "The depth cannot be negative.")
        
        if depth == 1 {
            while let pendingCompletion = pendingCompletions.popLast() {
                pendingCompletion() // Must be invoked decrementing depth counter.
            }
            pool = [:]
        }
        depth -= 1
    }
    
    internal mutating func appendPendingCompletion(_ completion: @escaping ()->()) {
        pendingCompletions.append(completion)
    }
}
