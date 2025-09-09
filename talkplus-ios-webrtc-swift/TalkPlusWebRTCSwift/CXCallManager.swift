import UIKit
import TalkPlusWebRTC
import CallKit
import PushKit

@available(iOS 13.0, *)
class CXCallManager: NSObject {
    let client = TPWebRTCClient()
    static let shared = CXCallManager()
    private let provider: CXProvider
    private let controller = CXCallController()
    
    override init() {
        self.provider = CXProvider.default
        super.init()
        self.provider.setDelegate(self, queue: .main)
        self.client.addDelegate(self, identifier: "CXCallManager")
    }
}

extension CXCallManager: TPWebRTCClientDelegate {
    
    func didReceiveCallIncoming(_ call: TalkPlusCall) {
        print("\(#function), CXCallManager, didReceiveCallIncoming")
    }
    
    func didReceiveCallEnd(_ call: TalkPlusCall) {
        print("\(#function), CXCallManager, didReceiveCallEnd, \(TalkPlusCall.getEndReasonMessage(call.endReasonCode))")
        CXCallManager.shared.endCall(for: call.uuid, endedAt: Date(), endReasonCode: call.endReasonCode)
    }
    
    func didReceiveCallConnect(_ call: TalkPlusCall) {
        print("\(#function), CXCallManager, didReceiveCallConnect")
        CXCallManager.shared.connectedCall(call)
    }
    
    func didReceiveCallDisconnected(_ call: TalkPlusCall) {
        print("\(#function), CXCallManager, didReceiveCallDisconnected")
    }
    
    func didReceiveCallFailed(_ call: TalkPlusCall) {
        print("\(#function), CXCallManager, didReceiveCallFailed, \(TalkPlusCall.getEndReasonMessage(call.endReasonCode))")
        CXCallManager.shared.endCall(for: call.uuid, endedAt: Date(), endReasonCode: call.endReasonCode)
    }
}

extension CXCallManager {
    
    func reportIncomingCall(with callID: UUID,
                            update: CXCallUpdate,
                            completionHandler: ((Error?) -> Void)? = nil)
    {
        self.provider.reportNewIncomingCall(with: callID, update: update) { (error) in
            if let error = error as? CXErrorCodeIncomingCallError {
                switch error.code {
                case .callUUIDAlreadyExists:
                    print("\(#function), Call already exists")
                default:
                    print("\(#function), CallKit error: \(error)")
                }
            } else if let error = error {
                print("\(#function), other error: \(error.localizedDescription)")
            } else {
                print("\(#function), incoming call reported successfully")
            }
            completionHandler?(error)
        }
    }
    
    func requestTransaction(_ transaction: CXTransaction, action: String = "") {
        print("\(#function) requestTransaction")
        self.controller.request(transaction) { error in
            guard error == nil else {
                print("\(String(describing: error))")
                return
            }
        }
    }
    
    func startCall(_ call: TalkPlusCall) {
        print("\(#function) startCall")
        let handle = CXHandle(type: .generic, value: call.calleeId)
        let startCallAction = CXStartCallAction(call: call.uuid, handle: handle)
        startCallAction.isVideo = true
        let transaction = CXTransaction(action: startCallAction)
        self.requestTransaction(transaction)
    }
    
    func endCall(for callId: UUID, endedAt: Date, endReasonCode: TPEndCallReason) {
        print("\(#function) endCall")
        var reason:CXCallEndedReason = .remoteEnded
        switch endReasonCode {
        case .declined:     reason = .declinedElsewhere
        case .canceled:     reason = .remoteEnded
        case .completed:    reason = .remoteEnded
        default:            reason = .failed
        }
        self.provider.reportCall(with: callId, endedAt: endedAt, reason: reason)
    }
    
    func connectedCall(_ call: TalkPlusCall) {
        print("\(#function) connectedCall")
        self.provider.reportOutgoingCall(with: call.uuid, connectedAt: Date())
    }
}

extension CXCallManager: CXProviderDelegate {
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        print("\(#function) CXStartCallActions")
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        print("\(#function) CXAnswerCallAction")
        CXCallManager.shared.client.acceptCall({ result, _ in
            result ? action.fulfill() : action.fail()
        })
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("\(#function) CXEndCallAction")
        CXCallManager.shared.client.endCall({ _, _ in })
        action.fulfill()
    }
    
    func providerDidReset(_ provider: CXProvider) { }
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) { }
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) { }
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) { }
}

extension CXProviderConfiguration {
    // The app's provider configuration, representing its CallKit capabilities
    static var `default`: CXProviderConfiguration {
        let providerConfiguration = CXProviderConfiguration(localizedName: "TalkPlusCallDemo")
        providerConfiguration.supportsVideo = true
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.maximumCallGroups = 1
        providerConfiguration.supportedHandleTypes = [.generic]
        return providerConfiguration
    }
}

extension CXProvider {
    static var `default`: CXProvider {
        CXProvider(configuration: .default)
    }
}
