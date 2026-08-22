# تقرير المراجعة النهائي — LocalSend Stream & Browse

**المشروع:** [Romany-Osama/localsend](https://github.com/Romany-Osama/localsend)  
**الفرع:** `stream-browse`  
**الإصدار المنشور:** [`v1.18.2-stream.9`](https://github.com/Romany-Osama/localsend/releases/tag/v1.18.2-stream.9)  
**آخر commit:** `118750f3`  
**GitHub Actions run:** [`32571134752`](https://github.com/Romany-Osama/localsend/actions/runs/32571134752)

## الخلاصة التنفيذية

تمت مراجعة مسار Stream & Browse في Rust وFlutter، ثم أُضيف اختبار تكاملي محلي يغطي دورة الجلسة والملف كاملة. النتيجة: **Stream & Browse لا يرفع الملفات إلى خادم سحابي ولا يستخدم WebSocket أو signaling أو STUN**؛ العميل يتصل مباشرةً بعنوان IP والمنفذ اللذين يعلنهما جهاز LocalSend الآخر عبر الاكتشاف المحلي، ويستقبل المحتوى من خادم HTTP المحلي على الجهاز المصدر.

تم اكتشاف وإصلاح أربع نقاط أثناء المراجعة: انتهاء صلاحية الجلسة أصبح مفروضًا فعليًا بدل أن يكون قيمة تُعاد للعميل فقط، انتظار موافقة الجلسة والملف أصبح محدودًا بمهلة، الملفات الفارغة أصبحت تُرسل بطول `0` صحيح، وإعادة تشغيل خادم LocalSend أصبحت تحتفظ بالمجلدات المختارة لـ Stream & Browse. كما أضيف اختبار رفض مستقل يثبت أن رفض الجلسة أو الملف يعيد `403` ولا ينشئ وصولًا.

## ما تم التحقق منه

| المجال | النتيجة | الدليل |
|---|---|---|
| اتصال Stream & Browse وقت التشغيل | LAN/direct-IP فقط داخل المسار الجديد | `stream_browse_client.dart` يبني URL من جهاز LocalSend المكتشف، ولا توجد روابط cloud أو signaling في المسار |
| موافقة الجلسة | ناجحة | الطلب يبقى معلقًا حتى إرسال قرار صريح، والرفض يعيد `403` |
| موافقة الملف | ناجحة | كل `file-request` ينتظر قرارًا منفصلًا، والرفض لا ينشئ grant |
| حماية المسار | ناجحة في الاختبار | `../` وpath traversal يعيدان `403`، والمسار يُحل بعد `canonicalize` مع فحص root boundary |
| البث الجزئي | ناجح | HTTP `Range: bytes=1-3` يعيد `206` وثلاثة bytes صحيحة |
| الملف الفارغ | ناجح بعد الإصلاح | الاستجابة تعلن `Content-Length: 0` ولا تنتج byte وهميًا |
| Revoke | ناجح | بعد revoke تصبح الجلسة غير صالحة وتعيد endpoints المحمية `403` |
| Rust compilation | ناجح | `cargo check --features http` |
| Rust unit tests | ناجحة | 5 اختبارات Range/path traversal |
| Rust integration tests | ناجحة | اختبارا approval/stream/revoke والرفض، إجمالي 2 tests |

## معنى LAN-only بدقة

> **LAN-only هنا تعني أن Stream & Browse وقت التشغيل ينقل البيانات مباشرة بين الجهازين عبر عنوان LAN المكتشف، دون cloud upload أو download.**

هذا لا يعني أن كل ما يتعلق بالمشروع يعمل دون Internet في كل الظروف. عملية البناء نفسها تحتاج تنزيل Flutter وRust وDart dependencies، وهذا أمر خاص بالـ CI وليس نقل الملفات وقت تشغيل التطبيق. كذلك يحتوي LocalSend الأصلي على مسار WebRTC/signaling اختياري له إعدادات عامة، لكنه في هذا الكود معطّل صراحةً (`webRTCEnabled = false`) وليس جزءًا من Stream & Browse. كما أن توفر الشبكة الخلوية أو VPN لا يحوّل Stream & Browse إلى cloud؛ مع ذلك، الخادم الأساسي يستمع على wildcard interfaces مثل LocalSend الأصلي، ولذلك فإن منع الوصول من خارج الشبكة يعتمد أيضًا على firewall وVPN وport-forwarding في نظام المستخدم.

## المنصات المنشورة

| المنصة | الأصول في Release | الحالة | ملاحظات التثبيت |
|---|---|---|---|
| Android | `armeabi-v7a`, `arm64-v8a`, `x86_64` APK | **Build ناجح** | APKs موقعة بمفتاح CI تجريبي مؤقت؛ ليست مفتاح تحديث إنتاجي دائم |
| Windows x64 | Installer `.exe` وPortable `.zip` | **Build ناجح** | غير موقّعين بشهادة تجارية، وقد يعرض Windows SmartScreen تحذيرًا |
| Linux x64 | `.tar.gz`, `.deb`, `.AppImage` | **Build ناجح** | AppImage وDebian package متاحان للأنظمة المعتادة x64 |
| Linux arm64 | `.tar.gz`, `.deb` | **Build ناجح** | مناسب لأجهزة Linux ARM64؛ لا يوجد AppImage arm64 في هذا الإصدار |
| macOS | unsigned `.zip` يحتوي `.app` | **Build ناجح** | يحتاج توقيعًا/notarization تجاريًا لتوزيع مريح بدون تحذيرات Gatekeeper |
| iOS | unsigned `.app.zip` | **Build ناجح** | ليس IPA قابلًا للتثبيت مباشرة؛ يحتاج Apple Developer signing وprovisioning profile أو إعادة بناء محلية من Xcode |

أُصلحت أثناء البناء مشاكل platform-specific فعلية: إضافة `libmpv-dev` لـ Linux، تصحيح تشغيل `flutter_distributor` من مجلد `app`، تثبيت `connectivity_plus` و`device_info_plus` على نسخ متوافقة مع SDK runner، تعطيل cache المسبب لفشل post-cleanup في GitHub Actions، وتمرير إعدادات unsigned إلى macOS CI. تفاصيل الأسماء والأحجام موجودة في صفحة الإصدار نفسها.[1]

## ملفات الإصدار

| الملف | الاستخدام |
|---|---|
| [`LocalSend-v1.18.2-stream.9-android-arm64.apk`](https://github.com/Romany-Osama/localsend/releases/download/v1.18.2-stream.9/LocalSend-v1.18.2-stream.9-android-arm64.apk) | أغلب أجهزة Android الحديثة |
| [`LocalSend-v1.18.2-stream.9-android-armeabi-v7a.apk`](https://github.com/Romany-Osama/localsend/releases/download/v1.18.2-stream.9/LocalSend-v1.18.2-stream.9-android-armeabi-v7a.apk) | أجهزة Android ARM32 الأقدم |
| [`LocalSend-v1.18.2-stream.9-android-x86_64.apk`](https://github.com/Romany-Osama/localsend/releases/download/v1.18.2-stream.9/LocalSend-v1.18.2-stream.9-android-x86_64.apk) | Android x86_64/emulators |
| [`LocalSend-v1.18.2-stream.9-windows-x64.exe`](https://github.com/Romany-Osama/localsend/releases/download/v1.18.2-stream.9/LocalSend-v1.18.2-stream.9-windows-x64.exe) | Windows installer |
| [`LocalSend-v1.18.2-stream.9-windows-x64-portable.zip`](https://github.com/Romany-Osama/localsend/releases/download/v1.18.2-stream.9/LocalSend-v1.18.2-stream.9-windows-x64-portable.zip) | Windows بدون تثبيت |
| [`LocalSend-v1.18.2-stream.9-linux-x64.AppImage`](https://github.com/Romany-Osama/localsend/releases/download/v1.18.2-stream.9/LocalSend-v1.18.2-stream.9-linux-x64.AppImage) | Linux x64 portable |
| [`LocalSend-v1.18.2-stream.9-linux-x64.deb`](https://github.com/Romany-Osama/localsend/releases/download/v1.18.2-stream.9/LocalSend-v1.18.2-stream.9-linux-x64.deb) | Debian/Ubuntu x64 |
| [`LocalSend-v1.18.2-stream.9-linux-x64.tar.gz`](https://github.com/Romany-Osama/localsend/releases/download/v1.18.2-stream.9/LocalSend-v1.18.2-stream.9-linux-x64.tar.gz) | Linux x64 bundle |
| [`LocalSend-v1.18.2-stream.9-linux-arm64.deb`](https://github.com/Romany-Osama/localsend/releases/download/v1.18.2-stream.9/LocalSend-v1.18.2-stream.9-linux-arm64.deb) | Debian/Ubuntu ARM64 |
| [`LocalSend-v1.18.2-stream.9-linux-arm64.tar.gz`](https://github.com/Romany-Osama/localsend/releases/download/v1.18.2-stream.9/LocalSend-v1.18.2-stream.9-linux-arm64.tar.gz) | Linux ARM64 bundle |
| [`LocalSend-v1.18.2-stream.9-macos-unsigned.zip`](https://github.com/Romany-Osama/localsend/releases/download/v1.18.2-stream.9/LocalSend-v1.18.2-stream.9-macos-unsigned.zip) | macOS unsigned app |
| [`LocalSend-v1.18.2-stream.9-ios-unsigned.app.zip`](https://github.com/Romany-Osama/localsend/releases/download/v1.18.2-stream.9/LocalSend-v1.18.2-stream.9-ios-unsigned.app.zip) | iOS unsigned app for signing/Xcode |

## ما لم يتم إثباته داخل sandbox

لم يتم تشغيل APK أو EXE أو Linux/macOS/iOS على أجهزة فعلية داخل هذه البيئة، ولم يتم تنفيذ packet capture على شبكة منزلية حقيقية. لذلك تم إثبات البناء والترجمة واختبارات HTTP المحلية، وليس تجربة تشغيل فيديو طويلة بين هاتف وكمبيوتر حقيقيين. قبل الاعتماد اليومي، يجب اختبار اكتشاف الأجهزة على نفس Wi‑Fi، فتح مجلد، رفض/قبول الطلب، تشغيل ملف كبير مع seek، ثم فصل الجهاز أثناء البث.

على iOS تحديدًا، الأرشيف المنشور unsigned لأسباب Apple؛ لا يمكن اعتبار ملف `.app.zip` نسخة App Store أو TestFlight جاهزة دون حساب Apple Developer وشهادة provisioning. أما macOS فيُبنى بنجاح لكنه unsigned، ولذلك يلزم توقيعه/notarize لتوزيع احترافي.

## المراجع

[1]: https://github.com/Romany-Osama/localsend/releases/tag/v1.18.2-stream.9 "LocalSend Stream & Browse v1.18.2-stream.9 Release"
[2]: https://github.com/Romany-Osama/localsend/actions/runs/32571134752 "Successful full-platform GitHub Actions run"
[3]: https://pub.dev/packages/connectivity_plus/changelog "connectivity_plus official changelog"
[4]: https://pub.dev/packages/in_app_purchase/changelog "in_app_purchase official changelog"
