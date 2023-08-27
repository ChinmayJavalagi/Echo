import 'package:echo/openai_service.dart';
import 'package:echo/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'feature_box.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final speechToText = SpeechToText();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  final flutterTts = FlutterTts();
  String? generatedImageUrl;
  String? generatedContent;


  void initState() {
    // TODO: implement initState
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async{
    await flutterTts.setSharedInstance(true);
    setState(() {
    });
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async{
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(child: Text("Allen")),
        leading: Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Virtual Assistant picture
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120.0,
                      width: 120.0,
                      margin: EdgeInsets.only(top:5.0),
                      decoration: BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage("assets/images/virtualAssistant.png"
                        ),
                      )
                    ),
                  ),
                ],
              ),
            ),

            //chat bubble
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 20.0,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 40.0).copyWith(top: 30.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Pallete.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(topLeft: Radius.zero,)
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      generatedContent ==  null?
                      "Good Morning, what task can I do for you?": generatedContent!,
                      style: TextStyle(
                        fontFamily: "Cera Pro",
                        color: Pallete.mainFontColor,
                        fontSize: generatedContent == null?25:18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (generatedImageUrl != null) Image.network(generatedImageUrl!),
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top:10.0, left:22),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Here are some features to try!',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: 'Cera Pro',
                    fontWeight: FontWeight.bold,
                    color: Pallete.mainFontColor,
                  ),
                ),
              ),
            ),

            //features list
            Visibility(
              visible: generatedImageUrl==null && generatedImageUrl == null,
              child: Column(
                children:[
                  FadeInLeft(delay: Duration(microseconds: 200), child: FeatureBox(color: Pallete.firstSuggestionBoxColor, headerText: 'ChatGPT', descriptionText: 'A smarter way to stay organized and informed with ChatGPT',)),
                  FadeInLeft(delay: Duration(microseconds: 600), child: FeatureBox(color: Pallete.secondSuggestionBoxColor, headerText: 'Dall-E', descriptionText: 'Get inspired and stay creative with your personal assistant powered by Dall-E',)),
                  FadeInLeft(delay: Duration(microseconds: 1000), child: FeatureBox(color: Pallete.thirdSuggestionBoxColor, headerText: 'Smart Voice Assistant', descriptionText: 'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT')),
                ],
              ),
            )

          ],
        ),
      ),
        floatingActionButton: ZoomIn(
          delay: Duration(microseconds: 1400),
          child: FloatingActionButton(
          onPressed: () async{
            if (await speechToText.hasPermission && speechToText.isNotListening){
              await startListening();
            }else if (speechToText.isListening){
              final speech = await openAIService.isArtPromptAPI(lastWords);
              if (speech.startsWith('https:')){
                generatedContent = null;
                generatedImageUrl = speech;
                setState(() {});
              }else{
                generatedContent = "Good morning boss, how was your day!";
                generatedImageUrl = null;
                await systemSpeak(generatedContent!);
                setState(() {});
              }
              await stopListening();
            }else {
              initSpeechToText();
            }
          },
          backgroundColor: Pallete.firstSuggestionBoxColor,
          child: speechToText.isListening? Icon(Icons.stop, color: Pallete.blackColor,): Icon(Icons.mic, color: Pallete.blackColor,),
      ),
        ),
    );
  }
}
