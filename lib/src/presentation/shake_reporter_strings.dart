class ShakeReporterStrings {
  const ShakeReporterStrings({
    this.shakeReporterSheetTitle = 'Report an Issue',
    this.shakeReporterSheetSubtitle = 'Shake to trigger',
    this.shakeReporterSubmitSuccess = 'Report submitted. Thank you.',
    this.shakeReporterSubmitQueued = 'Saved locally. Will retry automatically.',
    this.shakeReporterTitleLabel = 'Title *',
    this.shakeReporterTitleHint = 'Brief description of the issue',
    this.shakeReporterDescriptionLabel = 'Description',
    this.shakeReporterDescriptionHint = 'Steps to reproduce (optional)',
    this.shakeReporterSubmitButton = 'Submit Report',
    this.shakeReporterScreenshotLabel = 'Screenshot',
    this.shakeReporterNoScreenshot = 'No screenshot available',
  });

  const ShakeReporterStrings.arabic({
    this.shakeReporterSheetTitle = 'الإبلاغ عن مشكلة',
    this.shakeReporterSheetSubtitle = 'هز الجهاز للتشغيل',
    this.shakeReporterSubmitSuccess = 'تم إرسال البلاغ. شكرًا لك.',
    this.shakeReporterSubmitQueued =
        'تم الحفظ محليًا وسيتم إعادة المحاولة تلقائيًا.',
    this.shakeReporterTitleLabel = 'العنوان *',
    this.shakeReporterTitleHint = 'وصف مختصر للمشكلة',
    this.shakeReporterDescriptionLabel = 'الوصف',
    this.shakeReporterDescriptionHint = 'خطوات إعادة المشكلة (اختياري)',
    this.shakeReporterSubmitButton = 'إرسال البلاغ',
    this.shakeReporterScreenshotLabel = 'لقطة الشاشة',
    this.shakeReporterNoScreenshot = 'لا توجد لقطة شاشة متاحة',
  });

  final String shakeReporterSheetTitle;
  final String shakeReporterSheetSubtitle;
  final String shakeReporterSubmitSuccess;
  final String shakeReporterSubmitQueued;
  final String shakeReporterTitleLabel;
  final String shakeReporterTitleHint;
  final String shakeReporterDescriptionLabel;
  final String shakeReporterDescriptionHint;
  final String shakeReporterSubmitButton;
  final String shakeReporterScreenshotLabel;
  final String shakeReporterNoScreenshot;
}
