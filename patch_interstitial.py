with open('d:/real_invoice/lib/features/documents/presentation/document_editor_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import_admob = "import 'package:google_mobile_ads/google_mobile_ads.dart';\nimport '../../ads/ad_helper.dart';"
if "google_mobile_ads" not in content:
    content = import_admob + "\n" + content

# Add the ad loading logic
state_old = """class _DocumentEditorScreenState extends State<DocumentEditorScreen> {
  final _formKey = GlobalKey<FormState>();"""

state_new = """class _DocumentEditorScreenState extends State<DocumentEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  void _loadInterstitialAd() {
    final subState = context.read<SubscriptionBloc>().state;
    if (subState.plan?.isAdFree ?? false) return;

    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isAdLoaded = false;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _isAdLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }"""

if "_interstitialAd" not in content:
    content = content.replace(state_old, state_new)

# Add load to initState
init_old = """    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDefaults();
    });
  }"""
init_new = """    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDefaults();
      _loadInterstitialAd();
    });
  }"""
if "_loadInterstitialAd();" not in content:
    content = content.replace(init_old, init_new)

# Add show to save
save_old = """  Future<void> _handleSaveAndPreview() async {
    final doc = await _buildAndSaveDocument();
    if (doc != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PdfPreviewScreen(document: doc)),
      );
    }
  }"""
save_new = """  Future<void> _handleSaveAndPreview() async {
    final doc = await _buildAndSaveDocument();
    if (doc != null && mounted) {
      if (_isAdLoaded && _interstitialAd != null) {
        _interstitialAd!.show();
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PdfPreviewScreen(document: doc)),
      );
    }
  }"""
if "_interstitialAd!.show();" not in content:
    content = content.replace(save_old, save_new)

with open('d:/real_invoice/lib/features/documents/presentation/document_editor_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("document_editor_screen.dart patched with InterstitialAd")