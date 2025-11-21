import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  final String fromEmail = 'your_email@gmail.com';
  final String password = 'your_password';

  Future<void> sendEmail({required String subject, required String body}) async {
    final smtpServer = gmail(fromEmail, password);
    final message = Message()
      ..from = Address(fromEmail, 'BabyShopHub')
      ..recipients.add(fromEmail) // admin receives notifications
      ..subject = subject
      ..text = body;

    try {
      final sendReport = await send(message, smtpServer);
      print('Email sent: $sendReport');
    } catch (e) {
      print('Email not sent: $e');
    }
  }
}
