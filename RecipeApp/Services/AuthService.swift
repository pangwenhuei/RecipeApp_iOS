//
//  AuthServiceProtocol.swift
//  RecipeApp
//
//  Created by TTHQ23-PANGWENHUEI on 19/08/2025.
//

import RxSwift
import RxRelay
import Alamofire

protocol AuthServiceProtocol {
    var isLoggedIn: Observable<Bool> { get }
    func login(username: String, password: String) -> Observable<Bool>
    func logout() -> Observable<Void>
    func getCurrentUser() -> String?
}

class AuthService: AuthServiceProtocol {
    private let isLoggedInRelay = BehaviorRelay<Bool>(value: false)
    private let userDefaults = UserDefaults.standard
    private let sessionKey = "UserSession"
    private let encryptionKey = "RecipeAppKey2023"
    
    var isLoggedIn: Observable<Bool> {
        return isLoggedInRelay.asObservable()
    }
    
    init() {
        // Check for existing session
        if let _ = userDefaults.string(forKey: sessionKey) {
            isLoggedInRelay.accept(true)
        }
    }
    
    func login(username: String, password: String) -> Observable<Bool> {
        return Observable.create { observer in
            AF.request("https://json-placeholder.mock.beeceptor.com/login", method: .post)
                .authenticate(username: username, password: password)
                .responseDecodable(of: LoginResponse.self) { response in
                    switch response.result {
                    case .success:
                        let encryptedSession = self.encrypt(username)
                        self.userDefaults.set(encryptedSession, forKey: self.sessionKey)
                        self.isLoggedInRelay.accept(true)
                        observer.onNext(true)
                        break
                    case .failure:
                        observer.onNext(false)
                        break
                    }
                    observer.onCompleted()
                }
            return Disposables.create()
        }
    }
    
    func logout() -> Observable<Void> {
        return Observable.create { observer in
            self.userDefaults.removeObject(forKey: self.sessionKey)
            self.isLoggedInRelay.accept(false)
            observer.onNext(())
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func getCurrentUser() -> String? {
        guard let encryptedSession = userDefaults.string(forKey: sessionKey) else { return nil }
        return decrypt(encryptedSession)
    }
    
    private func encrypt(_ string: String) -> String {
        // Simple encryption - in real app, use proper encryption
        return Data(string.utf8).base64EncodedString()
    }
    
    private func decrypt(_ string: String) -> String? {
        guard let data = Data(base64Encoded: string) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
