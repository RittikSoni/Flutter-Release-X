import 'dart:io';
import 'dart:convert';
import 'package:flutter_release_x/helpers/helpers.dart';
import 'package:http/http.dart' as http;

class FlutterReleaseXTeamsService {

  static Future<void> _uploadQrCodeToTeams({
    required String webhookUrl,
    required File qrFile,
    required String message,
    required String downloadLink,
  }) async {
    try {
      // Microsoft Teams doesn't support direct file uploads via webhooks
      // We need to upload the image to a publicly accessible URL first
      // For now, we'll include the image as a base64 data URI in the card
      final imageBytes = await qrFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      final imageDataUri = 'data:image/png;base64,$base64Image';

      // Create an adaptive card with the QR code image
      final card = {
        'type': 'message',
        'attachments': [
          {
            'contentType': 'application/vnd.microsoft.card.adaptive',
            'content': {
              'type': 'AdaptiveCard',
              r'$schema': 'http://adaptivecards.io/schemas/adaptive-card.json',
              'version': '1.4',
              'body': [
                {
                  'type': 'TextBlock',
                  'text': message,
                  'wrap': true,
                  'size': 'Medium',
                  'weight': 'Bolder',
                },
                {
                  'type': 'Image',
                  'url': imageDataUri,
                  'altText': 'QR Code',
                  'size': 'Medium',
                },
                if (downloadLink.isNotEmpty)
                  {
                    'type': 'ActionSet',
                    'actions': [
                      {
                        'type': 'Action.OpenUrl',
                        'title': 'Download Now',
                        'url': downloadLink,
                        'style': 'positive',
                      }
                    ]
                  }
              ]
            }
          }
        ]
      };

      final response = await http.post(
        Uri.parse(webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(card),
      );

      if (response.statusCode == 200) {
        print('✅ QR Code shared on Microsoft Teams successfully!');
      } else {
        print('⚠️ Teams webhook response: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      FlutterReleaseXHelpers.showHighlight(
        firstMessage: 'Error while uploading QR to Teams:',
        highLightmessage: e.toString(),
      );
    }
  }

  Future<void> sendLinkAndQr({
    required String webhookUrl,
    required File qrFile,
    required String message,
    required String downloadLink,
    bool? isShareQR,
    bool? isShareDownloadLink,
    List<String>? mentions,
  }) async {
    try {
      // Note: Teams webhooks don't support @mentions directly
      // We'll include user names as plain text
      final formattedMentions = mentions?.isNotEmpty == true
          ? '\n\nMentioning: ${mentions!.join(', ')}'
          : '';
      final finalMessage = '$message$formattedMentions';

      // Create adaptive card message
      final cardBody = [
        {
          'type': 'TextBlock',
          'text': finalMessage,
          'wrap': true,
          'size': 'Medium',
          'weight': 'Bolder',
        },
      ];

      // Add download button if sharing link
      if (isShareDownloadLink == true && downloadLink.isNotEmpty) {
        cardBody.add({
          'type': 'ActionSet',
          'actions': [
            {
              'type': 'Action.OpenUrl',
              'title': 'Download Now',
              'url': downloadLink,
              'style': 'positive',
            }
          ]
        });
      }

      final messageCard = {
        'type': 'message',
        'attachments': [
          {
            'contentType': 'application/vnd.microsoft.card.adaptive',
            'content': {
              'type': 'AdaptiveCard',
              r'$schema': 'http://adaptivecards.io/schemas/adaptive-card.json',
              'version': '1.4',
              'body': cardBody,
            }
          }
        ]
      };

      // Send message first
      final messageResponse = await http.post(
        Uri.parse(webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(messageCard),
      );

      if (messageResponse.statusCode == 200) {
        FlutterReleaseXHelpers.showHighlight(
          firstMessage: '✅',
          highLightmessage: 'Message sent successfully to Microsoft Teams.',
        );
      } else {
        FlutterReleaseXHelpers.showHighlight(
          firstMessage: '⚠️ Teams webhook response:',
          highLightmessage: '${messageResponse.statusCode} ${messageResponse.body}',
        );
      }

      // Send QR code separately if enabled
      if (isShareQR == true) {
        await _uploadQrCodeToTeams(
          webhookUrl: webhookUrl,
          qrFile: qrFile,
          message: 'QR Code for quick access:',
          downloadLink: downloadLink,
        );
      }
    } catch (e) {
      FlutterReleaseXHelpers.showHighlight(
        firstMessage: 'Error while sending message to Teams:',
        highLightmessage: e.toString(),
      );
    }
  }
}

