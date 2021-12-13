//
//  PunctuationFunc.swift
//  KoreanToBrailleClean
//
//  Created by 양유진 on 2021/12/12.
//

import Foundation


let punctuation_dict = [".": "⠲", "?": "⠦", "!": "⠖", ",": "⠐", "·": "⠐⠆", ":": "⠐⠂", ";":"⠰⠆", "(": "⠦⠄", ")":"⠠⠴", "{": "⠦⠂", "}": "⠐⠴", "[": "⠦⠆", "]": "⠰⠴", "-": "⠤", "~": "⠤⠤" ]

let punctuation_list = [".", "?", "!", ",", "·", ":", ";", "(", ")", "{", "}", "[", "]", "-", "~"]
let quotes_kor_list = ["\"", "'"]
let quotes_list = ["⠦", "⠴", "⠠⠦", "⠴⠄"] // 여는 큰따옴표, 닫는 큰따옴표, 여는 작은따옴표, 닫는 작은따옴표

var open_flag = false // 따옴표 열고 닫는 flag

func translatePunc(text: String) -> String{
    
    var result = ""
    
    for i in 0...text.count-1{
        if quotes_kor_list.contains(String(text[i])){
            if !open_flag{
                if text[i] == "'"{
                    result += quotes_list[2] // 여는 작은따옴표
                }else if text[i] == "\""{
                    result += quotes_list[0] // 여는 큰따옴표
                }
                open_flag = true
                
            }else{
                if text[i] == "'"{
                    result += quotes_list[3] // 닫는 작은따옴표
                }else if text[i] == "\""{
                    result += quotes_list[1] // 닫는 큰따옴표
                }
                
                open_flag = false
                
            }
        }else if punctuation_list.contains(String(text[i])){
            result += punctuation_dict["\(text[i])"]!
        }else{
            result += String(text[i])
        }
    }
    
    return result
}



