import UIKit
import CallKit
import PushKit
import TalkPlus
import TalkPlusWebRTC

@available(iOS 13.0, *)
class VideoCallViewController: UIViewController {

    private var client = CXCallManager.shared.client
    private var talkplusCall:TalkPlusCall?
    private let delegateId = "VideoCallViewController"
    private var voipRegistry: PKPushRegistry!
    
    @IBOutlet weak var localVideoView: UIView!
    @IBOutlet weak var remoteVideoView: UIView!
    @IBOutlet weak var audioImageView: UIImageView! {
        didSet {
            let selector = #selector(didTapEnableLocalAudio(_:))
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: selector)
            audioImageView.isUserInteractionEnabled = true
            audioImageView.addGestureRecognizer(tapGestureRecognizer)
            audioImageView.image = UIImage(systemName: "mic.circle.fill")
        }
    }
    @IBOutlet weak var videoImageView: UIImageView! {
        didSet {
            let selector = #selector(didTapEnableLocalVideo(_:))
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: selector)
            videoImageView.isUserInteractionEnabled = true
            videoImageView.addGestureRecognizer(tapGestureRecognizer)
            videoImageView.image = UIImage(systemName: "video.circle.fill")
        }
    }
    @IBOutlet weak var makeCallImageView: UIImageView! {
        didSet {
            let selector = #selector(didTapMakeCall(_:))
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: selector)
            makeCallImageView.isUserInteractionEnabled = true
            makeCallImageView.addGestureRecognizer(tapGestureRecognizer)
            makeCallImageView.image = UIImage(systemName: "phone.circle.fill")
            makeCallImageView.tintColor = .green
            makeCallImageView.isHidden = false
        }
    }
    
    @IBOutlet weak var endCallImageView: UIImageView! {
        didSet {
            let selector = #selector(didTapEndCall(_:))
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: selector)
            endCallImageView.isUserInteractionEnabled = true
            endCallImageView.addGestureRecognizer(tapGestureRecognizer)
            endCallImageView.image = UIImage(systemName: "phone.down.circle.fill")
            endCallImageView.tintColor = .red
            endCallImageView.isHidden = false
        }
    }
    
    private var isAudioTrackEnabled:Bool = true {
        willSet(newVal) {
            if newVal {
                audioImageView.image = UIImage(systemName: "mic.circle.fill")
            } else {
                audioImageView.image = UIImage(systemName: "mic.slash.fill")
            }
        }
    }
    private var isVideoTrackEnabled:Bool = true {
        willSet(newVal) {
            if newVal {
                videoImageView.image = UIImage(systemName: "video.circle.fill")
            } else {
                videoImageView.image = UIImage(systemName: "video.slash.fill")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("VideoCallViewController viewDidLoad")
        // Add WebRTC Client Delegate
        client.addDelegate(self, identifier: self.delegateId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove WebRTC Client Delegate
        print("VideoCallViewController viewWillDisappear")
        client.removeDelegate(self.delegateId)
    }
    
    deinit {
        print("VideoCallViewController deinit")
    }
}

extension VideoCallViewController {
    
    @objc func didTapMakeCall(_ sender: UITapGestureRecognizer) {
        guard let callerId = TalkPlus.sharedInstance().getCurrentUser()?.getId() else {
            print("talplus login is needed.")
            return
        }
        let calleeId = callerId == "test1" ? "test2" : "test1"
        let params = TalkPlusCallParams("YOUR_CHANNEL_ID",
                                        callerId: callerId,
                                        calleeId: calleeId,
                                        uuid: UUID())
        params.customData = ["screenIdentifier":"VideoCallVC"];
        
        let alert = UIAlertController(title: "CONFIRM", message: "Make a call to \(calleeId) ?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "CANCEL", style: .default, handler: nil)
        let confirm = UIAlertAction(title: "CALL", style: .destructive) { [weak self] _ in
            print("\(#function) didTapMakeCall")
            self?.client.makeCall(params) { [weak self] result, call in
                guard let call = call, result == true  else { return }
                self?.talkplusCall = call
                CXCallManager.shared.startCall(call)
            }
        }
        alert.addAction(confirm)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func didTapEndCall(_ sender: UITapGestureRecognizer) {
        client.endCall { [weak self] result, call in
            guard let call = call, result == true else { return }
            print("\(#function) didTapEndCall, \(TalkPlusCall.getEndReasonMessage(call.endReasonCode))")
            CXCallManager.shared.endCall(for: call.uuid, endedAt: Date(), endReasonCode: call.endReasonCode)
            self?.removeVideoSubViews()
        }
    }
    
    @objc func didTapEnableLocalVideo(_ sender: UITapGestureRecognizer) {
        guard let localVideoTrack = self.talkplusCall?.localVideoTrack else { return }
        let isEnable = client.isTrackEnabled(localVideoTrack)
        print("video isEnable: \(isEnable)")
        client.setEnableTrack(!isEnable, track: localVideoTrack)
        self.isVideoTrackEnabled = client.isTrackEnabled(localVideoTrack)
    }
    
    @objc func didTapEnableLocalAudio(_ sender: UITapGestureRecognizer) {
        guard let localAudioTrack = self.talkplusCall?.localAudioTrack else { return }
        let isEnable = client.isTrackEnabled(localAudioTrack)
        print("audio isEnable: \(isEnable)")
        client.setEnableTrack(!isEnable, track: localAudioTrack)
        self.isAudioTrackEnabled = client.isTrackEnabled(localAudioTrack)
    }
    
    func removeVideoSubViews() {
        for subview in localVideoView.subviews { subview.removeFromSuperview() }
        for subview in remoteVideoView.subviews { subview.removeFromSuperview() }
    }
}

extension VideoCallViewController: TPWebRTCClientDelegate {
    
    func didReceiveCallIncoming(_ call: TalkPlusCall) {
        print("\(#function), VideoCallViewController, didReceiveCallIncoming, call from \(call.callerId)")
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: "Call from \(call.callerId)")
        update.localizedCallerName = "Call from \(call.callerId)"
        update.hasVideo = true
        CXCallManager.shared.reportIncomingCall(with: call.uuid, update: update)
    }
    
    func didReceiveCallConnect(_ call: TalkPlusCall) {
        print("\(#function), VideoCallViewController, didReceiveCallConnect")
        self.talkplusCall = call;
        guard let localRendererView = call.localRendererView,
              let remoteRendererView = call.remoteRendererView else { return }
        embedView(localRendererView, into: localVideoView)
        embedView(remoteRendererView, into: remoteVideoView)
    }
    
    func didReceiveCallDisconnected(_ call: TalkPlusCall) {
        print("\(#function), VideoCallViewController, didReceiveCallDisconnected")
    }
    
    func didReceiveCallFailed(_ call: TalkPlusCall) {
        print("\(#function), VideoCallViewController, didReceiveCallFailed")
        removeVideoSubViews()
    }
    
    func didReceiveCallEnd(_ call: TalkPlusCall) {
        print("\(#function), VideoCallViewController, didReceiveCallEnd, \(TalkPlusCall.getEndReasonMessage(call.endReasonCode))")
        removeVideoSubViews()
    }
    
    func didReceiveCallError(_ call: TalkPlusCall, error: [AnyHashable : Any]) {
        print("\(#function), VideoCallViewController, didReceiveCallError, \(error)")
        CXCallManager.shared.endCall(for: call.uuid, endedAt: Date(), endReasonCode: call.endReasonCode)
    }
    
    func didReceiveStateChange(_ call: TalkPlusCall, newState: RTCIceConnectionState) {
        print("\(#function), VideoCallViewController, didReceiveStateChange, \(newState)")
        switch newState {
        case .connected, .completed:
            makeCallImageView.isHidden = true
        default:
            makeCallImageView.isHidden = false
        }
    }
}

extension VideoCallViewController {
    func embedView(_ addingView: UIView, into containerView: UIView) {
        for view in containerView.subviews { view.removeFromSuperview() }
        containerView.addSubview(addingView)
        addingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            addingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            addingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            addingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
        containerView.layoutIfNeeded()
    }
}

