import UIKit
import CallKit
import PushKit
import TalkPlus
import TalkPlusWebRTC

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var voipRegistry: PKPushRegistry!
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        //TalkPlus.sharedInstance().initWithAppId("YOUR_APP_ID")
        TalkPlus.sharedInstance().initWithAppId("c45d29fe-7ee9-41cd-9499-8066e54c845c")
        talkPlusLogin()
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, 
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration
    {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
    
    private func talkPlusLogin() {
        
        let userId = UserDefaults.standard.string(forKey: "KeyUserID") ?? "test1"
        let userName = UserDefaults.standard.string(forKey: "KeyUserName") ?? "test1"
        
        let params = TPLoginParams(loginType: TPLoginType.anonymous, 
                                   userId: userId)
        params?.userName = userName
        
        TalkPlus.sharedInstance()?.login(params, success: { [weak self] tpUser in
            guard let tpUser = tpUser, let userId = tpUser.getId(), let userName = tpUser.getUsername() else { return }
            UserDefaults.standard.set(userId, forKey: "KeyUserID")
            UserDefaults.standard.set(userName, forKey: "KeyUserName")
            UserDefaults.standard.synchronize()
            if AVAudioSession.sharedInstance().recordPermission == .granted {
                // VoIP Push Token
                self?.voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
                self?.voipRegistry.delegate = self
                self?.voipRegistry.desiredPushTypes = [.voIP]
            }
        }, failure: { (errorCode, error) in
            print("login failed.")
        })
    }
}

extension AppDelegate: PKPushRegistryDelegate {
    
    public func pushRegistry(
        _ registry: PKPushRegistry,
        didUpdate pushCredentials: PKPushCredentials,
        for type: PKPushType
    ) {
        //let pushKitToken = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
        CXCallManager.shared.client.registerVoIPPushToken(pushCredentials.token) {
            print("voip push token registered")
        } failure: { errorCode, error in
            print("registerVoIPPushToken failed. \(String(describing: error))")
        }
    }
    
    public func pushRegistry(
        _ registry: PKPushRegistry,
        didReceiveIncomingPushWith payload: PKPushPayload,
        for type: PKPushType, completion: @escaping () -> Void
    ) {
        print("\(#function), dictionaryPayload : \(payload.dictionaryPayload)")
        guard type == .voIP else { return }
        CXCallManager.shared.client.voipPushRegistry(payload.dictionaryPayload)
        completion()
    }
}
