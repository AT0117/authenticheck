import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import '../services/scraper_service.dart';
import '../services/llm_service.dart';
import '../models/authenticity_result.dart';
import '../theme/brutalist_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StreamSubscription _intentSubscription;
  final _urlController = TextEditingController();
  
  bool _isLoading = false;
  String _loadingMessage = '';
  AuthenticityResult? _result;
  String? _error;

  final ScraperService _scraperService = ScraperService();
  final LlmService _llmService = LlmService();

  @override
  void initState() {
    super.initState();
    _initSharingIntent();
  }

  void _initSharingIntent() {
    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSubscription = FlutterSharingIntent.instance.getMediaStream().listen((List<SharedFile> value) {
      if (value.isNotEmpty) {
        final sharedString = value.first.value; // Usually URL is in value for text sharing
        if (sharedString != null) _handleIncomingUrl(sharedString);
      }
    }, onError: (err) {
      debugPrint("getLinkStream error: $err");
    });

    // Get the media sharing coming from outside the app while the app is closed.
    FlutterSharingIntent.instance.getInitialSharing().then((List<SharedFile> value) {
      if (value.isNotEmpty) {
        final sharedString = value.first.value;
        if (sharedString != null) _handleIncomingUrl(sharedString);
      }
    });
  }

  @override
  void dispose() {
    _intentSubscription.cancel();
    _urlController.dispose();
    super.dispose();
  }

  void _handleIncomingUrl(String url) {
    if (url.startsWith('http')) {
      _urlController.text = url;
      _analyzeUrl(url);
    }
  }

  Future<void> _analyzeUrl(String url) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
      _loadingMessage = '> Initializing intercept sequence...';
    });

    try {
      // Small delay for brutalist terminal effect
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _loadingMessage = '> Fetching data from ScraperAPI...';
      });
      final scrapedText = await _scraperService.scrapeProduct(url);
      
      setState(() {
        _loadingMessage = '> Raw data acquired.\n> Executing LLM heuristic analysis...';
      });
      
      final result = await _llmService.analyzeProduct(scrapedText);
      
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(BrutalistTheme.neonGreen),
            strokeWidth: 2,
          ),
          const SizedBox(height: 24),
          Text(
            _loadingMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'Roboto Mono',
              color: BrutalistTheme.neonGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(AuthenticityResult result) {
    final bool isSafe = result.authenticityScore >= 70;
    final Color scoreColor = isSafe ? BrutalistTheme.neonGreen : BrutalistTheme.neonRed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    'AUTHENTICITY_SCORE',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Roboto Mono',
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${result.authenticityScore}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: scoreColor,
                      fontSize: 80,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    color: scoreColor.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      result.verdict.toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: scoreColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRICE_ANOMALY',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Roboto Mono',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.priceAnomaly ? 'DETECTED' : 'NORMAL',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: result.priceAnomaly ? BrutalistTheme.neonRed : BrutalistTheme.neonGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RISK_FACTORS',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Roboto Mono',
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (result.riskFactors.isEmpty)
                    const Text('NONE DETECTED', style: TextStyle(color: BrutalistTheme.neonGreen)),
                  for (var factor in result.riskFactors)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('> ', style: TextStyle(color: BrutalistTheme.neonRed)),
                          Expanded(child: Text(factor)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _result = null;
                _urlController.clear();
              });
            },
            child: const Text('SCAN_ANOTHER_URL'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.security, size: 64, color: BrutalistTheme.textLight),
          const SizedBox(height: 24),
          Text(
            'Share a link from Amazon/Flipkart\nor paste below.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'PRODUCT_URL',
              hintText: 'https://...',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_urlController.text.isNotEmpty) {
                _analyzeUrl(_urlController.text);
              }
            },
            child: const Text('ANALYZE'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              color: BrutalistTheme.neonRed.withValues(alpha: 0.1),
              child: Text(
                'ERROR: $_error',
                style: const TextStyle(color: BrutalistTheme.neonRed, fontFamily: 'Roboto Mono'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AUTHENTICHECK',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: BrutalistTheme.neonGreen,
            letterSpacing: 4,
          ),
        ),
        backgroundColor: BrutalistTheme.black,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: BrutalistTheme.textLight, width: 1)),
      ),
      body: _isLoading
          ? _buildLoading()
          : _result != null
              ? _buildDashboard(_result!)
              : _buildInputView(),
    );
  }
}
