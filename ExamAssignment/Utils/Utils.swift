//
//  Utils.swift
//  ExamAssignment
//
//  Created by JonnyChinhTran on 03/03/2025.
//

import Foundation

struct Utils {
    static func getFibonacciArray(count: Int) -> [Int] {
        guard count > 0 else { return [Int]()}

            var fib = [Int]()
            if count >= 1 {
                fib.append(1)
            }
            if count >= 2 {
                fib.append(2)
            }

            for i in 2..<count {
                let nextFib = fib[i - 1] + fib[i - 2]
                fib.append(nextFib)
            }

        return fib
    }
}
 
