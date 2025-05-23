import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ui/constants/routes.dart';
import 'package:ui/controllers/auth_controllers/auth_methods.dart';
import 'package:ui/controllers/channel_controller/channel_controller.dart';
import 'package:ui/models/Channel/Channel.dart';
import 'package:ui/models/Video/video.model.dart';

import '../../models/User/user.dart';

class ChannelDetailsPage extends StatefulWidget {
  static const route_name = channel_details;
  final String? channelName;
  const ChannelDetailsPage({super.key, this.channelName});
  @override
  State<ChannelDetailsPage> createState() => _ChannelDetailsPageState();
}

class _ChannelDetailsPageState extends State<ChannelDetailsPage> {
  late final User user;
  late final Channel channel;
  final ChannelController controller = Get.put(ChannelController());

  @override
  void initState() {
    // TODO: implement initState
    final AuthController a = Get.find();
    user = a.user.value;
    super.initState();
  }

  Future<void> fetchChannelDetails() async {
    final String channelName;
    if (widget.channelName != null) {
      channelName = widget.channelName!;
    } else {
      channelName = user.userName;
    }
    channel = (await controller.getChannelDetails(channelName, context))!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: fetchChannelDetails(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Image
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    channel.coverImage!,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) =>
                            const Center(child: Icon(Icons.broken_image)),
                  ),
                ),

                const SizedBox(height: 16),

                // Avatar & Name (below cover image now)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(channel.avatar!),
                        onBackgroundImageError:
                            (_, __) => const Icon(Icons.person),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          channel.channelName!,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Email
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.email, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        channel.email!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildStatCard(
                        'Subscribers',
                        channel.nSubscribers!.toString(),
                        Icons.people,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        'Subscribed',
                        channel.nSubscribed!.toString(),
                        Icons.subscriptions,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Your watch history!"),
                ),

                const SizedBox(height: 32),

                FutureBuilder<List<Video>>(
                  future: controller.getUserWatchistory(context),
                  builder: (_, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snap.hasData || snap.data!.isEmpty) {
                      return const Center(child: Text('No videos watched yet!'));
                    }

                    List<Video> videos = snap.data!;
                    return ListView.builder(
                      itemCount: videos.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final video = videos[index];
                        log(video.toString());

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                   video.thumbNail!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(video.owner?.avatar ?? ''),
                                    onBackgroundImageError: (_, __) {},
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          video.title ?? 'Untitled',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          video.owner?.fullName ?? 'Unknown',
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String count, IconData icon) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          child: Column(
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 8),
              Text(
                count,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
