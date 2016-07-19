//
//  MyDocument.swift
//  iCloudStore
//
//  Created by JHJG on 2016. 7. 15..
//  Copyright © 2016년 KangJungu. All rights reserved.
//

import UIKit

class MyDocument: UIDocument {
    
    //애플리케이션의 데이터 구조를 구현해야함. 예제에서는 텍스튜 객체에 입력한 단순한 문자열이기때문에 MyDoucument 클래스안에 그냥 문자열 하나 선언( 복잡하면 클래스로 만들어야함)
    var userText:String? = "Some Sample Text"
    
    /**
     밑의 두개의 클래스는 필수적으로 있어야한다.
     **/
    //이 메서드는 데이터가 파일이나 문서에 쓰일때 UIDocument 하위 클래스에 의해 호출된다. 이 메서드는 기록될 데이터를 수집하고 NSData나 NSFileWrapper객체의 형태로 반환하는 것을 담당한다.
    override func contentsForType(typeName: String) throws -> AnyObject {
        if let content = userText {
            let length = content.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            //단순히 NSString 객체인 userText에서 현재 값을 얻어 NSData 객체에 넣고 반환하는 것.
            return NSData(bytes: content, length: length)
        }else{
            return NSData()
        }
    }
    
    
    //이 메서드는 문서의 내용이 담겨있는 NSData 객체를 넘겨 받으며, 이에 해당하는 애플리케이션의 내부 데이터 구조를 업데이트하는 역할을 한다. 
    override func loadFromContents(contents: AnyObject, ofType typeName: String?) throws {
        
        //이 메서드가 할 일은 NSData 객체의 내용을 문자열로 변환하고 이를 userText 객체에 할당하는것
        if let userContent = contents as? NSData{
            userText = NSString(bytes: contents.bytes, length: userContent.length, encoding: NSUTF8StringEncoding) as? String
        }
    }
}
