//
//  NumberFunc.swift
//  KoreanToBrailleClean
//
//  Created by 양유진 on 2021/12/11.
//

import Foundation

let number_braille = "⠼"
let number_braille_dict = ["0":"⠚", "1":"⠁", "2":"⠃", "3":"⠉", "4":"⠙","5":"⠑", "6":"⠋", "7":"⠛", "8":"⠓", "9":"⠊"]

let hangul = ["ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ","ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"]
let number_punctuation_invalid_dict = ["~":"⠤⠤"] // 수표 효력 무효
let number_punctuation_valid_dict = [":":"⠐⠂", "-":"⠤", ".":"⠲", ",":"⠐", "·":"⠐⠆"] // 수표 효력 유효

let number_punctuation_valid = [":", "-", ".", ",", "·"]
var isdigit_flag = false

// 초성 체크
func chosungCheck(word: String) -> String {
    let octal = word.unicodeScalars[word.unicodeScalars.startIndex].value
    let index = (octal - 0xac00) / 28 / 21
    
    return hangul[Int(index)]
    
}

func translateNumber(text: String) -> String{
    var result = ""
    for i in 0...text.count-1{
        if text[i].isNumber{
            
            if !isdigit_flag{
                isdigit_flag = true
                result += number_braille
                result += number_braille_dict["\(String(text[i]))"]!
            }else{
                result += number_braille_dict["\(String(text[i]))"]!
            }

            if i < text.count-1{ //제38항: 숫자와 혼용되는 '운'의 약자가 숫자 다음에 이어 나올 때에는 숫자와 한글을 띄어 쓴다.
                if text[i+1] == "운"{
                    result += "⠀"
                    print(text[i+1].description.contains("ㄴ"))
                }
            }
            
        }
        else if number_punctuation_valid.contains(String(text[i])) && isdigit_flag{
            result += number_punctuation_valid_dict["\(text[i])"]!
        }
        else{
            //제38항: 숫자와 혼용되는 'ㄴ,ㄷ,ㅁ,ㅋ,ㅌ,ㅍ,ㅎ'의 첫소리 글자와 숫자 다음에 이어 나올 때에는 숫자와 한글을 띄어 쓴다.
            if CharacterSet(charactersIn: ("가".unicodeScalars.first!)...("힣".unicodeScalars.first!)).contains("\(text[i])".unicodeScalars.first!){
                let cho = chosungCheck(word: String(text[i]))
                if (cho == "ㄴ" || cho == "ㄷ" || cho == "ㅁ" || cho == "ㅋ" || cho == "ㅌ" || cho == "ㅍ" || cho == "ㅎ") && isdigit_flag{
                    result += "⠀"
                }
            }

            result += String(text[i])
            isdigit_flag = false

        }
    }
    
    return result
}
