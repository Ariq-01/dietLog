class ChatMessages {

  final String text;
  final bool isUser;
  final bool isLoading;

  ChatMessages({
    required this.text,
    this.isUser = false,
    this.isLoading = false,
  });
}