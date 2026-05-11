import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;

  final List<Map<String, dynamic>> messages = [
    {
      'role': 'assistant',
      'message': 'Hello! I\'m your ShopKeeper AI Assistant. I can help you with business insights, inventory analysis, and sales recommendations. What would you like to know?',
      'timestamp': '10:30 AM'
    },
    {
      'role': 'user',
      'message': 'What are my top selling products this week?',
      'timestamp': '10:31 AM'
    },
    {
      'role': 'assistant',
      'message': 'Based on your sales data this week:\n\n1. Coca Cola 500ml - 45 units sold (FCFA 67,500)\n2. Lay\'s Chips 50g - 38 units sold (FCFA 76,000)\n3. Dettol Disinfectant 500ml - 12 units sold (FCFA 42,000)\n\nYour beverage category is performing 23% better than last week!',
      'timestamp': '10:31 AM'
    },
    {
      'role': 'user',
      'message': 'Should I restock any products?',
      'timestamp': '10:32 AM'
    },
    {
      'role': 'assistant',
      'message': 'Yes, I recommend restocking:\n\n⚠️ URGENT:\n- Fanta Orange 500ml (3 units left, min: 20)\n- Milk 1L (8 units left, min: 15)\n\n📊 SOON:\n- Sprite 500ml (12 units, min: 20)\n\nBased on your sales velocity, Fanta will run out in 2-3 days.',
      'timestamp': '10:32 AM'
    },
  ];

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        'role': 'user',
        'message': _messageController.text,
        'timestamp': 'Now'
      });
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        messages.add({
          'role': 'assistant',
          'message': 'That\'s a great question! Based on your current inventory and sales trends, I\'d recommend focusing on your high-margin products. Would you like me to provide more specific recommendations?',
          'timestamp': 'Now'
        });
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat Assistant'),
        backgroundColor: AppColors.ownerPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Start New Chat'),
                  content: const Text('Clear all messages and start a new conversation?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          messages.clear();
                          messages.add({
                            'role': 'assistant',
                            'message': 'Hello! I\'m your ShopKeeper AI Assistant. How can I help you today?',
                            'timestamp': 'Now'
                          });
                        });
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: () {},
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.ownerPrimary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['role'] == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: AppColors.accent,
                ),
              ),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppColors.ownerPrimary : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['message'],
                    style: AppTextStyles.bodyM.copyWith(
                      color: isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message['timestamp'],
                    style: AppTextStyles.bodyM.copyWith(
                      fontSize: 10,
                      color: isUser ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.ownerPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  size: 18,
                  color: AppColors.ownerPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
