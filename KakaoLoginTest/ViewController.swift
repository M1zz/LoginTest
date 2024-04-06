//
//  ViewController.swift
//  KakaoLoginTest
//
//  Created by hyunho lee on 3/19/24.
//

import UIKit
import KakaoSDKUser

class ViewController: UIViewController {

    @IBOutlet weak var kakaotalkLogin: UIButton!
    @IBOutlet weak var kakaotalkLogout: UIButton!
    private var userLoginState: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userLoginState = getUserLoginState()
        
        // 로그인이 가능할 경우
        if !UserApi.isKakaoTalkLoginAvailable() {
            // 현재 사용자의 상태가 로그인이 된 경우
            if userLoginState {
                kakaotalkLogin.isHidden = true
            } else {
                kakaotalkLogout.isHidden = true
            }
        }
    }

    // SNS 로그인이 동작해야하는 함수
    @IBAction func didTapKakaoLoginButton(_ sender: Any) {
        print("\(UserApi.isKakaoTalkLoginAvailable()) button clicked")
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                } else {
                    print("loginWithKakaoTalk() success.")
                   self.kakaoGetUserInfo()
                }
            }
        }
    }
    
    // SNS 로그아웃 버튼이 동작해야하는 함수
    @IBAction func didTapKakaoLogoutButton(_ sender: Any) {
        UserApi.shared.logout {(error) in
            if let error = error {
                print(error)
            }
            else {
                print("logout() success.")
            }
        }
    }
    
    // 사용자의 로그인 상태가 불러와지는 코드
    private func getUserLoginState() -> Bool {
        // 저장되어있는 사용자의 로그인 상태를 불러오는 코드
        return true
    }
    
    // 로그인 아후에 사용자의 정보를 가져오는 함수
    private func kakaoGetUserInfo() {
        UserApi.shared.me() { (user, error) in
            if let error = error {
                print(error)
            }
            
            let userName = user?.kakaoAccount?.name
            let userEmail = user?.kakaoAccount?.email
            let userGender = user?.kakaoAccount?.gender
            let userProfile = user?.kakaoAccount?.profile?.profileImageUrl
            let userBirthYear = user?.kakaoAccount?.birthyear
            
            let contentText =
            "user name : \(userName)\n userEmail : \(userEmail)\n userGender : \(userGender), userBirthYear : \(userBirthYear)\n userProfile : \(userProfile)"
            
            print("user - \(String(describing: user))")
            
            if userEmail == nil {
                self.kakaoRequestAgreement()
                return
            }
            
            //self.textField.text = contentText
        }
    }
    
    // SNS로그인 동의를 요청하는 함수
    private func kakaoRequestAgreement() {
        UserApi.shared.me() { (user, error) in
            if let error = error {
                print(error)
            }
            else {
                guard let user = user else { return }
                var scopes = [String]()
                if (user.kakaoAccount?.profileNeedsAgreement == true) { scopes.append("profile") }
                if (user.kakaoAccount?.emailNeedsAgreement == true) { scopes.append("account_email") }
                if (user.kakaoAccount?.birthdayNeedsAgreement == true) { scopes.append("birthday") }
                if (user.kakaoAccount?.birthyearNeedsAgreement == true) { scopes.append("birthyear") }
                if (user.kakaoAccount?.genderNeedsAgreement == true) { scopes.append("gender") }
                if (user.kakaoAccount?.phoneNumberNeedsAgreement == true) { scopes.append("phone_number") }
                if (user.kakaoAccount?.ageRangeNeedsAgreement == true) { scopes.append("age_range") }
                if (user.kakaoAccount?.ciNeedsAgreement == true) { scopes.append("account_ci") }

                if scopes.count > 0 {
                    print("사용자에게 추가 동의를 받아야 합니다.")

                    UserApi.shared.loginWithKakaoAccount(scopes: scopes) { (_, error) in
                        if let error = error {
                            print(error)
                        }
                        else {
                            UserApi.shared.me() { (user, error) in
                                if let error = error {
                                    print(error)
                                }
                                else {
                                    print("me() success.")
                                    guard let user = user else { return }

                                    //do something
                                    let userName = user.kakaoAccount?.name
                                    let userEmail = user.kakaoAccount?.email
                                    let userGender = user.kakaoAccount?.gender
                                    let userProfile = user.kakaoAccount?.profile?.profileImageUrl
                                    let userBirthYear = user.kakaoAccount?.birthyear

                                    let contentText =
                                    "user name : \(userName)\n userEmail : \(userEmail)\n userGender : \(userGender), userBirthYear : \(userBirthYear)\n userProfile : \(userProfile)"

                                        //self.textField.text = contentText
                                    print(contentText)
                                }
                            }
                        }
                    }
                }
                else {
                    print("사용자의 추가 동의가 필요하지 않습니다.")
                }
            }
        }
    }
}

