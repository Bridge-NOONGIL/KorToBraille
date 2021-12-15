import Foundation

public class KorToBraille {
    
    public init() {}
    
//    static var cnt = 0 // 지금까지 나온 음절의 수
//    static var wordCnt = 0 // 지금까지 나온 단어의 수
    // UTF-8 기준
    static let INDEX_HANGUL_START:UInt32 = 44032  // "가"
    static let INDEX_HANGUL_END:UInt32 = 55199    // "힣"
    
    static let CYCLE_CHO :UInt32 = 588
    static let CYCLE_JUNG :UInt32 = 28
    
    static let CHO = [
        "ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ",
        "ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
    ]
    
    static let JUNG = [
        "ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ","ㅕ", "ㅖ", "ㅗ", "ㅘ",
        "ㅙ", "ㅚ","ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ",
        "ㅣ"
    ]
    
    static let JONG = [
        "","ㄱ","ㄲ","ㄳ","ㄴ","ㄵ","ㄶ","ㄷ","ㄹ","ㄺ",
        "ㄻ","ㄼ","ㄽ","ㄾ","ㄿ","ㅀ","ㅁ","ㅂ","ㅄ","ㅅ",
        "ㅆ","ㅇ","ㅈ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
    ]
    
    static let JONG_DOUBLE = [
        "ㄲ":"ㄱㄱ","ㄳ":"ㄱㅅ","ㄵ":"ㄴㅈ","ㄶ":"ㄴㅎ","ㄺ":"ㄹㄱ","ㄻ":"ㄹㅁ",
        "ㄼ":"ㄹㅂ","ㄽ":"ㄹㅅ","ㄾ":"ㄹㅌ","ㄿ":"ㄹㅍ","ㅀ":"ㄹㅎ",
        "ㅄ":"ㅂㅅ"
    ]

    /* [약어 번역]
     제18항: 다음이 단어들은 약어로 적어 나타낸다.
     [붙임] 위에 제시된 말들의 뒤에 다른 음절이 붙어 쓰일 때에도 약어를 사용하여 적는다. ex. 그래서인지, 그러면서
     [다만] 위에 제시된 말들의 앞에 다른 음절이 붙어 쓰일 때에는 약어를 사용하여 적지 않는다. ex. 쭈그리고, 찡그리고, 오그리고
    */
    private class func korabbToBraille(_ input: String) -> String {

        var result = input
        
        for (key, value) in kor_abb{
            if input.contains(key){
                if let index = input.range(of: key){
                    var s = 1
                    s = input.distance(from: input.startIndex, to: index.lowerBound)
                    if s == 0{ // [다만] -> 맨 앞에 오는 경우인지 확인
                        result = result.replace(target: key, withString: value)
                    }
                }
                
            }
        }
        
        return result
    }
    
    
    // [최종 번역] 주어진 문장을 단어로 decompose -> korWordToBraille로 각각 점자 단어로 변경 -> 점자 단어 compose (result)
    public class func korTranslate(_ input: String) -> String{
        
        var result = ""
        let components = input.components(separatedBy: " ") // 띄어쓰기 단위로 끊음
        
        for word in components{
            if word == "" {
                continue
            }
            
            var word_translatedNumber = translateNumber(text: word) // (1) 숫자 번역
            word_translatedNumber = translatePunc(text: word_translatedNumber) //(2) 문장부호 번역
            result += korWordToBraille(word_translatedNumber) // (3) 한글 번역

            result += "⠀"
            
            // 모든 flag 초기화
            flag_10 = false
            flag_11 = false
            flag_17 = false
            isdigit_flag = false
        }
        
        return result
    }
    
    
    // [단어 번역] 주어진 "단어"를 자모음으로 분해해서 번역된 점자로 리턴하는 함수
    private class func korWordToBraille(_ input: String) -> String {
        
        var wordToTranslate = "" // 번역할 단어
        
        var jamo = "" // 분해된 문장
        var braillejamo = "" // 분해된 점자 문장
        //var jamoCursor = 0 // 현재 문장 커서 -> 위치 파악을 위한 index 역할
        //var brailleCursor = 0  // 현재 점자 문장 커서 -> 위치 파악을 위한 index 역할

        wordToTranslate = korabbToBraille(input) // 약어 처리
        
        for scalar in wordToTranslate.unicodeScalars{
            jamo += getJamoFromOneSyllable(scalar) ?? "" // 자모음 분해
            braillejamo += getBrailleFromJamo(scalar) ?? "" // 점자 번역
        }
        
        return braillejamo
    }
    
    // [점자 번역] 자모음으로 분해한 음절을 "점자"로 번역하여 리턴하는 함수 (한 음절씩 번역 처리(초성+중성+종성))
    private class func getBrailleFromJamo(_ n: UnicodeScalar) -> String?{
        if CharacterSet(charactersIn: ("가".unicodeScalars.first!)...("힣".unicodeScalars.first!)).contains(n){
            let index = n.value - INDEX_HANGUL_START
            
            // [초성]
            var cho = CHO[Int(index / CYCLE_CHO)]

            // 제2항: ‘ᄋ’이 첫소리 자리에 쓰일 때에는 이를 표기하지 않는다.
            if cho == "ㅇ"{
                cho = ""
            }
            
            var braille_cho = kor_cho["\(cho)"]! // 초성 점자
   
            
            // [중성]
            let jung = JUNG[Int((index % CYCLE_CHO) / CYCLE_JUNG)]
            
            var braille_jung = kor_jung["\(jung)"]! // 중성 점자
            
            
            if cho == "" && jung == "ㅖ" && flag_10 { // 제10항: 모음자에 '예'가 이어 나올 때에는 그 사이에 붙임표(⠤)를 적어 나타낸다.
                braille_jung.insert("⠤", at: braille_jung.startIndex)
                flag_10 = false
            }else if cho == "" && jung == "ㅐ" && flag_11{ // 제11항: 'ㅑ,ㅘ,ㅜ,ㅝ'에 '애'가 이어 나올 때에는 그 사이에 붙임표(⠤)를 적어 나타낸다.
                braille_jung.insert("⠤", at: braille_jung.startIndex)
                flag_11 = false
            }else if cho == "" && flag_17{ // 제17항: 한 어절 안에서 'ㅏ'를 생략한 약자에 받침 글자가 없고 다음 음절이 모음으로 시작될 때에는 'ㅏ'를 생략하지 않는다.
                braille_cho.insert("⠣", at: braille_cho.startIndex)
                flag_17 = false
            }
            
            // 제12항: 다음 글자가 포함된 글자들은 아래 표에 제시한 약자 표기를 이용하여 적는 것을 표준으로 삼는다.
            if jung == "ㅏ" {
                if cho == "ㄱ" {
                    braille_cho = ""
                    braille_jung = "⠫"
                }else if cho == "ㅅ" {
                    braille_cho = ""
                    braille_jung = "⠇"
                }else if cho == "ㄴ" || cho == "ㄷ" || cho == "ㅁ" || cho == "ㅂ" || cho == "ㅈ" || cho == "ㅋ" || cho == "ㅌ" || cho == "ㅍ" || cho == "ㅎ"{
                    braille_cho = "" // '나,다,마,바,자,카,타,파,하'는 모음 'ㅏ'를 생략하고 첫소리 글자로 약자 표기한다.
                    braille_jung = kor_cho["\(cho)"]!
                    flag_17 = true
                }else if cho == "ㄸ"{
                    braille_cho = ""
                    braille_jung = "⠠⠊"
                    flag_17 = true
                }else if cho == "ㅃ"{
                    braille_cho = ""
                    braille_jung = "⠠⠘"
                    flag_17 = true
                }else if cho == "ㅉ"{
                    braille_cho = ""
                    braille_jung = "⠠⠨"
                    flag_17 = true
                }else if cho == "ㄲ"{  // 제14항 '까,싸,껏'은 각각 '가,사,것'의 약자 표기에 된소리 표를 덧붙여 적는다.
                    braille_cho = ""
                    braille_jung = "⠠⠫"
                }else if cho == "ㅆ"{
                    braille_cho = ""
                    braille_jung = "⠠⠇"
                }
            }
            
            
            // [종성] * 종성은 없는 경우도 있음
            var jong = JONG[Int(index % CYCLE_JUNG)]
            guard var braille_jong = kor_jong["\(jong)"] else {
                flag_10 = true // 종성 없음(모음자)
                if jung == "ㅑ" || jung == "ㅘ" || jung == "ㅜ" || jung == "ㅝ"{
                    flag_11 = true
                }
                
                return braille_cho + braille_jung
            } // 종성 점자
            
            
            // 겹받침 처리를 위해 first와 second로 나누었음
            var firstjong: Character = " "
            var secondjong: Character = " "
            
            
            // 종성이 double(ex. ㄲ, ㄹㄱ ..)일 때
            if let disassembledJong = JONG_DOUBLE[jong] {
                jong = disassembledJong
                firstjong = jong[jong.startIndex]
                secondjong = jong[jong.index(jong.endIndex, offsetBy:-1)]
            }

            // 제12항: 다음 글자가 포함된 글자들은 아래 표에 제시한 약자 표기를 이용하여 적는 것을 표준으로 삼는다.
            // 제15항: 다음과 같이 글자 속에 모음으로 시작하는 약자가 포함되어 있을 때에는 해당 약자를 이용하여 적는다.
            if jung == "ㅓ"{
                // 글자 속에 "ㅓㄱ"이 포함된 경우
                if jong == "ㄱ"{
                    braille_jung = ""
                    braille_jong = "⠹"
                }else if firstjong == "ㄱ"{
                    braille_jung = ""
                    braille_jong = "⠹" + kor_jong["\(secondjong)"]!
                }else if jong == "ㄴ"{ // 글자 속에 "ㅓㄴ"이 포함된 경우
                    braille_jung = ""
                    braille_jong = "⠾"
                }else if firstjong == "ㄴ"{
                    braille_jung = ""
                    braille_jong = "⠾" + kor_jong["\(secondjong)"]!
                }else if jong == "ㄹ"{ // 글자 속에 "ㅓㄹ"이 포함된 경우
                    braille_jung = ""
                    braille_jong = "⠞"
                }else if firstjong == "ㄹ"{
                    braille_jung = ""
                    braille_jong = "⠞" + kor_jong["\(secondjong)"]!
                } // 한글점자규정 제16항: '성,썽,정,쩡,청'은 'ㅅ,ㅆ,ㅈ,ㅉ,ㅊ' 다음에 'ㅕㅇ'의 약자('⠻')를 적어 나타낸다.
                else if jong == "ㅇ" && (cho == "ㅅ" || cho == "ㅆ" || cho == "ㅈ" || cho == "ㅉ" || cho == "ㅊ"){
                    braille_jung = ""
                    braille_jong = "⠻"
                }
            }else if jung == "ㅕ"{
                if jong == "ㄴ"{ // 글자 속에 "ㅕㄴ"이 포함된 경우
                    braille_jung = ""
                    braille_jong = "⠡"
                }else if firstjong == "ㄴ"{
                    braille_jung = ""
                    braille_jong = "⠡" + kor_jong["\(secondjong)"]!
                }else if jong == "ㄹ"{ // 글자 속에 "ㅕㄹ"이 포함된 경우
                    braille_jung = ""
                    braille_jong = "⠳"
                }else if firstjong == "ㄹ"{
                    braille_jung = ""
                    braille_jong = "⠳" + kor_jong["\(secondjong)"]!
                }else if jong == "ㅇ"{ // 글자 속에 "ㅕㅇ"이 포함된 경우
                    braille_jung = ""
                    braille_jong = "⠻"
                }
            }else if jung == "ㅗ"{
                if jong == "ㄱ"{ // 글자 속에 "ㅗㄱ"이 포함된 경우
                    braille_jung = ""
                    braille_jong = "⠭"
                }else if firstjong == "ㄱ"{
                    braille_jung = ""
                    braille_jong = "⠭" + kor_jong["\(secondjong)"]!
                }else if jong == "ㄴ"{ // 글자 속에 "ㅗㄴ"이 포함된 경우
                    braille_jung = ""
                    braille_jong = "⠷"
                }else if firstjong == "ㄴ"{
                    braille_jung = ""
                    braille_jong = "⠷" + kor_jong["\(secondjong)"]!
                }else if jong == "ㅇ"{ // 글자 속에 "ㅗㅇ"이 포함된 경우
                    braille_jung = ""
                    braille_jong = "⠿"
                }
            }else if jung == "ㅜ"{
                if jong == "ㄴ"{ // 글자 속에 "ㅜㄴ"이 포함된 경우
                    braille_jung = ""
                    braille_jong = "⠛"
                }else if firstjong == "ㄴ"{
                    braille_jung = ""
                    braille_jong = "⠛" + kor_jong["\(secondjong)"]!
                }else if jong == "ㄹ"{ // 글자 속에 "ㅜㄹ"이 포함된 경우
                    braille_jung = ""
                    braille_jong = "⠯"
                }else if firstjong == "ㄹ"{
                    braille_jung = ""
                    braille_jong = "⠯" + kor_jong["\(secondjong)"]!
                }
            }else if jung == "ㅡ"{
                if jong == "ㄴ"{ // 글자 속에 "ㅡㄴ"이 포함된 경우
                    braille_jung = ""
                    braille_jong = "⠵"
                }else if firstjong == "ㄴ"{
                    braille_jung = ""
                    braille_jong = "⠵" + kor_jong["\(secondjong)"]!
                }else if jong == "ㄹ"{  // 글자 속에 "ㅡㄹ"이 포함된 경우
                    braille_jung = ""
                    braille_jong = "⠮"
                }else if firstjong == "ㄹ"{
                    braille_jung = ""
                    braille_jong = "⠮" + kor_jong["\(secondjong)"]!
                }
            }else if jung == "ㅣ"{
                if jong == "ㄴ"{  // 글자 속에 "ㅣㄴ"이 포함된 경우
                    braille_jung = ""
                    braille_jong = "⠟"
                }else if firstjong == "ㄴ"{
                    braille_jung = ""
                    braille_jong = "⠟" + kor_jong["\(secondjong)"]!
                }
            }
            
            // 한글점자규정 제12항: 것은 약자("⠸⠎")를 사용한다.
            if n == "것"{
                braille_cho = ""
                braille_jong = ""
                braille_jung = "⠸⠎"
            }else if n == "껏"{ // 한글점자규정 제14항: '까,싸,껏'은 각각 '가,사,것'의 약자 표기에 된소리 표를 덧붙여 적는다.
                braille_cho = ""
                braille_jong = ""
                braille_jung = "⠠⠸⠎"
            }else if n == "팠"{ // 한글점자규정 제17항 [붙임]: '팠'을 적을 때에는 'ㅏ'를 생략하지 않고 적는다.
                braille_cho = ""
                braille_jong = ""
                braille_jung = "⠙⠣⠌"
            }
            
            flag_17 = false

            
            return braille_cho + braille_jung + braille_jong
            
        }else{
            return String(UnicodeScalar(n))
        }
    }
    
    // [한글 분해] 자모음으로 분해해서 리턴하는 함수 (한글로 규칙을 파악해야할 때 사용)
    private class func getJamoFromOneSyllable(_ n: UnicodeScalar) -> String?{
        if CharacterSet(charactersIn: ("가".unicodeScalars.first!)...("힣".unicodeScalars.first!)).contains(n){
            let index = n.value - INDEX_HANGUL_START
            
            let cho = CHO[Int(index / CYCLE_CHO)]

            let jung = JUNG[Int((index % CYCLE_CHO) / CYCLE_JUNG)]
            
            // 종성은 없는 경우도 있음
            var jong = JONG[Int(index % CYCLE_JUNG)]
            if let disassembledJong = JONG_DOUBLE[jong] {
                jong = disassembledJong
            }
            
            return cho + jung + jong
        }else{
            return String(UnicodeScalar(n))
        }
    }
}
