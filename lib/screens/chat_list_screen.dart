import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_user.dart';
import '../widgets/common_widgets.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
@override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ChatProvider>().listenToUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final users = chatProvider.users;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: ListView(
        children: [
          // Group chat tile
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.accent,
              child: const Icon(Icons.groups_rounded, color: Colors.white),
            ),
            title: const Text('Team Group Chat',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Everyone in the company'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    chatId: chatProvider.groupChatId,
                    title: 'Team Group Chat',
                    isGroup: true,
                    participants: const [], // group: all users, handled server-side via rules if needed
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1),
          // 1-on-1 chats
          if (users.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ...users.map((user) => _UserTile(user: user)),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final ChatUser user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.read<ChatProvider>();
    final chatId = chatProvider.getDmChatId(user.uid);
    final currentUid = chatProvider.currentUid;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.accent.withValues(alpha: 0.15),
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: const TextStyle(
              color: AppColors.accent, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(user.role == 'admin' ? 'Admin' : user.email,
          style: const TextStyle(fontSize: 12)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: chatId,
              title: user.name,
              isGroup: false,
              participants: [currentUid, user.uid],
            ),
          ),
        );
      },
    );
  }
}