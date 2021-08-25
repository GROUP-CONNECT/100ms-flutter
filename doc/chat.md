# Chat

What's a video without being able to send messages to each other too? 100ms supports chat for every video/audio room you create.

You can see an example of every way of sending messages and interpreting messages in the advanced sample app.

```dart 
    HMSMeeting meeting = new HMSMeeting();
    meeting.sendMessage("HI");
```

You will get updates about message sent by someone in HMSUpdateListener.

```dart
    void onMessage({required HMSMessage message});
```