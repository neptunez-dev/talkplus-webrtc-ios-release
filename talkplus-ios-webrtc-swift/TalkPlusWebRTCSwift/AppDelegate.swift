import UIKit
import CallKit
import PushKit
import TalkPlus
import TalkPlusWebRTC

@main
@available(iOS 13.0, *)
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var voipRegistry: PKPushRegistry!
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        TalkPlus.sharedInstance().initWithAppId("YOUR_APP_ID")
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
        guard type == .voIP else {
            print("\(#function), push type is not VoIP.")
            return
        }
        
        print("\(#function), dictionaryPayload : \(payload.dictionaryPayload)")
        CXCallManager.shared.client.voipPushRegistry(payload.dictionaryPayload)
        
        guard let callerId = payload.dictionaryPayload["callerId"] as? String else { return }
        guard let calleeId = payload.dictionaryPayload["calleeId"] as? String else { return }
        guard let uuid = payload.dictionaryPayload["uuid"] as? String else { return }
        guard let channelId = payload.dictionaryPayload["channelId"] as? String else { return }
        
        let call = TalkPlusCall(channelId, callerId: callerId, calleeId: calleeId, uuidString: uuid)
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: "Call from \(call.callerId)")
        update.localizedCallerName = "Call from \(call.callerId)"
        update.hasVideo = true
        /*
         pushRegistry(_:didReceiveIncomingPushWith:for:completion:) 메소드가 호출되었는데,
         reportNewIncomingCall(with:update:completion:)를 호출하지 않으면
         iOS가 앱을 강제로 종료하고 (Crash 발생), 이후부터는 보안 정책 때문에 더 이상 VoIP 푸시를 해당 앱에 전달하지 않게 됩니다.
         이후 시스템은 앱을 더 이상 Wake Up 하지 않습니다.
        */
        CXCallManager.shared.reportIncomingCall(with: call.uuid, update: update)
        completion()
    }
}
