//Dart imports
import 'dart:async';

//Package imports
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import 'package:package_info_plus/package_info_plus.dart';

//Project imports
import 'package:hmssdk_flutter_example/common/constant.dart';
import 'package:hmssdk_flutter_example/common/ui/organisms/user_name_dialog_organism.dart';
import 'package:hmssdk_flutter_example/enum/meeting_flow.dart';
import 'package:hmssdk_flutter_example/meeting/meeting_store.dart';
import 'package:hmssdk_flutter_example/preview/preview_page.dart';
import 'package:hmssdk_flutter_example/service/deeplink_service.dart';
import 'package:input_history_text_field/input_history_text_field.dart';
import './logs/custom_singleton_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  Wakelock.enable();
  Provider.debugCheckInvalidValueType = null;
  runZonedGuarded(
      () => runApp(HMSExampleApp()), FirebaseCrashlytics.instance.recordError);
}

class HMSExampleApp extends StatelessWidget {
  const HMSExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController roomIdController =
      TextEditingController(text: Constant.defaultRoomID);
  CustomLogger logger = CustomLogger();
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  void getPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();

    while ((await Permission.camera.isDenied)) {
      await Permission.camera.request();
    }
    while ((await Permission.microphone.isDenied)) {
      await Permission.microphone.request();
    }
  }

  @override
  void initState() {
    super.initState();
    logger.getCustomLogger();
    getPermissions();
    _initPackageInfo();
  }

  Future<bool> _closeApp() {
    CustomLogger.file?.delete();
    return Future.value(true);
  }

  DeepLinkBloc _bloc = DeepLinkBloc();

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  void setRTMPUrl(String roomUrl) {
    List<String> urlSplit = roomUrl.split('/');
    int index = urlSplit.lastIndexOf("meeting");
    if (index != -1) {
      urlSplit[index] = "preview";
    }
    Constant.rtmpUrl = urlSplit.join('/') + "?token=beam_recording";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _closeApp,
      child: Scaffold(
          appBar: AppBar(
            title: Text('100ms'),
          ),
          body: Provider<DeepLinkBloc>(
            create: (context) => _bloc,
            dispose: (context, bloc) => bloc.dispose(),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Join a Meeting',
                          style: TextStyle(
                              height: 1,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 8,
                      ),
                      StreamBuilder(
                          stream: _bloc.state,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data is String) {
                              var url = snapshot.data as String;
                              if (url.isNotEmpty) {
                                roomIdController.text = url;
                              }
                            }
                            return InputHistoryTextField(
                              historyKey: "key-01",
                              textEditingController: roomIdController,
                              enableOpacityGradient: true,
                              autofocus: true,
                              keyboardType: TextInputType.url,
                              decoration: InputDecoration(
                                  hintText: 'Enter Room URL',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(16)))),
                            );
                          }),
                      SizedBox(
                        height: 8,
                      ),
                      ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ))),
                          onPressed: () async {
                            setRTMPUrl(roomIdController.text);
                            String user = await showDialog(
                                context: context,
                                builder: (_) => UserNameDialogOrganism());
                            if (user.isNotEmpty)
                              FocusManager.instance.primaryFocus?.unfocus();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) =>
                                      ListenableProvider<MeetingStore>(
                                        create: (ctx) => MeetingStore(),
                                        child: PreviewPage(
                                          roomId: roomIdController.text,
                                          user: user,
                                          flow: MeetingFlow.join,
                                        ),
                                      )));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.video_call_outlined, size: 48),
                                SizedBox(
                                  width: 8,
                                ),
                                Text('Join Meeting',
                                    style: TextStyle(height: 1, fontSize: 24))
                              ],
                            ),
                          )),
                      SizedBox(
                        height: 50.0,
                      ),
                      Container(
                        child: Text("Version: ${_packageInfo.version}"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
