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
    private let flutterMethodGetMusicVolume = "getMusicVolume"
    private let flutterMethodPlayMusicPaused = "playMusicPaused"
    private let flutterMethodPlayMusicResumed = "playMusicResumed"
    private let flutterMethodPlayMusicStop = "playMusicStop"
     
    var registrar: FlutterPluginRegistrar? = nil
    var timer:Timer?
    let VOLUME_DB : Float = 0.05
    
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
           // self.playMusicWithFrequency(strResource: asset, type: type, number: musicFile, frequency: [750.0,1500.0], pan: -1)
        case flutterMethodPlayMusicFrequency:
            
            let arguments = call.arguments as! NSDictionary
             print(arguments)
            let asset =  arguments["asset"] as! String
            let type =  arguments["type"] as! String
            let musicFile = arguments["file"] as! Int
            let speakerSide =  arguments["speakerSide"] as! Float
            let frequency = arguments["frequency"] as! [Float]
            let isIncreasedVolume = arguments["isEveryFiveSecIncreseVolume"] as! Bool
            let fType = arguments["filterType"] as! Int
            self.playMusicWithFrequency(strResource: asset, type: type, number: musicFile, frequency: frequency, pan: speakerSide,isIncreasedVolume:isIncreasedVolume, filterType: fType)

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
        case flutterMethodGetMusicVolume:
            let volume = self.getMusicVolume()
            result(volume)
        case flutterMethodPlayMusicPaused:
            let arguments = call.arguments as! NSDictionary
            let musicFile = arguments["file"] as! Int
            self.playMusicPaused(player:musicFile == 1 ? player : player2)
            self.audioPause()

        case flutterMethodPlayMusicResumed:
            let arguments = call.arguments as! NSDictionary
            let musicFile = arguments["file"] as! Int
            self.playMusicResumed(player:musicFile == 1 ? player : player2)
            self.audioResume()
        
        case flutterMethodPlayMusicStop:
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
        
        if let timer = timer {
            timer.invalidate()
        }
    }
    
    func setMusicVolume(player:AVAudioPlayer?,volume: Float){
        if let player = player, player.isPlaying {
            player.volume = volume
        }
        if let audioPlayerNode = audioPlayerNode,audioPlayerNode.isPlaying {
            self.audioPlayerNode.volume = volume
        }
    }
    
    func getMusicVolume() -> Float {
        if let player = player {
            return player.volume
        }
        return 0.0
    }


    // Frequency

//    func playMusicWithFrequency(strResource:String, type:String,number:Int,frequency:[Float],pan:Float){
//        if audioPlayerNode.isPlaying {
//            audioPlayerNode.stop()
//        }
        
      //  self.setFrequncy(freqs: frequency)
//            do {
//                if let filepath = Bundle.main.path(forResource: strResource, ofType: type) {
//                    let filepathURL = NSURL.fileURL(withPath: filepath)
//                    audioFile = try AVAudioFile(forReading: filepathURL)
//                    audioEngine.prepare()
//
//                    try audioEngine.start()
//                    audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
//                    audioPlayerNode.play()
//                 //   audioPlayerNode.pan = pan
//                }
//            } catch _ {
//                print ("There is an issue with this code!")
//            }
//       }
    
//    func setFrequncy(freqs:[Float]) {
//        self.clearAllData()
//        equalizer = AVAudioUnitEQ(numberOfBands: freqs.count)
//        audioEngine.attach(audioPlayerNode)
//        audioEngine.attach(equalizer)
//        let bands = equalizer.bands
//        audioEngine.connect(audioPlayerNode, to: equalizer, format: nil)
//        audioEngine.connect(equalizer, to: audioEngine.outputNode, format: nil)
//        for i in 0...(bands.count - 1) {
//            bands[i].frequency  = Float(freqs[i])
//            bands[i].bypass     = false
//            bands[i].filterType = .parametric
//        }
//
//        bands[0].gain = -10.0
//        bands[0].filterType = .lowShelf
//    }
//
//    func clearAllData() {
//        equalizer = AVAudioUnitEQ()
//        audioEngine = AVAudioEngine()
//        audioPlayerNode = AVAudioPlayerNode()
//    }
    
    
    func audioSetup(frequency:[Float],filterType:Int) {

       // let FREQUENCY: [Float] = [31, 62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
        
        self.audioEngine = AVAudioEngine.init()
        self.audioPlayerNode = AVAudioPlayerNode.init()
        self.audioUnitEQ = AVAudioUnitEQ(numberOfBands: frequency.count)
        self.audioEngine.attach(self.audioPlayerNode)
        self.audioEngine.attach(self.audioUnitEQ)
        for i in 0...(frequency.count - 1) {
            if filterType == -1 {
                self.audioUnitEQ.bands[i].filterType = .lowPass
            } else if filterType == 1{
                self.audioUnitEQ.bands[i].filterType = .highPass
            } else {
                self.audioUnitEQ.bands[i].filterType = .parametric
            }
            
            self.audioUnitEQ.bands[i].frequency = frequency[i]
            self.audioUnitEQ.bands[i].bandwidth = 0.5 // half an octave
           // let eq = self.value(forKey: String(format: "eq%d", i)) as! UISlider
            self.audioUnitEQ.bands[i].gain = -10 //eq.value
            self.audioUnitEQ.bands[i].bypass = false
        }
        self.audioUnitEQ.bypass = true
    }

    func playMusicWithFrequency(strResource:String, type:String,number:Int,frequency:[Float],pan:Float,isIncreasedVolume:Bool,filterType:Int) {
        self.audioStop()
        self.isPlaying = true
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        try! AVAudioSession.sharedInstance().setActive(true)

        self.audioSetup(frequency: frequency, filterType: filterType)

        let key = registrar?.lookupKey(forAsset:  strResource)
        let path = Bundle.main.path(forResource: key, ofType: nil)
        self.audioFile = try! AVAudioFile(forReading: URL(fileURLWithPath: path!))

        self.audioPlayerNode.scheduleSegment(self.audioFile, startingFrame: 0, frameCount: AVAudioFrameCount(self.audioFile.length), at: nil, completionHandler: self.completion)

        self.audioEngine.connect(self.audioPlayerNode, to: self.audioUnitEQ, format: self.audioFile.processingFormat)
        self.audioEngine.connect(self.audioUnitEQ, to: self.audioEngine.mainMixerNode, format: self.audioFile.processingFormat)

        if !self.audioEngine.isRunning {
            do {
                try self.audioEngine.start()
            } catch {
                print ("There is an issue with this code!")
            }
            
        }
        let sampleRate = self.audioFile.processingFormat.sampleRate / 2
        let format = self.audioEngine.mainMixerNode.outputFormat(forBus: 0)
        self.audioEngine.mainMixerNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(sampleRate), format: format, block:{ (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
            // print(buffer.frameLength)
        })
        self.audioPlayerNode.pan = pan
        self.audioPlayerNode.play()
        if isIncreasedVolume {
            self.startTimer()
        } else {
            self.stopTimer()
        }
        
    }
    
    func audioStop() {
        self.isPlaying = false
        if let audioPlayerNode = audioPlayerNode {
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
    
    @objc func increasedVolume() {
        let volume = self.getMusicVolume() + VOLUME_DB
        if let player = player, player.isPlaying {
            player.volume = volume
        }
        if let audioPlayerNode = audioPlayerNode,audioPlayerNode.isPlaying {
            self.audioPlayerNode.volume = volume
        }
    }
    
    func startTimer() {
         if let timer = timer {
                   timer.invalidate()
         }
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector:#selector(self.increasedVolume), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if let timer = timer {
            timer.invalidate()
        }
        
    }
}
