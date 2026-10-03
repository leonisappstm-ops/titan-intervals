import 'package:flutter/material.dart';

class SoundScheme {
  final String id;
  final String name;
  final String description;
  final String acousticTag;
  final IconData icon;

  const SoundScheme({
    required this.id,
    required this.name,
    required this.description,
    required this.acousticTag,
    required this.icon,
  });

  static const List<SoundScheme> all = [
    SoundScheme(
      id: 'titan_impact',
      name: 'Titan Impact',
      description: 'Punchy dual-tone synth beeps & triumphant victory brass',
      acousticTag: 'SYNTH / HIGH ENERGY',
      icon: Icons.bolt_rounded,
    ),
    SoundScheme(
      id: 'arcade_retro',
      name: 'Arcade 8-Bit',
      description: 'Classic chiptune arpeggios & retro gaming alerts',
      acousticTag: '8-BIT / RETRO GAMING',
      icon: Icons.videogame_asset_rounded,
    ),
    SoundScheme(
      id: 'boxing_bell',
      name: 'Gym Boxing Bell',
      description: 'Authentic metallic ring bell strikes & resonant deep gong',
      acousticTag: 'METALLIC / BOXING RING',
      icon: Icons.notifications_active_rounded,
    ),
    SoundScheme(
      id: 'zen_harmony',
      name: 'Zen Harmony',
      description: 'Harmonic 528Hz crystal chimes & soothing Tibetan bowls',
      acousticTag: 'ACOUSTIC / YOGA & CORE',
      icon: Icons.self_improvement_rounded,
    ),
    SoundScheme(
      id: 'military_drill',
      name: 'Military Drill',
      description: 'High-frequency tactical command beeps & bugle call',
      acousticTag: 'TACTICAL / ULTRA SHARP',
      icon: Icons.campaign_rounded,
    ),
  ];

  static SoundScheme get defaultScheme => all.first;

  static SoundScheme fromId(String id) {
    return all.firstWhere((s) => s.id == id, orElse: () => defaultScheme);
  }
}
