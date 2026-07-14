import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import 'widgets/home_audience_paths.dart';
import 'widgets/home_hero.dart';
import 'widgets/home_recent_verified.dart';
import 'widgets/home_stages.dart';
import 'widgets/home_stats.dart';
import 'widgets/sotongware_banner.dart';

/// 소통AI스토리 서비스 시작 페이지.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeHero(),
          const SizedBox(height: 32),
          HomeStats(stats: repository.stats),
          const SizedBox(height: 32),
          const HomeStages(),
          const SizedBox(height: 32),
          const HomeAudiencePaths(),
          const SizedBox(height: 32),
          HomeRecentVerified(entries: repository.recentlyVerifiedTimeline),
          const SizedBox(height: 32),
          const SotongwareBanner(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
