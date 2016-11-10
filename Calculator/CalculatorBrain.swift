//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Cristina Rodriguez Fernandez on 30/5/16.
//  Copyright © 2016 CrisRodFe. All rights reserved.
//

//MODEL

//

import Foundation

class CalculatorBrain
{
    
    fileprivate var accumulator = 0.0
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    func setOperand(_ operand: Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)
    }
    
    fileprivate enum Operation { //Pasan por valor
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double,Double) -> Double)
        case equals
    }
    
    fileprivate var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(M_PI),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "cos" : Operation.unaryOperation(cos),
        "sen" : Operation.unaryOperation(sin),
        //Closure. An inline function. Caputra el estado de su entorno. $0 etc. accede a los argumentos. No hace falta especificar tipos porque en el enum BinaryOperation ya ponemos que recibe dos Double y devuelve otro.
        "×" : Operation.binaryOperation({$0 * $1 }),
        "÷" : Operation.binaryOperation({$0 / $1 }),
        "+" : Operation.binaryOperation({$0 + $1 }),
        "−" : Operation.binaryOperation({$0 - $1 }),
        "=": Operation.equals
    ]
    
    func performOperation(_ symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol]{
            switch operation {
            case .constant(let value): accumulator = value
            case .unaryOperation(let function): accumulator = function(accumulator)
            case .binaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .equals : executePendingBinaryOperation()
                
            }
        }
    }
    
    fileprivate func executePendingBinaryOperation(){
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    fileprivate var pending : PendingBinaryOperationInfo? //Lo hacemos opcional porq solo lo usaremos si tenemos un operador
    
    //Es como una clase. Sin herencia. La gran diferencia es que se pasan por valor, las clases por referencia.
    fileprivate struct PendingBinaryOperationInfo {
        var binaryFunction : (Double,Double) -> Double
        var firstOperand : Double
    }
    
    var result: Double {
        get{
            return accumulator
        }
    }
    
    fileprivate var internalProgram = [AnyObject]() //Storage
    
    typealias PropertyList = AnyObject //sirve fundamentalmente como documentacion
    
    func clear(){
        accumulator = 0.0
        internalProgram.removeAll()
        pending = nil
    }
    
    var program: PropertyList{
        get{
            return internalProgram as CalculatorBrain.PropertyList
        }
        set{
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps{
                    if let operand = op as? Double {
                        setOperand(operand)
                    }else{
                        if let operation = op as? String {
                            performOperation(operation)
                        }
                    }
                }
            }
        }
    }
    
    //Metodo para añadir una nueva operacion a nuestro diccionario con todas nuestas operaciones
    func addUnaryOperation(_ symbol: String, operation: @escaping (Double) -> Double){
        operations[symbol] = Operation.unaryOperation(operation)
    }

}
