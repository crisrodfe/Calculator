//
//  ViewController.swift
//  Calculator
//
//  Created by Cristina Rodriguez Fernandez on 30/5/16.
//  Copyright © 2016 CrisRodFe. All rights reserved.
//

//Aquí tendremos que conectar todos los elementos de la UI para asignarles funcionalidad. Al pulsar un botón,se hará una llamada a algún método de este controller.

import UIKit
var calculatorCount = 0
class ViewController: UIViewController
{

    @IBOutlet fileprivate weak var history: UILabel!
    
    @IBOutlet fileprivate weak var display: UILabel!
    
    fileprivate var userIsInTheMiddleOfTyping = false {
        didSet {
            if !userIsInTheMiddleOfTyping {
                userIsInTheMiddleOfFloatingPointNummer = false
            }
        }
    }
    /////////
    //Prueba para comprobar que cada vez que pulsamos el boton Calculate! se crea un nuevo MVC y al volver se elimina de la memoria
    override func viewDidLoad() {
        super.viewDidLoad()
        calculatorCount += 1
        print("Loaded up a new Calculator(count = \(calculatorCount))")
        brain.addUnaryOperation("Z"){ [ weak weakSelf = self] in
            //self.display.textColor = UIColor.redColor() Con este self nunca podrá el MVC ser liberado de la memoria no se eliminará tenemos que poner en los [] la caputra del self en otra variable que será la que usaremos dentro del closure
            weakSelf?.display.textColor = UIColor.red
            return sqrt($0)
        }
    }
    //Este metodo es llamado justo antes de ser eliminado de la memoria
    deinit {
        calculatorCount -= 1
        print("Calculator left the heap(count = \(calculatorCount))")
    }
    //////////
    
    
    fileprivate var userIsInTheMiddleOfFloatingPointNummer = false

    @IBAction fileprivate func touchDigit(_ sender: UIButton)
    {
        var digit = sender.currentTitle!
        
        if digit == "." {
            if userIsInTheMiddleOfFloatingPointNummer {
                return
            }
            if !userIsInTheMiddleOfTyping {
                digit = "0."
            }
            userIsInTheMiddleOfFloatingPointNummer = true
        }
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    //Computed property.
    fileprivate var displayValue : Double
    {
        get{
            return Double(display.text!)!
        }
        
        set{
            display.text = String(newValue)
            //history.text = brain.description + (brain.isPartialResult ? " …" : " =")
        }
        
    }
    
    fileprivate var brain = CalculatorBrain()
    
    @IBAction fileprivate func performOperation(_ sender: UIButton)
    {
        if userIsInTheMiddleOfTyping
        {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }

        if let mathematicalSymbol = sender.currentTitle
        {
            brain.performOperation(mathematicalSymbol)
        }
        
        displayValue = brain.result
    }
    
    var savedProgram : CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    @IBAction func clearAll(_ sender: UIButton) {
        display.text = String(0)
        history.text = ""
        brain = CalculatorBrain()
    }
}

 
