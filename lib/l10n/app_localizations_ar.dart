// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'راوتر كوماندر AI';

  @override
  String get dashboard => 'الرئيسية';

  @override
  String get routers => 'الراوترات';

  @override
  String get tools => 'الأدوات';

  @override
  String get ai => 'الذكاء';

  @override
  String get settings => 'الإعدادات';

  @override
  String get dashboardTitle => 'مركز قيادة الشبكة';

  @override
  String get dashboardSubtitle =>
      'أساس منظم لإدارة الراوترات والتشخيصات ورؤى الأمان والمساعدة الذكية.';

  @override
  String get commandCenterTitle => 'راوتر كوماندر AI';

  @override
  String get commandCenterSubtitle =>
      'هيكل Sprint 1 جاهز مع التنقل والترجمة والتخطيط المتجاوب ونظام الثيمات الإنتاجي.';

  @override
  String get routerStatus => 'حالة الراوتر';

  @override
  String get noRouterConnected => 'لا يوجد راوتر متصل';

  @override
  String get wifiHealth => 'صحة الواي فاي';

  @override
  String get awaitingNetworkScan => 'بانتظار الفحص';

  @override
  String get security => 'الأمان';

  @override
  String get baselineReady => 'الأساس جاهز';

  @override
  String get speedTest => 'اختبار السرعة';

  @override
  String get notMeasured => 'لم يتم القياس';

  @override
  String get foundationReadyTitle => 'الأساس جاهز';

  @override
  String get foundationReadyMessage =>
      'التطبيق يملك الآن هيكلا قابلا للتوسع حسب المزايا. تم استبعاد الاتصال بالراوتر عمدا من Sprint 1.';

  @override
  String get routersTitle => 'ملفات الراوترات';

  @override
  String get routersSubtitle =>
      'ستتم إدارة الراوترات المحفوظة من هذه المساحة عند إضافة وحدات الاتصال.';

  @override
  String get routersEmptyTitle => 'لا توجد ملفات راوتر';

  @override
  String get routersEmptyMessage =>
      'هذا الأساس يفصل تخزين الملفات وسير الاتصال عن واجهة المستخدم.';

  @override
  String get toolsTitle => 'أدوات الشبكة';

  @override
  String get toolsSubtitle =>
      'تم تنظيم التشخيصات حسب الميزة حتى تنمو كل أداة بشكل مستقل.';

  @override
  String get wifi => 'واي فاي';

  @override
  String get connectedDevices => 'الأجهزة المتصلة';

  @override
  String get dsl => 'DSL';

  @override
  String get toolReady => 'الوحدة جاهزة';

  @override
  String get aiAssistantTitle => 'المساعد الذكي';

  @override
  String get aiAssistantSubtitle =>
      'تم تجهيز مساحة المساعد للإرشاد والشرح وسير استكشاف المشاكل مستقبلا.';

  @override
  String get aiEmptyTitle => 'مساحة المساعد';

  @override
  String get aiEmptyMessage =>
      'يحجز الأساس هذه المساحة دون إضافة ذكاء اصطناعي أو اتصال بالراوتر في Sprint 1.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSubtitle => 'تحكم في مظهر التطبيق واللغة فورا.';

  @override
  String get appearance => 'المظهر';

  @override
  String get theme => 'الثيم';

  @override
  String get systemTheme => 'النظام';

  @override
  String get lightTheme => 'فاتح';

  @override
  String get darkTheme => 'داكن';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get wanIp => 'عنوان WAN IP';

  @override
  String get wanIpNotAvailable => 'غير متوفر';

  @override
  String get connected => 'متصل';

  @override
  String get connecting => 'جاري الاتصال...';

  @override
  String get connectionFailed => 'فشل الاتصال';

  @override
  String get uptime => 'مدة التشغيل';

  @override
  String get activeDevices => 'الأجهزة النشطة';

  @override
  String get dashboardEmptyStateMessage =>
      'يرجى الاتصال بجهاز راوتر من علامة تبويب الراوترات لعرض الإحصائيات الحية.';

  @override
  String get addRouterTitle => 'إضافة راوتر';

  @override
  String get routerNameLabel => 'اسم الراوتر';

  @override
  String get ipAddressLabel => 'عنوان IP';

  @override
  String get usernameLabel => 'اسم المستخدم';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get saveAndConnect => 'حفظ واتصال';

  @override
  String get connect => 'اتصال';
}
