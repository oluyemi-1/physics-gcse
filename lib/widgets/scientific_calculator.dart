import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/sound_provider.dart';

/// A collapsible scientific calculator widget for use in quiz and practice screens.
class ScientificCalculator extends StatefulWidget {
  final Color accentColor;

  const ScientificCalculator({
    super.key,
    this.accentColor = Colors.blue,
  });

  @override
  State<ScientificCalculator> createState() => _ScientificCalculatorState();
}

class _ScientificCalculatorState extends State<ScientificCalculator> {
  bool _isExpanded = false;
  String _expression = '';
  String _result = '';
  bool _showScientific = false;

  void _onButtonPressed(String value) {
    try {
      context.read<SoundProvider>().playClick();
    } catch (_) {}

    setState(() {
      switch (value) {
        case 'C':
          _expression = '';
          _result = '';
          break;
        case '⌫':
          if (_expression.isNotEmpty) {
            // Remove last character or function name
            if (_expression.endsWith('sin(') ||
                _expression.endsWith('cos(') ||
                _expression.endsWith('tan(')) {
              _expression =
                  _expression.substring(0, _expression.length - 4);
            } else if (_expression.endsWith('√(')) {
              _expression =
                  _expression.substring(0, _expression.length - 2);
            } else {
              _expression =
                  _expression.substring(0, _expression.length - 1);
            }
          }
          break;
        case '=':
          _evaluate();
          break;
        case 'sin':
          _expression += 'sin(';
          break;
        case 'cos':
          _expression += 'cos(';
          break;
        case 'tan':
          _expression += 'tan(';
          break;
        case '√':
          _expression += '√(';
          break;
        case 'x²':
          _expression += '²';
          break;
        case 'π':
          _expression += 'π';
          break;
        default:
          _expression += value;
      }
    });
  }

  void _evaluate() {
    try {
      final result = _parseAndEvaluate(_expression);
      if (result.isNaN || result.isInfinite) {
        _result = 'Error';
      } else if (result == result.roundToDouble() && result.abs() < 1e12) {
        _result = result.toInt().toString();
      } else {
        _result = result.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      }
    } catch (e) {
      _result = 'Error';
    }
  }

  double _parseAndEvaluate(String expr) {
    // Preprocess: replace display symbols with parseable tokens
    expr = expr.replaceAll('×', '*');
    expr = expr.replaceAll('÷', '/');
    expr = expr.replaceAll('π', '${math.pi}');
    expr = expr.replaceAll('²', '^2');

    final parser = _ExpressionParser(expr);
    return parser.parse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Header toggle
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.accentColor.withValues(alpha: 0.15),
                borderRadius: _isExpanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      )
                    : BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.calculate,
                      color: widget.accentColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Calculator',
                    style: TextStyle(
                      color: widget.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  if (_result.isNotEmpty && !_isExpanded)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _result,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: widget.accentColor,
                  ),
                ],
              ),
            ),
          ),

          // Calculator body
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _expression.isEmpty ? '0' : _expression,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_result.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '= $_result',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Scientific toggle
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            setState(() => _showScientific = !_showScientific),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _showScientific
                                ? widget.accentColor.withValues(alpha: 0.3)
                                : Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _showScientific ? 'Basic' : 'Scientific',
                            style: TextStyle(
                              color: _showScientific
                                  ? widget.accentColor
                                  : Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Scientific row
                  if (_showScientific)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          _buildCalcButton('sin', flex: 1, isFunc: true),
                          _buildCalcButton('cos', flex: 1, isFunc: true),
                          _buildCalcButton('tan', flex: 1, isFunc: true),
                          _buildCalcButton('√', flex: 1, isFunc: true),
                          _buildCalcButton('x²', flex: 1, isFunc: true),
                          _buildCalcButton('π', flex: 1, isFunc: true),
                          _buildCalcButton('^', flex: 1, isFunc: true),
                        ],
                      ),
                    ),

                  // Main button grid
                  _buildButtonRow(['C', '(', ')', '⌫']),
                  const SizedBox(height: 4),
                  _buildButtonRow(['7', '8', '9', '÷']),
                  const SizedBox(height: 4),
                  _buildButtonRow(['4', '5', '6', '×']),
                  const SizedBox(height: 4),
                  _buildButtonRow(['1', '2', '3', '-']),
                  const SizedBox(height: 4),
                  _buildButtonRow(['0', '.', '=', '+']),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<String> buttons) {
    return Row(
      children: buttons.map((b) => _buildCalcButton(b)).toList(),
    );
  }

  Widget _buildCalcButton(String label, {int flex = 1, bool isFunc = false}) {
    final isOp = ['+', '-', '×', '÷', '^'].contains(label);
    final isEquals = label == '=';
    final isClear = label == 'C';
    final isBackspace = label == '⌫';

    Color bgColor;
    Color textColor;

    if (isEquals) {
      bgColor = widget.accentColor;
      textColor = Colors.white;
    } else if (isOp) {
      bgColor = widget.accentColor.withValues(alpha: 0.3);
      textColor = widget.accentColor;
    } else if (isClear) {
      bgColor = Colors.red.shade900;
      textColor = Colors.red.shade200;
    } else if (isBackspace) {
      bgColor = Colors.orange.shade900;
      textColor = Colors.orange.shade200;
    } else if (isFunc) {
      bgColor = Colors.indigo.shade900;
      textColor = Colors.indigo.shade200;
    } else {
      bgColor = Colors.grey.shade800;
      textColor = Colors.white;
    }

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _onButtonPressed(label),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: isFunc ? 8 : 14,
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: isFunc ? 13 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple recursive descent parser for math expressions.
/// Supports: +, -, *, /, ^, sin, cos, tan, sqrt, parentheses, negative numbers.
class _ExpressionParser {
  final String _expr;
  int _pos = 0;

  _ExpressionParser(this._expr);

  double parse() {
    final result = _parseAddSub();
    if (_pos < _expr.length) {
      throw FormatException('Unexpected character at $_pos');
    }
    return result;
  }

  double _parseAddSub() {
    var result = _parseMulDiv();
    while (_pos < _expr.length) {
      if (_match('+')) {
        result += _parseMulDiv();
      } else if (_match('-')) {
        result -= _parseMulDiv();
      } else {
        break;
      }
    }
    return result;
  }

  double _parseMulDiv() {
    var result = _parsePower();
    while (_pos < _expr.length) {
      if (_match('*')) {
        result *= _parsePower();
      } else if (_match('/')) {
        final divisor = _parsePower();
        result /= divisor;
      } else {
        break;
      }
    }
    return result;
  }

  double _parsePower() {
    var result = _parseUnary();
    if (_match('^')) {
      result = math.pow(result, _parseUnary()).toDouble();
    }
    return result;
  }

  double _parseUnary() {
    if (_match('-')) {
      return -_parseAtom();
    }
    if (_match('+')) {
      return _parseAtom();
    }
    return _parseAtom();
  }

  double _parseAtom() {
    _skipSpaces();

    // Functions
    if (_matchWord('sin(')) {
      final arg = _parseAddSub();
      _expect(')');
      return math.sin(arg * math.pi / 180); // degrees
    }
    if (_matchWord('cos(')) {
      final arg = _parseAddSub();
      _expect(')');
      return math.cos(arg * math.pi / 180);
    }
    if (_matchWord('tan(')) {
      final arg = _parseAddSub();
      _expect(')');
      return math.tan(arg * math.pi / 180);
    }
    if (_matchWord('√(') || _matchWord('sqrt(')) {
      final arg = _parseAddSub();
      _expect(')');
      return math.sqrt(arg);
    }

    // Parentheses
    if (_match('(')) {
      final result = _parseAddSub();
      _expect(')');
      return result;
    }

    // Number
    return _parseNumber();
  }

  double _parseNumber() {
    _skipSpaces();
    final start = _pos;
    while (_pos < _expr.length &&
        (RegExp(r'[0-9.]').hasMatch(_expr[_pos]))) {
      _pos++;
    }
    if (_pos == start) {
      throw FormatException('Expected number at position $_pos');
    }
    return double.parse(_expr.substring(start, _pos));
  }

  bool _match(String char) {
    _skipSpaces();
    if (_pos < _expr.length && _expr[_pos] == char) {
      _pos++;
      return true;
    }
    return false;
  }

  bool _matchWord(String word) {
    _skipSpaces();
    if (_pos + word.length <= _expr.length &&
        _expr.substring(_pos, _pos + word.length) == word) {
      _pos += word.length;
      return true;
    }
    return false;
  }

  void _expect(String char) {
    if (!_match(char)) {
      // Tolerate missing closing parens
    }
  }

  void _skipSpaces() {
    while (_pos < _expr.length && _expr[_pos] == ' ') {
      _pos++;
    }
  }
}
