import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';

import '../app/constants.dart';

/// Full-screen Changelog viewer.
///
/// Loads `CHANGELOG.md` from app assets and renders it with a minimal,
/// theme-aware markdown formatter. Intentionally hand-rolled (no
/// `flutter_markdown` dependency) — the changelog format is simple and
/// adding a heavy markdown engine just for this screen isn't worth the
/// extra weight.
class ChangelogScreen extends StatefulWidget {
  const ChangelogScreen({super.key});

  @override
  State<ChangelogScreen> createState() => _ChangelogScreenState();
}

class _ChangelogScreenState extends State<ChangelogScreen> {
  late final Future<String> _future;

  @override
  void initState() {
    super.initState();
    _future = rootBundle.loadString('CHANGELOG.md');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Changelog',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: _future,
          builder: (ctx, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              );
            }
            if (snap.hasError || snap.data == null) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: Text(
                    'Could not load changelog.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withAlpha(160),
                    ),
                  ),
                ),
              );
            }
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
              child: _MarkdownView(source: snap.data!),
            );
          },
        ),
      ),
    );
  }
}

/// Lightweight markdown renderer covering the subset BreakCount's
/// CHANGELOG actually uses:
///   - `# H1`, `## H2`, `### H3`
///   - bullet lines starting with `- `
///   - `**bold**` runs inside paragraphs / bullets
///   - `[link text](url)` — rendered as bold (no tap, this is just docs)
///   - Fenced ``` ``` ``` blocks
///   - blank lines = paragraph break
class _MarkdownView extends StatelessWidget {
  final String source;
  const _MarkdownView({required this.source});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blocks = _parseBlocks(source);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((b) => _renderBlock(theme, b)).toList(),
    );
  }

  List<_MdBlock> _parseBlocks(String src) {
    final lines = src.split('\n');
    final blocks = <_MdBlock>[];
    var i = 0;
    while (i < lines.length) {
      final line = lines[i];
      if (line.startsWith('```')) {
        // Fenced code block — collect until closing fence.
        final buf = StringBuffer();
        i++;
        while (i < lines.length && !lines[i].startsWith('```')) {
          buf.writeln(lines[i]);
          i++;
        }
        i++; // skip closing fence
        blocks.add(_MdBlock.code(buf.toString().trimRight()));
        continue;
      }
      if (line.startsWith('### ')) {
        blocks.add(_MdBlock.h3(line.substring(4).trim()));
        i++;
        continue;
      }
      if (line.startsWith('## ')) {
        blocks.add(_MdBlock.h2(line.substring(3).trim()));
        i++;
        continue;
      }
      if (line.startsWith('# ')) {
        blocks.add(_MdBlock.h1(line.substring(2).trim()));
        i++;
        continue;
      }
      if (line.trim().startsWith('- ')) {
        // Collect contiguous bullet lines.
        final items = <String>[];
        while (i < lines.length && lines[i].trim().startsWith('- ')) {
          items.add(lines[i].trim().substring(2));
          i++;
        }
        blocks.add(_MdBlock.bullets(items));
        continue;
      }
      if (line.trim().isEmpty) {
        i++;
        continue;
      }
      // Otherwise it's a paragraph — collect until blank line / heading.
      final buf = StringBuffer(line);
      i++;
      while (i < lines.length &&
          lines[i].trim().isNotEmpty &&
          !lines[i].startsWith('#') &&
          !lines[i].trim().startsWith('- ') &&
          !lines[i].startsWith('```')) {
        buf.write(' ');
        buf.write(lines[i].trim());
        i++;
      }
      blocks.add(_MdBlock.paragraph(buf.toString()));
    }
    return blocks;
  }

  Widget _renderBlock(ThemeData theme, _MdBlock block) {
    switch (block.kind) {
      case _MdKind.h1:
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          child: Text(
            block.text!,
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
        );
      case _MdKind.h2:
        return Padding(
          padding: const EdgeInsets.only(top: 22, bottom: 8),
          child: Text(
            block.text!,
            style: GoogleFonts.outfit(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
              letterSpacing: -0.3,
            ),
          ),
        );
      case _MdKind.h3:
        return Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(
            block.text!,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              letterSpacing: 0.6,
            ),
          ),
        );
      case _MdKind.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: RichText(
            text: TextSpan(
              children: _inline(theme, block.text!),
            ),
          ),
        );
      case _MdKind.bullets:
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: block.items!.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7, right: 8, left: 4),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(children: _inline(theme, item)),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      case _MdKind.code:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withAlpha(15),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: theme.dividerTheme.color ?? AppColors.surfaceBorder,
            ),
          ),
          child: Text(
            block.text!,
            style: GoogleFonts.firaCode(
              fontSize: 12,
              color: theme.colorScheme.onSurface,
              height: 1.45,
            ),
          ),
        );
    }
  }

  /// Inline parsing for **bold** and [link](url) inside a single line of
  /// text. Returns a list of `TextSpan`s ready for `RichText`.
  List<TextSpan> _inline(ThemeData theme, String text) {
    final spans = <TextSpan>[];
    final base = GoogleFonts.outfit(
      fontSize: 14,
      color: theme.colorScheme.onSurface.withAlpha(220),
      height: 1.55,
    );
    final bold = base.copyWith(
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.onSurface,
    );

    // Tokenize on **…** and [text](url).
    final pattern = RegExp(r'(\*\*[^*]+\*\*)|(\[[^\]]+\]\([^)]+\))');
    var cursor = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(
          TextSpan(text: text.substring(cursor, match.start), style: base),
        );
      }
      final token = match.group(0)!;
      if (token.startsWith('**')) {
        spans.add(
          TextSpan(
            text: token.substring(2, token.length - 2),
            style: bold,
          ),
        );
      } else {
        // Link: render the visible text in primary color, drop the URL.
        final close = token.indexOf(']');
        final visible = token.substring(1, close);
        spans.add(
          TextSpan(
            text: visible,
            style: base.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: base));
    }
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: base));
    }
    return spans;
  }
}

enum _MdKind { h1, h2, h3, paragraph, bullets, code }

class _MdBlock {
  final _MdKind kind;
  final String? text;
  final List<String>? items;

  const _MdBlock._(this.kind, {this.text, this.items});

  factory _MdBlock.h1(String t) => _MdBlock._(_MdKind.h1, text: t);
  factory _MdBlock.h2(String t) => _MdBlock._(_MdKind.h2, text: t);
  factory _MdBlock.h3(String t) => _MdBlock._(_MdKind.h3, text: t);
  factory _MdBlock.paragraph(String t) =>
      _MdBlock._(_MdKind.paragraph, text: t);
  factory _MdBlock.bullets(List<String> items) =>
      _MdBlock._(_MdKind.bullets, items: items);
  factory _MdBlock.code(String t) => _MdBlock._(_MdKind.code, text: t);
}
