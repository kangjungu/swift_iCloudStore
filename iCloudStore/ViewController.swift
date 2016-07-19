//
//  ViewController.swift
//  iCloudStore
//
//  Created by JHJG on 2016. 7. 15..
//  Copyright © 2016년 KangJungu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var textView: UITextView!
    
    var document:MyDocument?
    var documentURL:NSURL?
    
    //아이클라우드 저장소에 대한 URL을 저장하는데 사용되는 객체
    var ubiquityURL:NSURL?
    //문서 검색은 NSMetaDataQuery 객체를 사용하여 수행하며, 이객체는 뷰 컨트롤러 클래스에 선언되어야 한다. 객체가 사용되는 메서드 안에 객체를 선언할경우 검색이 완료되기 전에 ARC서비스에 의해 해제될수 있다!!
    var metaDataQuery: NSMetadataQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //아이클라우드 관련
        
        let filemgr = NSFileManager.defaultManager()
        //권한 파일에 나열된 첫번째 컨테이너를 디폴트로 하기위해 nil을 메서드의 인자로 전달한다. 문서는 Documents 하위 디렉터리에 저장하는 것을 권장하기 때문에 URL 경로명에 그 부분이 추가되어야한다.
        ubiquityURL = filemgr.URLForUbiquityContainerIdentifier(nil)
        
        //사용자가 iOS 설정 앱의 iCloud 화면 내에 유요한 애플ID를 설정했을 경우에만 ubiquityURL을 얻을수 있도록 할것이다.
        //만약에 ubiquityURL을 얻을수 없는 경우에는 사용자에게 그 사실을 알려주기 위한 몇가지 방어적인 코드를 추가하도록 한다.
        guard ubiquityURL != nil else{
            print("Unable to access iCloud Account")
            print("Open the settings app and enter your Apple ID into iCloud settings")
            return
        }
        
        //애플은 문서들을 Documents 하위 디렉터리에 저장하라고 권장하고 있으므로 경로명 끝에 문서이름을 추가하도록한다.
        ubiquityURL = ubiquityURL?.URLByAppendingPathComponent("/Documents/savefile.txt")
        
        /**
         아이클라우드 저장소에서 savefile.txt 파일이 있는지 검색하고, 그결과에 따라 적절하게 대처하는 것이다.
         검색은 NSMetaDataQuery 객체의 인스턴스 메서드를 호출하여 수행한다. 이를 위해 객체를 생성하고 검색할 파일을 가리킬 조건문을 만들어 검색 범위를 설정한다.
         검색이 시작되면 별도의 스레드에 의해 수행되며, 완료시 노티피케이션이 생선된다. 따라서 완료되었다는 노티피 케이션을 수신하기 위해서 옵저버도 구성해야한다.
         */
        metaDataQuery = NSMetadataQuery()
        metaDataQuery?.predicate = NSPredicate(format: "%K like 'savefile.txt'", NSMetadataItemFSNameKey)
        metaDataQuery?.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(ViewController.metadataQueryDidFinishGathering(_:)),
                                                         name: NSMetadataQueryDidFinishGatheringNotification,
                                                         object: metaDataQuery!)
        
        //startQuery가 호출되면 검색이 시작되고, 검색이 완료되면 옵저버로 인해 metadataQueryDidFinishGathering 메서드가 호출된다.
        //그러므로 metadataQueryDidFinishGathering 메서드를 구현해보자.
        metaDataQuery?.startQuery()
        
        
        ///// 로컬 파일 관련
        //        //파일 매니저 객체 가져오기
        //        let filemgr = NSFileManager.defaultManager()
        //
        //        //Document 디렉터리 경로 확인
        //        let dirPaths = filemgr.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        //
        //        //파일 이름까지 넣어서 documentURL 경로 완성
        //        documentURL = dirPaths[0].URLByAppendingPathComponent("savefile.txt")
        //
        //        //위에서 만든 url로 MyDocument 클래스의 인스턴스 생성
        //        document = MyDocument(fileURL: documentURL!)
        //        document?.userText = ""
        //
        //        //파일 이 이미 존재하면
        //        if filemgr.fileExistsAtPath((documentURL?.path)!) {
        //            //openWithCompletionHandler를 호출하는 과정에서 loadFromContents 메서드가 자동으로 호출된다.
        //            document?.openWithCompletionHandler({ (success:Bool) -> Void in
        //                if success{
        //                    print("File open OK")
        //                    self.textView.text = self.document?.userText
        //                }else{
        //                    print("Failed to open file")
        //                }
        //            })
        //        }else{
        //        //파일이 존재하지 않는경우
        //            //saveToURL 메소드가 호출되어 새 파일을 생성한다.
        //            document?.saveToURL(documentURL!, forSaveOperation: .ForCreating, completionHandler: { (success:Bool) -> Void in
        //                if success {
        //                    print("File create OK")
        //                }else{
        //                    print("Failed to crate file")
        //                }
        //            })
        //        }
    }
    
    //검색이 완료되면 옵저버를 통해서 이 메서드가 호출된다.
    func metadataQueryDidFinishGathering(notification: NSNotification) -> Void {
        //이 메서드를 호출하도록 하는 쿼리 객체를 식별
        let query: NSMetadataQuery = notification.object as! NSMetadataQuery
        //이 객체의 쿼리가 더이상 업데이트 되지 않도록 한다.( 이 시점에서 문서가 존재하는지 아닌지 검색하므로 추가적인 업데이트
        query.disableUpdates()
        //옵저버 제거
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSMetadataQueryDidFinishGatheringNotification, object: query)
        //쿼리 스탑
        query.stopQuery()
        
        //검색을 통해 찾은 문서의 배열을 추출
        //좀 더 복잡한 애플리케이션이라면 하나 이상의 문서가 배열에 있어 for 루프를 통해 결과를 추출해야한다.
        let result = query.results
        
        //iCloudStore 애플리케이션은 오직 하나의 파일이름만 검색했으므로 배열 원소의 갯수를 체크해보면 1일것이다(문서가 존재하면)
        if query.resultCount == 1 {
            //쿼리 객체에서 얻은 문서의 유비쿼터스 URL을 ubiquityURL에 할당하고, document라고 불리우는 MyDocument 클래스의 인스턴스를 생성하는 데 사용한다.
            let resultURL = result[0].valueForAttribute(NSMetadataItemURLKey) as! NSURL
            
            document = MyDocument(fileURL: resultURL)
            //그런 다음, 클라우드에 있는 그 문서를 열고 내용을 읽기 위해 document 객체의 openWithCompletionHanlder 메서드가 호출된다.
            //이는 document 객체의 loadFromContents 메서드를 호출하고 문서 내용을 userText 속성에 할당한다.
            document?.openWithCompletionHandler({ (success:Bool) -> Void in
                if success {
                    //문서 읽기가 성공하면 userText의 내용이 텍스트 뷰 객체에 text 속성에 할당되어 사용자에게 표시된다.
                    print("iCloud file open OK")
                    self.textView.text = self.document?.userText
                    self.ubiquityURL = resultURL
                }else{
                    print("iCloud file open failed")
                }
            })
        } else{
            //아이클라우드 저장소에 문서가 존재하지 않는 경우
            //document 객체의 saveToURL 메서드에 ubiquityiURL을 인자로 전달하여 문서를 만들어야 한다.
            document = MyDocument(fileURL: ubiquityURL!)
            document?.saveToURL(ubiquityURL!,
                                forSaveOperation: .ForCreating,
                                completionHandler: { (success:Bool) -> Void in
                                    if success {
                                        print("iCloud create OK")
                                    }else{
                                        print("iCloud create failed")
                                    }
            })
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveDocument(sender: UIButton) {
        
        /**
         기존의 로컬파일을 아이클라우드에 저장하는 방법
         do{
            try filemgr.setUbiquitous(true, itemAtURL: documentURL!, destinationURL: ubiquityURL!)
         }catch let error NSError{
            print("실패");
         }
        */
        document?.userText = textView.text
        
        document?.saveToURL(ubiquityURL!, forSaveOperation: .ForOverwriting, completionHandler: { (success: Bool) -> Void in
            if success{
                print("Save overrite OK")
            }else{
                print("Save overwrite failed")
            }
        })
        //        //document 객체의 userText 속성을 현재 글로 설정하고
        //        document?.userText = textView.text
        //
        //        //document에 새로운 글을 save한다
        //        document?.saveToURL(documentURL!, forSaveOperation: .ForOverwriting, completionHandler: { (success: Bool) -> Void in
        //            if success {
        //                print("File overwirte OK")
        //            }else{
        //                print("File overwrtie failed")
        //            }
        //        })
    }
    
}

