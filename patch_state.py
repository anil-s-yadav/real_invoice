import re

with open('d:/real_invoice/lib/features/documents/presentation/document_editor_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

ad_code = """
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
  }
"""

content = re.sub(
    r'(class _DocumentEditorScreenState extends State<DocumentEditorScreen> \{)',
    r'\1' + ad_code,
    content,
    count=1
)

with open('d:/real_invoice/lib/features/documents/presentation/document_editor_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("document_editor_screen.dart patched correctly")