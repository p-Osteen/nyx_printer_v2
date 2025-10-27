/// The [NyxTextFormat] class holds the formatting options for text to be printed.
/// This class allows customization of text appearance, including font size, style, alignment, spacing, and padding.
/// It provides a method [toMap] to convert the properties into a map format suitable for platform-specific communication.
class NyxTextFormat {
  /// The size of the text to be printed.
  ///
  /// This value determines the font size for the printed text. Default is 24.
  int textSize;

  /// Whether the text should be underlined.
  ///
  /// This boolean value specifies whether the text will have an underline. Default is false.
  bool underline;

  /// Horizontal scaling factor for text.
  ///
  /// This value scales the text horizontally. A value of 1.0 means no scaling, while values greater than 1.0 stretch the text horizontally. Default is 1.0.
  double textScaleX;

  /// Vertical scaling factor for text.
  ///
  /// This value scales the text vertically. A value of 1.0 means no scaling, while values greater than 1.0 stretch the text vertically. Default is 1.0.
  double textScaleY;

  /// The space between letters.
  ///
  /// This value controls the amount of space between each letter of the text. Default is 0.
  double letterSpacing;

  /// The space between lines of text.
  ///
  /// This value controls the vertical space between lines of text. Default is 0.
  double lineSpacing;

  /// The top padding for the text.
  ///
  /// This value specifies the amount of space to add above the text. Default is 0.
  int topPadding;

  /// The left padding for the text.
  ///
  /// This value specifies the amount of space to add to the left of the text. Default is 0.
  int leftPadding;

  /// The alignment of the text.
  ///
  /// This specifies how the text will be aligned: left, center, or right. Default is [NyxAlign.left].
  NyxAlign align;

  /// The style of the font.
  ///
  /// This value specifies the font style of the text. It can be [NyxFontStyle.normal], [NyxFontStyle.bold],
  /// [NyxFontStyle.italic], or [NyxFontStyle.boldItalic]. Default is [NyxFontStyle.normal].
  NyxFontStyle style;

  /// The font type to be used for the text.
  ///
  /// This value specifies the font type. It can be [NyxFont.defaultFont], [NyxFont.defaultBold],
  /// [NyxFont.sansSerif], [NyxFont.serif], or [NyxFont.monospace]. Default is [NyxFont.defaultFont].
  NyxFont font;

  /// Constructor to initialize the [NyxTextFormat] with default values or custom ones.
  ///
  /// [textSize] The size of the text. Must be positive. Default is 24.
  /// [underline] Whether the text should be underlined. Default is false.
  /// [textScaleX] The horizontal scaling factor for the text. Must be positive. Default is 1.0.
  /// [textScaleY] The vertical scaling factor for the text. Must be positive. Default is 1.0.
  /// [letterSpacing] The space between letters. Default is 0.
  /// [lineSpacing] The space between lines of text. Default is 0.
  /// [topPadding] The top padding for the text. Must be non-negative. Default is 0.
  /// [leftPadding] The left padding for the text. Must be non-negative. Default is 0.
  /// [align] The alignment of the text. Default is [NyxAlign.left].
  /// [style] The font style. Default is [NyxFontStyle.normal].
  /// [font] The font type. Default is [NyxFont.defaultFont].
  ///
  /// Throws [ArgumentError] if any parameter is invalid.
  NyxTextFormat({
    this.textSize = 24,
    this.underline = false,
    this.textScaleX = 1.0,
    this.textScaleY = 1.0,
    this.letterSpacing = 0,
    this.lineSpacing = 0,
    this.topPadding = 0,
    this.leftPadding = 0,
    this.align = NyxAlign.left,
    this.style = NyxFontStyle.normal,
    this.font = NyxFont.defaultFont,
  }) {
    if (textSize <= 0) {
      throw ArgumentError('Text size must be positive');
    }
    if (textScaleX <= 0) {
      throw ArgumentError('Text scale X must be positive');
    }
    if (textScaleY <= 0) {
      throw ArgumentError('Text scale Y must be positive');
    }
    if (topPadding < 0) {
      throw ArgumentError('Top padding must be non-negative');
    }
    if (leftPadding < 0) {
      throw ArgumentError('Left padding must be non-negative');
    }
  }

  /// Validates the current text format settings.
  ///
  /// Throws [ArgumentError] if any property has an invalid value.
  void validate() {
    if (textSize <= 0) {
      throw ArgumentError('Text size must be positive');
    }
    if (textScaleX <= 0) {
      throw ArgumentError('Text scale X must be positive');
    }
    if (textScaleY <= 0) {
      throw ArgumentError('Text scale Y must be positive');
    }
    if (topPadding < 0) {
      throw ArgumentError('Top padding must be non-negative');
    }
    if (leftPadding < 0) {
      throw ArgumentError('Left padding must be non-negative');
    }
  }

  /// Converts the [NyxTextFormat] properties into a map of key-value pairs.
  ///
  /// This method is useful for passing the text format options to platform-specific implementations.
  /// The map keys correspond to the text formatting properties, and the values are their respective settings.
  ///
  /// Validates the format before conversion.
  Map<String, dynamic> toMap() {
    validate(); // Ensure all values are valid before conversion
    
    return <String, dynamic>{
      'textSize': textSize,
      'underline': underline,
      'textScaleX': textScaleX,
      'textScaleY': textScaleY,
      'letterSpacing': letterSpacing,
      'lineSpacing': lineSpacing,
      'topPadding': topPadding,
      'leftPadding': leftPadding,
      'align': align == NyxAlign.left
          ? 0
          : align == NyxAlign.center
              ? 1
              : 2,
      'style': style == NyxFontStyle.normal
          ? 0
          : style == NyxFontStyle.bold
              ? 1
              : style == NyxFontStyle.italic
                  ? 2
                  : 3,
      'font': font == NyxFont.defaultFont
          ? 0
          : font == NyxFont.defaultBold
              ? 1
              : font == NyxFont.sansSerif
                  ? 2
                  : font == NyxFont.serif
                      ? 3
                      : 4,
    };
  }

  /// Creates a copy of this [NyxTextFormat] with optionally modified properties.
  ///
  /// This is useful for creating variations of a text format without
  /// modifying the original instance.
  NyxTextFormat copyWith({
    int? textSize,
    bool? underline,
    double? textScaleX,
    double? textScaleY,
    double? letterSpacing,
    double? lineSpacing,
    int? topPadding,
    int? leftPadding,
    NyxAlign? align,
    NyxFontStyle? style,
    NyxFont? font,
  }) {
    return NyxTextFormat(
      textSize: textSize ?? this.textSize,
      underline: underline ?? this.underline,
      textScaleX: textScaleX ?? this.textScaleX,
      textScaleY: textScaleY ?? this.textScaleY,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      topPadding: topPadding ?? this.topPadding,
      leftPadding: leftPadding ?? this.leftPadding,
      align: align ?? this.align,
      style: style ?? this.style,
      font: font ?? this.font,
    );
  }

  @override
  String toString() {
    return 'NyxTextFormat{'
        'textSize: $textSize, '
        'underline: $underline, '
        'textScaleX: $textScaleX, '
        'textScaleY: $textScaleY, '
        'letterSpacing: $letterSpacing, '
        'lineSpacing: $lineSpacing, '
        'topPadding: $topPadding, '
        'leftPadding: $leftPadding, '
        'align: $align, '
        'style: $style, '
        'font: $font'
        '}';
  }
}

/// Enum representing different font styles that can be applied to text.
enum NyxFontStyle {
  /// Regular text style.
  normal,

  /// Bold text style.
  bold,

  /// Italic text style.
  italic,

  /// Bold and italic text style.
  boldItalic,
}

/// Enum representing different font types that can be used for text.
enum NyxFont {
  /// Default font style.
  defaultFont,

  /// Bold default font.
  defaultBold,

  /// Sans-serif font.
  sansSerif,

  /// Serif font.
  serif,

  /// Monospace font.
  monospace,
}

/// Enum representing different text alignment options.
enum NyxAlign {
  /// Align the text to the left.
  left,

  /// Align the text to the center.
  center,

  /// Align the text to the right.
  right,
}
