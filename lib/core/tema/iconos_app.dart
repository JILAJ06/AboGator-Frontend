import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

/// Íconos del diseño (estilo Lucide: trazo 2, esquinas redondeadas, caja 24).
///
/// Una entrada por nombre de Figma. Los marcados con "≈" no tienen
/// equivalente exacto en Lucide y usan el más cercano.
abstract final class IconosApp {
  static const IconData heart = LucideIcons.heart;

  /// ≈ `coins` (Lucide no tiene una sola moneda).
  static const IconData coin = LucideIcons.coins;
  static const IconData flame = LucideIcons.flame;
  static const IconData star = LucideIcons.star;

  /// `lightbulb` en Lucide.
  static const IconData bulb = LucideIcons.lightbulb;

  /// `house` en Lucide.
  static const IconData home = LucideIcons.house;
  static const IconData inbox = LucideIcons.inbox;
  static const IconData store = LucideIcons.store;
  static const IconData user = LucideIcons.user;
  static const IconData lock = LucideIcons.lock;
  static const IconData check = LucideIcons.check;
  static const IconData x = LucideIcons.x;
  static const IconData code = LucideIcons.code;
  static const IconData clock = LucideIcons.clock;

  /// ≈ `arrow-left`.
  static const IconData back = LucideIcons.arrowLeft;

  /// ≈ `chevron-right`.
  static const IconData chevron = LucideIcons.chevronRight;
  static const IconData settings = LucideIcons.settings;

  /// `file-text` en Lucide.
  static const IconData doc = LucideIcons.fileText;
  static const IconData trophy = LucideIcons.trophy;
  static const IconData shield = LucideIcons.shield;
  static const IconData eye = LucideIcons.eye;
  static const IconData moon = LucideIcons.moon;
  static const IconData vibrate = LucideIcons.vibrate;
  static const IconData bell = LucideIcons.bell;

  /// `log-out` en Lucide.
  static const IconData logout = LucideIcons.logOut;
  static const IconData pause = LucideIcons.pause;

  /// ≈ `refresh-cw`.
  static const IconData refresh = LucideIcons.refreshCw;
  static const IconData mail = LucideIcons.mail;
  static const IconData map = LucideIcons.map;
  static const IconData gavel = LucideIcons.gavel;
  static const IconData info = LucideIcons.info;
  static const IconData accessibility = LucideIcons.accessibility;
  static const IconData type = LucideIcons.type;
  static const IconData arrowUp = LucideIcons.arrowUp;
  static const IconData arrowDown = LucideIcons.arrowDown;
  static const IconData search = LucideIcons.search;
  static const IconData zap = LucideIcons.zap;

  /// ≈ `triangle-alert`.
  static const IconData alert = LucideIcons.triangleAlert;
  static const IconData paperclip = LucideIcons.paperclip;
  static const IconData highlighter = LucideIcons.highlighter;
  static const IconData briefcase = LucideIcons.briefcase;
  static const IconData trendingDown = LucideIcons.trendingDown;
  static const IconData building = LucideIcons.building;
  static const IconData megaphone = LucideIcons.megaphone;
  static const IconData shieldCheck = LucideIcons.shieldCheck;

  /// Extra (no está en la lista de Figma): ocultar contraseña.
  static const IconData eyeOff = LucideIcons.eyeOff;

  /// Congelar racha (Tienda, T-10).
  static const IconData snowflake = LucideIcons.snowflake;

  /// Todos los íconos de Figma con su nombre (para la galería y las pruebas).
  static const Map<String, IconData> porNombre = {
    'heart': heart,
    'coin': coin,
    'flame': flame,
    'star': star,
    'bulb': bulb,
    'home': home,
    'inbox': inbox,
    'store': store,
    'user': user,
    'lock': lock,
    'check': check,
    'x': x,
    'code': code,
    'clock': clock,
    'back': back,
    'chevron': chevron,
    'settings': settings,
    'doc': doc,
    'trophy': trophy,
    'shield': shield,
    'eye': eye,
    'moon': moon,
    'vibrate': vibrate,
    'bell': bell,
    'logout': logout,
    'pause': pause,
    'refresh': refresh,
    'mail': mail,
    'map': map,
    'gavel': gavel,
    'info': info,
    'accessibility': accessibility,
    'type': type,
    'arrow-up': arrowUp,
    'arrow-down': arrowDown,
    'search': search,
    'zap': zap,
    'alert': alert,
    'paperclip': paperclip,
    'highlighter': highlighter,
    'briefcase': briefcase,
    'trending-down': trendingDown,
    'building': building,
    'megaphone': megaphone,
    'shield-check': shieldCheck,
    'snowflake': snowflake,
  };
}
