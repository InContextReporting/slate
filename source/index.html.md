---
title: inContext Reference

language_tabs: # must be one of https://git.io/vQNgJ
  - swift: Swift
  - objective_c: Obj-c
  - javascript: React Native

toc_footers:
  - <a href='https://incontext.ai'>inContext.ai</a>

search: true
---
# Introduction

inContext.ai services are accessed through the concept of "Bots".  Each Bot type is specific to the functionality which it is designed to fullfil.  Each Bot is tailored with a custom language model to best recognize specific speech patterns and emits different events based on its use case.

# Setup

```
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, "10.0"
use_frameworks!

target "ChatbotExample" do
  pod "ChatbotSDK"
end
```
Add ChatbotSDK to your podfile, then run pod update.

<aside class="warning">You'll need to add an <code>Privacy - Microphone Usage Description</code> property to your application's Info.plist in order to access the microphone.</aside>

## Additional Setup for React Native

```
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
```

React Native setup requires additional steps to create a native iOS to React bridge.

To install, run `npm install react-native-chatbot-sdk --save` from the React Native project folder.

Copy `RNChatbotSDK.m` and `RNChatbotSDK.swift` from node_modules/react-native-chatbot-sdk/ios into your project. You will be prompted to create a bridging header. Accept and place the additional `#import` statements into the header.

# Initialization

```swift
let chatbot = ChatBot(username: "username", password: "password")
```

```objective_c
ChatBot *chatbot = [[ChatBot alloc] initWithUsername:@"username" password:@"password"];
```

```javascript
ChatBot.initialize("username", "password");
```

All bots first need to be initialized.  Use your credentials to instantiate and initialize a Bot.


# Connecting


```swift
chatbot.connect(onConnectSuccess: { (loginStatus) in
    //connection success
}, onConnectError: { (loginStatus) in
    //connection error
})
```

```objective_c
[chatbot connectOnConnectSuccess:^(LoginStatus * _Nonnull loginStatus) {
    //connection success
} onConnectError:^(LoginStatus * _Nonnull loginStatus) {
    //connection error
}];
```

```javascript
ChatBot.connect((error, loginStatus) => {
    if (loginStatus.success) {
        //connection success
    } else {
        //connection error
    }
});
```

Once initialized, establish a connection to inContext.  `loginStatus` will contain the result of the connection.

# Listening

```swift
chatbot.activate(onConnect: {
    //connected and listening
}, onDisconnect: {
    //disconnected
}, onError: {
    //error
}, onPartialResult: { (partial) in
    //partial speech recognized
}, onResult: { (interaction) in
    //full speech recognized and interaction concluded
})
```

```objective_c
[chatbot activateOnConnect:^{
    //connected and listening
} onDisconnect:^{
    //disconnected
} onError:^{
    //error
} onPartialResult:^(NSString * _Nonnull partial) {
    //partial speech recognized
} onResult:^(Interaction * _Nullable interaction) {
    //full speech recognized and interaction concluded
}];
```

```javascript
ChatBot.activate(
    (error, text) => {
        //connected and listening
    },
    (error, text) => {
        //disconnected
    },
    (error, text) => {
        //error
    },
    (error, partial) => {
        //partial speech recognized, result in partial (String)
    },    
    (error, json) => {
        //full speech recognized and interaction concluded, result in json (String)
    }
);
```
Once connected, enable the microphone and begin listening.  Results are emitted as speech is processed.

<aside class="warning">Bots will automatically deactivate after 30 seconds of not hearing speech.  This will trigger an <code>onDisconnect</code> event.</aside>

# Bots

## ChatBot

```swift
import UIKit
import ChatbotSDK

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let chatbot = ChatBot(username: "username", password: "password")
        chatbot.connect(onConnectSuccess: { (loginStatus) in
            chatbot.activate(onConnect: {
                //connected and listening
                chatbot.enableSpeaker() //enable reading out of response
            }, onDisconnect: {
                //disconnected
            }, onError: {
                //error
            }, onPartialResult: { (partial) in
                //partial speech recognized
            }, onResult: { (interaction) in
                self.textView.text.append("Doctor: \(interaction!.display_as!)\n")
                self.textView.text.append("Bot: \(interaction!.response ?? "nil")\n")
            })
        }, onConnectError: { (loginStatus) in
            //connection error
        })
    }
}
```

```objective_c
#import "ViewController.h"
#import <ChatbotSDK/ChatbotSDK.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ChatBot *chatbot = [[ChatBot alloc] initWithUsername:@"username" password:@"password"];
    [chatbot connectOnConnectSuccess:^(LoginStatus * _Nonnull loginStatus) {
        [chatbot activateOnConnect:^{
            //connected and listening
            [chatbot enableSpeaker];
        } onDisconnect:^{
            //disconnected
        } onError:^{
            //error
        } onPartialResult:^(NSString * _Nonnull partial) {
            //partial speech recognized
        } onResult:^(Interaction * _Nullable interaction) {
            self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"Doctor: %@\n", interaction.display_as]];
            self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"Bot: %@\n", interaction.response ?: @""]];
        }];
    } onConnectError:^(LoginStatus * _Nonnull loginStatus) {
        //connection error
    }];
}

@end

```

```javascript
import React, {Component} from 'react';
import {StyleSheet, Text, ScrollView} from 'react-native';
import {ChatBot} from 'react-native-chatbot-sdk';

type Props = {};
export default class App extends Component<Props> {
    constructor() {
        super();
        this.state = {
            log: '\n'
        }

        ChatBot.initialize("username", "password");

        ChatBot.connect((error, loginStatus) => {
            if (loginStatus.success) {
                ChatBot.activate(
                    //onConnect
                    (error, text) => {
                        this.log("Connected")
                        ChatBot.enableSpeaker()
                    },
                    //onDisconnect
                    (error, text) => {
                        //disconnected
                    },
                    //onError
                    (error, text) => {
                        //error
                    },
                    //onPartialResult
                    (error, partial) => {
                        //partial speech recognized
                    },
                    //onResult
                    (error, interactionJson) => {
                        var interaction = JSON.parse(interactionJson);
                        this.log("Doctor: " + interaction.display_as);
                        this.log("Bot: " + interaction.response);
                    });
            } else {
                //connection error
            }
        });
    }

    log(text) {
        this.setState({
            log: this.state.log + text + '\n'
        });
    }

  render() {
    return (
      <ScrollView
          style={styles.container}
          ref={ref => this.scrollView = ref}
          onContentSizeChange={(contentWidth, contentHeight)=>{
              this.scrollView.scrollToEnd({animated: true});
          }}>
        <Text style={styles.instructions}>{this.state.log}</Text>
      </ScrollView>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5FCFF',
  },
  instructions: {
    textAlign: 'left',
    color: '#333333',
    marginBottom: 5,
  },
});
```

ChatBot is a question and answer virtual assistant that listens for questions and commands, then returns answers or pointers to results.

An example interaction might look like this:

| | | 
--------- | ------- 
Doctor | Is the report for patient Smith ready?
Bot | Yes, patient Smith's ultrasound report is ready.
Doctor | Was there appendicitis?
Bot | Yes, patient Smith's ultrasound report is consistent with acute perforated appendicitis.  I will let the on call surgical team know to start getting the O-R ready.
Doctor | Any signs of infection?
Bot | Patient Smith's blood test results are consistent with a mild infection. White cell count was reported at 11.3 thousand cells per microliter, which is above the normal range.

An instance of ChatBot enables the microphone and listens for questions and commands.  Partial speech recognition results are available using the `onPartialResult` event.  Once an utterance is heard, an `onResult` event fires with access to the result. Optionally, the response can be read out using device audio. 

### Constructor

Instantiate a Bot object using a username and password

Parameters | Type | Description
--------- | ------- | -----------
username | String | The username for authentication
password | String | The password for authentication

### connect()

Connect to inContext using the credentials used during bot instantiation

Parameters | Type | Description
--------- | ------- | -----------
onConnectSuccess | Function | Execute on connection success (`LoginStatus in`)
onConnectError | Function | Execute on connection failure (`LoginStatus in`)

### disconnect()

Disconnect from inContext

### activate()

Enable microphone and begin listening

Parameters | Type | Description
--------- | ------- | -----------
onConnect | Function | Execute on activation complete
onDisconnect | Function | Execute on deactivation complete
onError | Function | Execute on error
onPartialResult | Function | Execute on partial speech recognized (`String in`)
onResult | Function | Execute on final result and response is ready.  `Interaction` object will contain the result

<aside class="warning">Bots will automatically deactivate after 30 seconds of not hearing speech.  This will trigger an <code>onDisconnect</code> event.</aside>

### deactivate()

Stop listening and disable microphone

### enableSpeaker()

Enable reading out response through audio device when final result is received

### disableSpeaker()

Disable reading out response through audio device when final result is received

## ScribeBot

```swift
import UIKit
import ChatbotSDK

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let scribebot = ScribeBot(username: "username", password: "password")
        scribebot.connect(onConnectSuccess: { (loginStatus) in
            scribebot.activate(onConnect: {
                //connected and listening
            }, onDisconnect: {
                //disconnected
            }, onError: {
                //error
            }, onResult: { (interaction) in
                self.textView.text.append("\(interaction!.display_as!)\n")
            })
        }, onConnectError: { (loginStatus) in
            //connection error
        })
    }
}
```

```objective_c
#import "ViewController.h"
#import <ChatbotSDK/ChatbotSDK.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ScribeBot *scribebot = [[ScribeBot alloc] initWithUsername:@"username" password:@"password"];
    [scribebot connectOnConnectSuccess:^(LoginStatus * _Nonnull loginStatus) {
        [scribebot activateOnConnect:^{
            //connected and listening
        } onDisconnect:^{
            //disconnected
        } onError:^{
            //error
        } onPartialResult:^(NSString * _Nonnull partial) {
            //partial speech recognized
        } onResult:^(Interaction * _Nullable interaction) {
            self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"%@\n", interaction.display_as]];
        }];
    } onConnectError:^(LoginStatus * _Nonnull loginStatus) {
        //connection error
    }];
}

@end
```

```javascript
Not Implemented
```

ScribeBot is a transcription virtual assistant that listens for notes then aggregates and extracts data from the notes for later retrieval

An example interaction might look like this:

| | | 
--------- | ------- 
Doctor | Room ten patient smith sixty nine year old male
Doctor | Chest pain, negative EKG
Doctor | Unable to urinate, awaiting urology consult

An instance of ScribeBot enables the microphone and listens for notes.  Once an utterance is heard, an `onResult` event fires with access to the full patient context.


### Constructor

Instantiate a Bot object using a username and password

Parameters | Type | Description
--------- | ------- | -----------
username | String | The username for authentication
password | String | The password for authentication

### connect()

Connect to inContext using the credentials used during bot instantiation

Parameters | Type | Description
--------- | ------- | -----------
onConnectSuccess | Function | Execute on connection success (`LoginStatus in`)
onConnectError | Function | Execute on connection failure (`LoginStatus in`)

### disconnect()

Disconnect from inContext

### activate()

Enable microphone and begin listening

Parameters | Type | Description
--------- | ------- | -----------
onConnect | Function | Execute on activation complete
onDisconnect | Function | Execute on deactivation complete
onError | Function | Execute on error
onPartialResult | Function | Execute on partial speech recognized (`String in`)
onResult | Function | Execute on final result and response is ready.  `Interaction` object will contain the result

<aside class="warning">Bots will automatically deactivate after 30 seconds of not hearing speech.  This will trigger an <code>onDisconnect</code> event.</aside>

### deactivate()

Stop listening and disable microphone

### newVisit()

Manually trigger a new visit

### endCurrentVisit()

Manually end current visit

## CodeBlueBot

```swift
import UIKit
import ChatbotSDK

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let codebluebot = CodeBlueBot(username: "username", password: "password")
        codebluebot.connect(onConnectSuccess: { (loginStatus) in
            codebluebot.activate(onConnect: {
                //connected and listening
            }, onDisconnect: {
                //disconnected
            }, onError: {
                //error
            }, onResult: { (interaction) in
                for action in interaction?.action ?? [] {
                    self.textView.text.append("\(action.command ?? "Unknown")\n")
                    for (k, v) in action.arguments_kv ?? [:] {
                        self.textView.text.append("  \(k): \(v)\n")
                    }
                    self.textView.text.append("\n")
                }
            })
        }, onConnectError: { (loginStatus) in
            //connection error
        })
    }
}
```

```objective_c
#import "ViewController.h"
#import <ChatbotSDK/ChatbotSDK.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CodeBlueBot *codebluebot = [[CodeBlueBot alloc] initWithUsername:@"username" password:@"password"];
    [codebluebot connectOnConnectSuccess:^(LoginStatus * _Nonnull loginStatus) {
        [codebluebot activateOnConnect:^{
            //connected and listening
        } onDisconnect:^{
            //disconnected
        } onError:^{
            //error
        } onPartialResult:^(NSString * _Nonnull partial) {
            //partial speech recognized
        } onResult:^(Interaction * _Nullable interaction) {
            for (Action* action in interaction.action) {
                self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"%@\n", action.command]];
                for (id key in action.arguments_kv) {
                    self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"  %@: %@\n", key, [action.arguments_kv objectForKey:key]]];
                }
                self.textView.text = [self.textView.text stringByAppendingString:@"\n"];
            }
        }];
    } onConnectError:^(LoginStatus * _Nonnull loginStatus) {
        //connection error
    }];
}

@end
```

```javascript
import React, {Component} from 'react';
import {StyleSheet, Text, ScrollView} from 'react-native';
import {CodeBlueBot} from 'react-native-chatbot-sdk';

type Props = {};
export default class App extends Component<Props> {
    constructor() {
        super();
        this.state = {
            log: '\n'
        }

        CodeBlueBot.initialize("username", "password");

        CodeBlueBot.connect((error, loginStatus) => {
            if (loginStatus.success) {
                CodeBlueBot.activate(
                    //onConnect
                    (error, text) => {
                        this.log("Connected")
                    },
                    //onDisconnect
                    (error, text) => {
                        //disconnected
                    },
                    //onError
                    (error, text) => {
                        //error
                    },
                    //onResult
                    (error, interactionJson) => {
                        var interaction = JSON.parse(interactionJson);
                        if (interaction.action != null) {
                            for (var action of interaction.action) {
                                this.log(action.command);
                                if (action.arguments_kv != null) {
                                    for (const [k, v] of Object.entries(action.arguments_kv)) {
                                        this.log('  ' + k + ': ' + v);
                                    }
                                }
                                this.log('');
                            }
                        }
                    });
            } else {
                console.log(loginStatus.error)
            }
        });
    }

    log(text) {
        this.setState({
            log: this.state.log + text + '\n'
        });
    }

    render() {
        return (
            <ScrollView
                style={styles.container}
                ref={ref => this.scrollView = ref}
                onContentSizeChange={(contentWidth, contentHeight)=>{
                    this.scrollView.scrollToEnd({animated: true});
                }}>
                <Text style={styles.instructions}>{this.state.log}</Text>
            </ScrollView>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#F5FCFF',
    },
    instructions: {
        textAlign: 'left',
        color: '#333333',
        marginBottom: 5,
    },
});
```

CodeBlueBot is a transcription virtual assistant that listens for phrases typical during a Code Blue event then triggers a function with event details.

Example utterances that will trigger events

| Example Phrase | Event | 
--------- | ------- 
Defibrillator set to 300 joules | icrDefibrillatorSet(power=300, unit_power=joules)
1 milligram of epinephrin delivered | icrMedicationDelivered(dose=1, unit_dose=milligram, medication=epinephrine)
Shock delivered | icrShockDelivered()

An instance of CodeBlueBot enables the microphone and listens for Code Blue events.  Once an utterance is heard, an `onResult` event fires with access to action details


### Constructor

Instantiate a Bot object using a username and password

Parameters | Type | Description
--------- | ------- | -----------
username | String | The username for authentication
password | String | The password for authentication

### connect()

Connect to inContext using the credentials used during bot instantiation

Parameters | Type | Description
--------- | ------- | -----------
onConnectSuccess | Function | Execute on connection success (`LoginStatus in`)
onConnectError | Function | Execute on connection failure (`LoginStatus in`)

### disconnect()

Disconnect from inContext

### activate()

Enable microphone and begin listening

Parameters | Type | Description
--------- | ------- | -----------
onConnect | Function | Execute on activation complete
onDisconnect | Function | Execute on deactivation complete
onError | Function | Execute on error
onResult | Function | Execute on final result and response is ready.  `Interaction` object will contain the result

<aside class="warning">Bots will automatically deactivate after 30 seconds of not hearing speech.  This will trigger an <code>onDisconnect</code> event.</aside>

### deactivate()

Stop listening and disable microphone

### newCode()

Manually trigger a new code

### endCode()

Manually end current code

### Recognized Code Blue Events

| Event | Example Phrase | Extracted Data
--------- | ------- | ------- 
icrDefibrillatorSet | Defibrillator set to 300 joules | power=300, unit_power=joules
icrMedicationDelivered | 1 milligram of epinephrin delivered | dose=1, unit_dose=milligram, medication=epinephrine
icrShockDelivered | Shock delivered | 
icrEveryoneClear | We're all clear |
icrPatientInFibrillation | Still looks like it's ventricular fibrillation | state=true
icrCompressionsStarted | Back on the chest |
icrCompressionsStopped | Hold CPR | 
