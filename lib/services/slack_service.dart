import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_release_x/helpers/helpers.dart';

class FlutterReleaseXSlackService {
  static final dio = Dio();

  static Future<void> _uploadQrCode({
    required String slackBotToken,
    required int fileSizeInBytes,
    required File file,
    required String channelId,
    required String message,
    required String downloadLink,
  }) async {
    try {
      final response = await dio.get(
        'https://slack.com/api/files.getUploadURLExternal?filename=qr-code&length=$fileSizeInBytes',
        options: Options(
          headers: {
            'Authorization': 'Bearer $slackBotToken',
          },
        ),
      );

      final responseData = response.data;
      if (responseData['ok']) {
        final uploadUrl = responseData['upload_url'];
        final fileId = responseData['file_id'];

        final uploadResponse = await dio.post(
          uploadUrl,
          data: await file.readAsBytes(),
          options: Options(
            headers: {
              'Content-Type': 'application/octet-stream',
            },
          ),
        );

        if (uploadResponse.statusCode == 200) {
          final completeResponse = await dio.post(
            'https://slack.com/api/files.completeUploadExternal',
            options: Options(
              headers: {
                'Authorization': 'Bearer $slackBotToken',
                'Content-Type': 'application/json',
              },
            ),
            data: jsonEncode({
              'files': [
                {'id': fileId},
              ],
              'channel_id': channelId,
            }),
          );

          if (completeResponse.statusCode == 200) {
            print('QR Code shared on slack successfully!');
          } else {
            print('Something went wrong ${completeResponse.data}');
          }
        }
      }
    } catch (e) {
      FlutterReleaseXHelpers.showHighlight(
        firstMessage: 'Error while uploading QR to slack:',
        highLightmessage: e.toString(),
      );
      exit(0);
    }
  }

  Future<void> sendLinkAndQr({
    required String slackBotToken,
    required int fileSizeInBytes,
    required File file,
    required String channelId,
    required String message,
    required String downloadLink,
    bool? isShareQR,
    bool? isShareDownloadLink,
    List<String>? mentions,
  }) async {
    if (isShareQR == true) {
      await _uploadQrCode(
        slackBotToken: slackBotToken,
        fileSizeInBytes: fileSizeInBytes,
        file: file,
        channelId: channelId,
        message: message,
        downloadLink: downloadLink,
      );
    }
    try {
      // Step 4: Send the message with link and mentions
      final formattedMentions = mentions?.map((id) => '<@$id>').join(' ') ?? '';
      final finalMessage = '$message\n$formattedMentions';

      final messageResponse = await dio.post(
        'https://slack.com/api/chat.postMessage',
        options: Options(
          headers: {
            'Authorization': 'Bearer $slackBotToken',
            'Content-Type': 'application/json',
          },
        ),
        data: jsonEncode(
          {
            'channel': channelId,
            'text':
                '$finalMessage ${isShareDownloadLink == true ? "<$downloadLink|Download>" : ""}',
            'blocks': [
              {
                "type": "section",
                "text": {
                  "type": "mrkdwn",
                  "text":
                      "🚀 *$finalMessage ${isShareDownloadLink == true ? "<$downloadLink|Download>" : ""}*"
                }
              },
              if (isShareDownloadLink == true)
                {
                  "type": "actions",
                  "elements": [
                    {
                      "type": "button",
                      "text": {"type": "plain_text", "text": "Download Now"},
                      "style": "primary",
                      "url": downloadLink.toString()
                    }
                  ]
                }
            ]
          },
        ),
      );

      if (messageResponse.data['ok']) {
        FlutterReleaseXHelpers.highlight('Message sent successfully to Slack.');
      } else {
        FlutterReleaseXHelpers.showHighlight(
          firstMessage: 'Error sending message:',
          highLightmessage: messageResponse.data['error'].toString(),
        );
      }
    } catch (e) {
      FlutterReleaseXHelpers.showHighlight(
        firstMessage: 'Error while uploading QR to slack:',
        highLightmessage: e.toString(),
      );
      exit(0);
    }
  }
}
