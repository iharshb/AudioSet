import Flutter
import UIKit
import AVFoundation
import MediaPlayer

enum Speaker : Float {
   case Left = -1
   case Right = 1
   case Both = 0
}

enum SpeakerVolume {
    case Increase
    case Decrease
}

public class SwiftAudiosetPlugin: NSObject, FlutterPlugin {
    
//    var audioEngine: AVAudioEngine = AVAudioEngine()
//    var equalizer: AVAudioUnitEQ!
//    var audioPlayerNode: AVAudioPlayerNode = AVAudioPlayerNode()
//    var audioFile: AVAudioFile!
    
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var audioFile: AVAudioFile!
    var audioUnitEQ = AVAudioUnitEQ(numberOfBands: 10)
    var isPlaying = false

    //let MAX_GAIN: Float = 24.0
    //let MIN_GAIN: Float = -96.0

    private var player : AVAudioPlayer?
    private var player2 : AVAudioPlayer?
    private let flutterMethodPlayMusic = "playMusic"
    private let flutterMethodPlayMusicFrequency = "playMusicFrerquency"
    private let flutterMethodPlayMusicSpeaker = "playMusicSpeaker"
    private let flutterMethodPlayMusicMuted = "playMusicMuted"
    private let flutterMethodSetMusicVolume = "setMusicVolume"
    private let flutterMethodSetMusicPaused = "playMusicPaused"
    private let flutterMethodSetMusicResumed = "playMusicResumed"
    private let flutterMethodSetMusicStop = "playMusicStop" 
    
    var registrar: FlutterPluginRegistrar? = nil   
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "audioset", binaryMessenger: registrar.messenger())
        let instance = SwiftAudiosetPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
         instance.registrar = registrar
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch(call.method) {
        
        case flutterMethodPlayMusic:
            
            let arguments = call.arguments as! NSDictionary
             print(arguments)
            let asset =  arguments["asset"] as! String
            let type =  arguments["type"] as! String
            let musicFile = arguments["file"] as! Int
            let isRepeat = arguments["isRepeat"] as! Bool
            self.playMusic(strResource: asset, type: type,musicFile: musicFile,isRepeat:isRepeat)
            self.playMusicWithFrequency(strResource: asset, type: type, number: musicFile, frequency: [750.0,1500.0], pan: -1)
        case flutterMethodPlayMusicFrequency:
            
            let arguments = call.arguments as! NSDictionary
             print(arguments)
            let asset =  arguments["asset"] as! String
            let type =  arguments["type"] as! String
            let musicFile = arguments["file"] as! Int
            let speakerSide =  arguments["speakerSide"] as! Float
            let frequency = arguments["frequency"] as! [Float]
            self.playMusicWithFrequency(strResource: asset, type: type, number: musicFile, frequency: frequency, pan: speakerSide)

        case flutterMethodPlayMusicSpeaker:
            let arguments = call.arguments as! NSDictionary
            let speakerSide =  arguments["speakerSide"] as! Float
            let musicFile = arguments["file"] as! Int
            self.playMusicSpeaker(player:musicFile == 1 ? player : player2,speakerSide:speakerSide) 
            
        case flutterMethodPlayMusicMuted:
            let arguments = call.arguments as! NSDictionary
            let musicFile = arguments["file"] as! Int
            self.playMusicMuted(player:musicFile == 1 ? player : player2)
            
        case flutterMethodSetMusicVolume:
            let arguments = call.arguments as! NSDictionary
            let musicFile = arguments["file"] as! Int
            let musicVolume = arguments["volume"] as! Float
            self.setMusicVolume(player:musicFile == 1 ? player : player2,volume: musicVolume)

        case flutterMethodSetMusicPaused:
            let arguments = call.arguments as! NSDictionary
            let musicFile = arguments["file"] as! Int
            self.playMusicPaused(player:musicFile == 1 ? player : player2)
            self.audioPause()

        case flutterMethodSetMusicResumed:
            let arguments = call.arguments as! NSDictionary
            let musicFile = arguments["file"] as! Int
            self.playMusicResumed(player:musicFile == 1 ? player : player2)
            self.audioResume()
        
        case flutterMethodSetMusicStop:
            let arguments = call.arguments as! NSDictionary
            let musicFile = arguments["file"] as! Int
            self.playMusicStop(player:musicFile == 1 ? player : player2)
            self.audioStop()

        default:
            print ("Unknown method called on Native Audio Player channel.")
        }
    }
    

    func playMusic(strResource:String, type:String,musicFile:Int,isRepeat:Bool){
        let key = registrar?.lookupKey(forAsset:  strResource)
        if let path = Bundle.main.path(forResource: key, ofType : nil) {
            let url = URL(fileURLWithPath : path)
            do {
                if musicFile == 1 {
                    if let player = player, player.isPlaying {
                            self.playMusicStop(player:player)
                    }
                    player = try AVAudioPlayer(contentsOf: url)
                    if isRepeat {
                        player?.numberOfLoops = 100
                    } else {
                        player?.numberOfLoops = 1
                    }
                    player?.play()
                } else {
                    if let player2 = player2, player2.isPlaying {
                            self.playMusicStop(player:player2)
                    }
                    player2 = try AVAudioPlayer(contentsOf: url)
                    if isRepeat {
                        player2?.numberOfLoops = 100
                    } else {
                        player2?.numberOfLoops = 1
                    }
                    player2?.play()
                }

            } catch {
                print ("There is an issue with this code!")
            }
        } else {
            print("Path Not Found")
        }
        
    }
    


    func playMusicSpeaker(player:AVAudioPlayer?,speakerSide:Speaker.RawValue) {
        if let player = player, player.isPlaying {
                player.pan = speakerSide
        }
        
        if let audioPlayerNode = audioPlayerNode,audioPlayerNode.isPlaying {
            audioPlayerNode.pan = speakerSide
        }
    }

    func playMusicMuted(player:AVAudioPlayer?){
        if let player = player, player.isPlaying {
            if player.volume == 0.0 {
                player.volume = 1.0
            } else {
                player.volume = 0.0
            }
        }
        
        if let audioPlayerNode = audioPlayerNode,audioPlayerNode.isPlaying {
            if audioPlayerNode.volume == 0.0 {
                audioPlayerNode.volume = 1.0
            } else {
                audioPlayerNode.volume = 0.0
            }
        }
    }

    func playMusicPaused(player:AVAudioPlayer?){
        if let player = player, player.isPlaying {
                player.pause()
        }
    }

    func playMusicResumed(player:AVAudioPlayer?){
        if let player = player {
                player.play()
        }
    }

    func playMusicStop(player:AVAudioPlayer?){
        if let player = player, player.isPlaying {
            player.stop()
        }
    }
    
    func setMusicVolume(player:AVAudioPlayer?,volume: Float){
        if let player = player, player.isPlaying {
            player.volume = volume
        }
    }


  
    
    func audioSetup(frequency:[Float]) {

       // let FREQUENCY: [Float] = [31, 62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]

        self.audioEngine = AVAudioEngine.init()
        self.audioPlayerNode = AVAudioPlayerNode.init()
        self.audioUnitEQ = AVAudioUnitEQ(numberOfBands: frequency.count)
        self.audioEngine.attach(self.audioPlayerNode)
        self.audioEngine.attach(self.audioUnitEQ)
        for i in 0...(frequency.count - 1) {
            self.audioUnitEQ.bands[i].filterType = .parametric
            self.audioUnitEQ.bands[i].frequency = frequency[i]
            self.audioUnitEQ.bands[i].bandwidth = 0.5 // half an octave
           // let eq = self.value(forKey: String(format: "eq%d", i)) as! UISlider
            self.audioUnitEQ.bands[i].gain = -10 //eq.value
            self.audioUnitEQ.bands[i].bypass = false
        }
        self.audioUnitEQ.bypass = true
    }

    func playMusicWithFrequency(strResource:String, type:String,number:Int,frequency:[Float],pan:Float) {
        self.audioStop()
        self.isPlaying = true

        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        try! AVAudioSession.sharedInstance().setActive(true)

        self.audioSetup(frequency: frequency)

        let key = registrar?.lookupKey(forAsset:  strResource)
        let path = Bundle.main.path(forResource: key, ofType: nil)
        self.audioFile = try! AVAudioFile(forReading: URL(fileURLWithPath: path!))

        self.audioPlayerNode.scheduleSegment(self.audioFile, startingFrame: 0, frameCount: AVAudioFrameCount(self.audioFile.length), at: nil, completionHandler: self.completion)

        self.audioEngine.connect(self.audioPlayerNode, to: self.audioUnitEQ, format: self.audioFile.processingFormat)
        self.audioEngine.connect(self.audioUnitEQ, to: self.audioEngine.mainMixerNode, format: self.audioFile.processingFormat)

        if !self.audioEngine.isRunning {
            try! self.audioEngine.start()
        }
        let sampleRate = self.audioFile.processingFormat.sampleRate / 2
        let format = self.audioEngine.mainMixerNode.outputFormat(forBus: 0)
        self.audioEngine.mainMixerNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(sampleRate), format: format, block:{ (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
            // print(buffer.frameLength)
        })
        self.audioPlayerNode.pan = pan
        self.audioPlayerNode.play()
    }
    
    func audioStop() {
        self.isPlaying = false
        if let audioPlayerNode = audioPlayerNode,audioPlayerNode.isPlaying {
            self.audioPlayerNode.pause()
            self.audioPlayerNode.stop()
            self.audioEngine.stop()
            self.audioEngine.mainMixerNode.removeTap(onBus: 0)
        }
        
    }
    
    func audioPause() {
        if let audioPlayerNode = audioPlayerNode,audioPlayerNode.isPlaying {
            self.audioPlayerNode.pause()
        }
        
    }
    
    func audioResume() {
        if let audioPlayerNode = audioPlayerNode {
            self.audioPlayerNode.play()
        }
        
    }

    func completion() {
        if self.isPlaying {
            DispatchQueue.main.async {
                // self.play(self.playButton)
                if self.isPlaying {
                    self.audioStop()
                } else {
                    // self.audioPlay()
                }
            }
        }
    }
}
