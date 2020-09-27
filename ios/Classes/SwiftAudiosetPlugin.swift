import Flutter
import UIKit
import AVFoundation

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
    
    // private var avPlayer: AVPlayer!
    // private var avPlayerItem: AVPlayerItem!
    // private var isReadyToPlay = false
    // Veriable Declaration
    private var player : AVAudioPlayer?
    private var player2 : AVAudioPlayer?
    private let flutterMethodPlayMusic = "playMusic"
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
        //registar ma problem hoy toh flutter assets no path na ave!!!!
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch(call.method) {
        
        // Method Added
        case flutterMethodPlayMusic:
            
           
            let arguments = call.arguments as! NSDictionary
             print(arguments)
            let asset =  arguments["asset"] as! String
            let type =  arguments["type"] as! String
            let musicFile = arguments["file"] as! Int
            let isRepeat = arguments["isRepeat"] as! Bool
            self.playMusic(strResource: asset, type: type,musicFile: musicFile,,isRepeat:isRepeat)

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
            let musicVolume = arguments["volume"] as! Int
            self.setMusicVolume(player:musicFile == 1 ? player : player2,volume: musicVolume)

        case flutterMethodSetMusicPaused:
            let arguments = call.arguments as! NSDictionary
            let musicFile = arguments["file"] as! Int
            self.playMusicPaused(player:musicFile == 1 ? player : player2)

        case flutterMethodSetMusicResumed:
            let arguments = call.arguments as! NSDictionary
            let musicFile = arguments["file"] as! Int
            self.playMusicResumed(player:musicFile == 1 ? player : player2)
        
        case flutterMethodSetMusicStop:
            let arguments = call.arguments as! NSDictionary
            let musicFile = arguments["file"] as! Int
            self.playMusicStop(player:musicFile == 1 ? player : player2)

           // 2 pr click krj
        // case "play":
        //     let arguments = call.arguments as! NSDictionary
           
            
        // case "resume":
        //     self.resume()
            
        // case "pause":
        //     self.pause()
            
        // case "stop":
        //     self.stop()
            
            
        // case "dragVolume":
        //     let arguments = call.arguments as! NSDictionary
        //     let dragPoint =  arguments["dragPoint"] as! Int
        
            
        //  case "muteVolume":
        //    self.volum
        default:
            print ("Unknown method called on Native Audio Player channel.")
        }
    }
    

    func playMusic(strResource:String, type:String,musicFile:Int,isRepeat:Bool){
        //var registar : FlutterPluginRegistrar? = nil
        // Prblm ena pchi ave che
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
                        player.numberOfLoops = 100
                    } else {
                        player.numberOfLoops = 1
                    }
                    player?.play()
                } else {
                    if let player2 = player2, player2.isPlaying {
                            self.playMusicStop(player:player2)
                    }
                    player2 = try AVAudioPlayer(contentsOf: url)
                    if isRepeat {
                        player2.numberOfLoops = 100
                    } else {
                        player2.numberOfLoops = 1
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
    
    // func playMusicSpeaker(i: Float, player:AVAudioPlayer?, speakerSide:Speaker) {
    //     if let player = player, player.isPlaying {
    //         player.pan = speakerSide.rawValue
    //     }
    // }

    func playMusicSpeaker(player:AVAudioPlayer?,speakerSide:Speaker.RawValue) {
        if let player = player, player.isPlaying {
                player.pan = speakerSide
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
    }

    func playMusicPaused(player:AVAudioPlayer?){
        if let player = player, player.isPlaying {
                player.pause()
        }
    }

    func playMusicResumed(player:AVAudioPlayer?){
        if let player = player,player.isPlaying {
                player.play()
        }
    }

    func playMusicStop(player:AVAudioPlayer?){
        if let player = player, player.isPlaying {
            player.stop()
        }
    }
    
    func setMusicVolume(player:AVAudioPlayer?,volume: SpeakerVolume){
        if let player = player, player.isPlaying {
            player.volume = SpeakerVolume
            // if volume == .Increase {
            //     print("Player Volume \(player.volume)")
            //     if player.volume >= 1.0 {
            //         player.volume = 1.0
            //     } else {
            //         player.volume = player.volume + 0.1
            //     }
            // } else {
            //     print("Player Volume \(player.volume)")
            //     if player.volume <= 0.0 {
            //         player.volume = 0.0
            //     } else {
            //         player.volume = player.volume - 0.1
            //     }
            // }
        }
    }
    
    // func changeToSpeaker() -> Bool{
    //     try? AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
    //     return true;
    // }
    
    // func changeToReceiver() -> Bool{
    //     return changeByPortType([AVAudioSession.Port.builtInMic])
    // }
    
    // func changeToHeadphones() -> Bool{
    //     return changeByPortType([AVAudioSession.Port.headsetMic])
    // }
    

    // func getCurrentPort(){
    //     return changeByPortType([AVAudioSession.Port.headsetMic])
    // }
    
    // func changeByPortType(_ ports:[AVAudioSession.Port]) -> Bool{
    //     let currentRoute = AVAudioSession.sharedInstance().currentRoute
    //     for output in currentRoute.outputs {
    //         if(ports.firstIndex(of: output.portType) != nil){
    //             return true;
    //         }
    //     }
    //     if let inputs = AVAudioSession.sharedInstance().availableInputs {
    //         for input in inputs {
    //             if(ports.firstIndex(of: input.portType) != nil){
    //                 try?AVAudioSession.sharedInstance().setPreferredInput(input);
    //                 return true;
    //             }
    //         }
    //     }
    //     return false;
    // }
}
