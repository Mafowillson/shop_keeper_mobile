String timeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} min ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hrs ago';
  } else if (difference.inDays < 30) {
    return '${difference.inDays} days ago';
  } else {
    return dateTime.toString().split(' ')[0];
  }
}

String formatDate(DateTime dateTime) {
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}

String formatDateTime(DateTime dateTime) {
  return '${formatDate(dateTime)} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
}
