//
//  ViewController.swift
//  JJC
//
//  Created by Justin Weiss on 2/28/18.
//  Copyright © 2018 HPU. All rights reserved.
//
// This calculate includes Exponents, x square, and the shake to clear

import UIKit

//Error handler
var error = false

//Stack to hold numbers and operators
struct Stack<T> {
    var items = [T]()
    mutating func push(newItem: T) {
        items.append(newItem)
    }
    
    //Pops the top item off the stack
    mutating func pop() -> T? {
        guard !items.isEmpty else {
            return nil
        }
        return items.removeLast()
    }
    
    //Gets the top item off the stack
    func top() -> T? {
        guard !items.isEmpty else {
            return nil
        }
        return items.last
    }
    
    //Returns true or false if stack is empty
    func isEmpty() -> Bool? {
        guard !items.isEmpty else {
            return true
        }
        return false
    }
}

//Add function function takes in 2 doubles and returns the calculation as a double
func add(_ a: Double, _ b: Double) -> Double
{
    return a + b
}

//Subtract function takes in 2 doubles and returns the calculation as a double
func sub(_ a: Double, _ b: Double) -> Double
{
    return a - b
}

//Multiply function takes in 2 doubles and returns the calculation as a double
func mult(_ a: Double, _ b: Double) -> Double
{
    return a * b
}

//Divide function takes in 2 doubles and returns the calculation as a double
func div(_ a: Double, _ b: Double) -> Double
{
    if b != 0 {
        return a / b
    } else {
        error = true
        return 0
    }
    
}

//Exponent function takes in 2 doubles and returns the calculation as a double
func expo(_ a: Double, _ b: Double) -> Double {
    return pow(a, b)
}

//the following 2 lines checks to see which operator is need and runs the function to
// do the math calculation and returns the answer as a double
typealias binop = (Double, Double) -> Double
let ops: [String: binop] = ["+": add, "\u{2012}": sub, "*": mult, "/": div, "^": expo]

class CalculatorViewController: UIViewController {
    
    //MARK: - Calcutor buttons
    //Calculator text field
    @IBOutlet var calcTextField: UITextField!
    
    //One IBAction the works for all the number buttons
    @IBAction func buttons(_ sender: UIButton){
        
        //Sets button to the current button being pressed
        let button = sender
        
        //Changes the text field to at what ever the button does (EX button 1 adds 1 to the screen)
        let newTextFieldValue = calcTextField.text! + (button.titleLabel?.text)!
        calcTextField.text = newTextFieldValue
    }
    
    //this function gets called when the enter button is clicked
    @IBAction func enterButton(_ sender: UIButton) {
        
        
        //Checks if there is any characters that are not allowed
        if allowedChar(calcTextField.text!) {
            //Check to see if the text field is empty
            if calcTextField.text != "" {
                
                //Gets the expression from the text field
                let textFieldExpression  = convertStringToArray(calcTextField.text!)
                
                //converts it to infix and calculates the answer
                let value = inFix(textFieldExpression)
                
                //Checks to see if an error occured
                if error != true {
                    //if no errer then sets the field to the answer value
                    calcTextField.text = String(value)
                } else {
                    //if there was an error ouputs error in the field
                    calcTextField.text = "Error"
                    error = false
                }
            }
        } else {
            //If there was invalid characters
            calcTextField.text = "Error"
        }
    }
    
    //Called when used clicks Delete button
    @IBAction func deleteButton(_ sender: UIButton) {
        
        //takes off the last character of the string and resets it as the text field
        let newTextFieldValue = String(describing: calcTextField.text!.dropLast())
        calcTextField.text = newTextFieldValue
    }
    
    //Called when Clear button  clicked
    @IBAction func clearButton(_ sender: UIButton) {
        
        //Clears the screen
        calcTextField.text = ""
    }
    
    //Called when x square is clicked
    @IBAction func xSquared(_ sender: UIButton) {
        
        //Adds x^2 to the screen
        let newTextFieldValue = calcTextField.text! + "^2"
        calcTextField.text = newTextFieldValue
    }
    
    //Called when the minus button clicked
    @IBAction func minus(_ sender: UIButton) {
        
        //Changed the minus character to a different Unicode character so we could us the real
        // "-" minus for the negative number
        let newTextFieldValue = calcTextField.text! + "\u{2012}"
        calcTextField.text = newTextFieldValue
    }
    
    //MARK: - Converstion Function
    //This function inputs a string and walks throught it adding spaces in between all the numbers
    // and operators and returns an array of strings
    func convertStringToArray (_ inputString: String) -> [String] {
        
        var enteredNumbers = inputString
        //Adds the spaces
        enteredNumbers = enteredNumbers.replacingOccurrences(of: "(", with: " ( ", options: .literal, range: nil)
        enteredNumbers = enteredNumbers.replacingOccurrences(of: "+", with: " + ", options: .literal, range: nil)
        enteredNumbers = enteredNumbers.replacingOccurrences(of: ")", with: " ) ", options: .literal, range: nil)
        enteredNumbers = enteredNumbers.replacingOccurrences(of: "*", with: " * ", options: .literal, range: nil)
        enteredNumbers = enteredNumbers.replacingOccurrences(of: "\u{2012}", with: " \u{2012} ", options: .literal, range: nil)
        enteredNumbers = enteredNumbers.replacingOccurrences(of: "/", with: " / ", options: .literal, range: nil)
        enteredNumbers = enteredNumbers.replacingOccurrences(of: "^", with: " ^ ", options: .literal, range: nil)
        
        //separates the string into an array removing the spaces and returns array of strings
        return enteredNumbers.components(separatedBy: " ")
    }
    
    
    //MARK: - View life cycle
    //Function that gets called when the device is shaken
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        
        //If motion detected then clears the screen
        if motion == .motionShake {
            calcTextField.text = ""
        }
    }
    
    //MARK: - Math Functions
    //This function takes in 2 doubles and an operator and apply that operator the numbers
    func doMath(_ a: Double, _ b: Double, _ op: Character) -> Double {
        
        //Does the math and returns the answer
        let opFunc = ops["\(op)"]
        
        return opFunc!(a, b)
    }
    
    //This function checks to see which operator has greater precedence
    // the operator on the top of the stack or the current and returns true if
    // the stack operator has greater precedence or false if the current has greater precdence
    func precedence (_ op1: String, _ op2: String) -> Bool {
        
        //Compares and returns true or false
        if (compare(op1) >= compare(op2)) {
            return true
        } else {
            return false
        }
    }
    
    //This function sets a number to type of operator inputed and returns that number for the
    // precedence function to compare
    func compare (_ op: String) -> Int {
        //Returns - or + to 1
        if (op == "-" || op == "+") {
            return 1
            
        //Returns * /  to 2
        } else if (op == "*" || op == "/") {
            return 2
            
        //Returns ^ to 3
        } else if (op == "^") {
            return 3
            
        //Returns ( to 4
        } else if (op == "(") {
            return 4
            
        } else {
            return 0
        }
    }
    
    //This function takes in a string and checks to see if any characters in the string are not allowed
    // and return true if all the character are allowed and false if there are not allowed characters
    func allowedChar (_ inPullString: String) -> Bool {
        
        //Inverts the list of allowed characters to check for all others
        let allowedCharacters = NSCharacterSet(charactersIn:"0123456789.^()+-*/\u{2012}").inverted
        let stringCharacters = inPullString.components(separatedBy: allowedCharacters)
        let filtered = stringCharacters.joined(separator: "")
        
        //If the old string and the filtered string are the same then return true indicating all the characters
        // are allowed
        if filtered == inPullString {
            return true
        } else {
            return false
        }
    }
    
    //This function takes in an array of string to convert them to postfix and calculate the math
    // it returns a double that is the answer to the inputed exquation
    func inFix(_ tokens:[String]) -> Double {
        
        //Creates 2 stacks for the numbers and operators
        var number = Stack<Double>()
        var op = Stack<String>()
        
        //Loops through the array
        for token in tokens {
            
            //If the token is nil then it does nothing
            if token == "" {
                
            //If the token is a double then it pushes it onto the stack
            } else if let num = Double(token) {
                //Push num to stack
                number.push(newItem: num)
            
            //If the token is ) then it calculates the experation inside
            } else if token == ")" {
                
                //While there are items in the stack and its not the end parentheses
                while let opTop = op.top(), opTop != "(" {
                    
                    //If there was an error with one of the values then it fails the if and returns 0
                    // if no error then it pops 2 number off the stack and 1 operator and computes the total
                    // then pushes the total back onto the stack
                    if let val2 = number.pop(), let val1 = number.pop(), let oper2 = op.pop() {
                        number.push(newItem: doMath(val1, val2, Character(oper2)))
                    } else {
                        //If error return 0
                        error = true
                        return 0
                    }
                }
                
                //Pops the last parentheses of the stack
                op.pop()
            } else {
                
                //Runs through the stack and checks precedence with operator stack and current token and
                // calculates answers
                while let opTop = op.top(), precedence(opTop, token), opTop != "(" {
                    
                    //If there was an error with one of the values then it fails the if and returns 0
                    // if no error then it pops 2 number off the stack and 1 operator and computes the total
                    // then pushes the total back onto the stack
                    if let val2 = number.pop(), let val1 = number.pop(), let oper2 = op.pop() {
                        number.push(newItem: doMath(val1, val2, Character(oper2)))
                    } else {
                        //if error returns 0
                        error = true
                        return 0
                    }
                }
                
                //Pushs the curret token onto the stack if the other if statements don't already
                op.push(newItem: token)
            }
        }
        
        //While there is still operators in the operator stack 
        while let opTop = op.top(), opTop != "(" {
            
            //If there was an error with one of the values then it fails the if and returns 0
            // if no error then it pops 2 number off the stack and 1 operator and computes the total
            // then pushes the total back onto the stack
            if let val2 = number.pop(), let val1 = number.pop() ,let oper2 = op.pop() {
                number.push(newItem: doMath(val1, val2, Character(oper2)))
            } else {
                //If error
                error = true
                return 0
            }
        }
        //pops the answer off the stack and returns the value
        return number.pop()!
    }
}

