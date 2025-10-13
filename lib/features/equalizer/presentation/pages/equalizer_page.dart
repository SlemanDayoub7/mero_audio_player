import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:equalizer_flutter/equalizer_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_circular_progress_indicator.dart';
import 'package:mero_audio_player/core/widgets/generic_app_bar.dart';
import 'package:mero_audio_player/features/settings/presentation/pages/change_background/change_background_page.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';

bool enableCustomEQ = false;
String? selectedPreset;

class EqualizerPage extends StatefulWidget {
  const EqualizerPage({Key? key}) : super(key: key);

  @override
  State<EqualizerPage> createState() => _EqualizerPageState();
}

class _EqualizerPageState extends State<EqualizerPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: globalBackgroundColor,
      appBar: GenericAppBar(title: LocaleKeys.equalizer.tr()),
      body: ListView(
        padding: context.paddingLow,
        children: [
          Card(
            color: Colors.grey.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SwitchListTile(
              title: Text(
                LocaleKeys.enable_custom_equalizer.tr(),
                style: TextStyles.titleLarge.copyWith(color: Colors.white),
              ),
              value: enableCustomEQ,
              activeColor: globalBackgroundColor,
              thumbColor: const WidgetStatePropertyAll(Colors.white),
              onChanged: (value) {
                EqualizerFlutter.setEnabled(value);
                setState(() {
                  enableCustomEQ = value;
                });
              },
            ),
          ),
          SizedBox(height: 20.h),
          FutureBuilder<List<int>>(
            future: EqualizerFlutter.getBandLevelRange(),
            builder: (context, snapshot) {
              return snapshot.connectionState == ConnectionState.done
                  ? CustomEQ(
                    enableCustomEQ,
                    snapshot.data!,
                    onChanged: () {
                      setState(() {});
                    },
                  )
                  : AppCircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }
}

class CustomEQ extends StatefulWidget {
  const CustomEQ(this.enabled, this.bandLevelRange, {Key? key, this.onChanged})
    : super(key: key);

  final bool enabled;
  final List<int> bandLevelRange;
  final Function? onChanged;
  @override
  _CustomEQState createState() => _CustomEQState();
}

class _CustomEQState extends State<CustomEQ> {
  late double min, max;
  String? _selectedPreset;
  late Future<List<String>> fetchPresets;
  late Future<List<int>> centerFreqs;
  List<double> bandLevels = [];

  @override
  void initState() {
    super.initState();
    min = widget.bandLevelRange[0].toDouble();
    max = widget.bandLevelRange[1].toDouble();
    fetchPresets = EqualizerFlutter.getPresetNames();
    centerFreqs = EqualizerFlutter.getCenterBandFreqs();
    _selectedPreset = selectedPreset;
    _initBandLevels();
  }

  Future<void> _initBandLevels() async {
    final freqs = await EqualizerFlutter.getCenterBandFreqs();
    List<double> levels = [];
    for (int i = 0; i < freqs.length; i++) {
      final level = await EqualizerFlutter.getBandLevel(i);
      levels.add(level.toDouble());
    }
    if (mounted) setState(() => bandLevels = levels);
  }

  void _onSliderChanged(int bandId, double value) {
    setState(() {
      bandLevels[bandId] = value;
      _selectedPreset = selectedPreset = null;
    });
    EqualizerFlutter.setBandLevel(bandId, value.toInt());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: centerFreqs,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            bandLevels.isEmpty) {
          return AppCircularProgressIndicator();
        }
        final freqs = snapshot.data!;
        return Column(
          children: [
            _buildPresetSelector(widget.onChanged!),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                freqs.length,
                (i) => _buildSliderBand(freqs[i], i),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPresetSelector(Function onChanged) {
    final presets = [
      LocaleKeys.flat.tr(),
      LocaleKeys.bass_booster.tr(),
      LocaleKeys.vocal_booster.tr(),
      LocaleKeys.pop.tr(),
      LocaleKeys.rock.tr(),
      LocaleKeys.hip_hop.tr(),
      LocaleKeys.heavy_metal.tr(),
      LocaleKeys.electronic.tr(),
      LocaleKeys.rnb.tr(),
      LocaleKeys.folk.tr(),
      LocaleKeys.jazz.tr(),
      LocaleKeys.dance.tr(),
      LocaleKeys.classical.tr(),
      LocaleKeys.latin.tr(),
    ];

    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: context.paddingMedium,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.preset.tr(),
              style: TextStyles.titleMedium.copyWith(color: Colors.white),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  presets.map((preset) {
                    final bool isSelected = selectedPreset == preset;
                    return ChoiceChip(
                      disabledColor: Colors.black,
                      label: Text(
                        preset,
                        style: TextStyles.titleMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: globalBackgroundColor,
                      backgroundColor: Colors.grey.shade800,
                      onSelected: (selected) {
                        if (selected) {
                          if (!enableCustomEQ) {
                            EqualizerFlutter.setEnabled(true);

                            enableCustomEQ = true;
                            onChanged();
                          }
                          _applyPreset(preset);
                        }
                      },
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyPreset(String presetName) async {
    setState(() => _selectedPreset = selectedPreset = presetName);

    Map<String, List<double>> presetValues = {
      LocaleKeys.flat.tr(): List.filled(5, 0.0),
      LocaleKeys.bass_booster.tr(): [8.0, 6.0, 2.0, 0.0, 0.0],
      LocaleKeys.vocal_booster.tr(): [0.0, 3.0, 6.0, 6.0, 3.0],
      LocaleKeys.pop.tr(): [2.0, 4.0, 3.0, 0.0, 2.0],
      LocaleKeys.rock.tr(): [4.0, 3.0, 0.0, 2.0, 4.0],
      LocaleKeys.hip_hop.tr(): [6.0, 4.0, 0.0, 2.0, 4.0],
      LocaleKeys.heavy_metal.tr(): [5.0, 3.0, 0.0, 3.0, 5.0],
      LocaleKeys.electronic.tr(): [4.0, 3.0, 0.0, 3.0, 5.0],
      LocaleKeys.rnb.tr(): [5.0, 3.0, 0.0, 2.0, 3.0],
      LocaleKeys.folk.tr(): [2.0, 0.0, 0.0, 2.0, 3.0],
      LocaleKeys.jazz.tr(): [3.0, 2.0, 0.0, 2.0, 3.0],
      LocaleKeys.dance.tr(): [5.0, 3.0, 0.0, 2.0, 4.0],
      LocaleKeys.classical.tr(): [3.0, 2.0, 0.0, 2.0, 4.0],
      LocaleKeys.latin.tr(): [4.0, 2.0, 0.0, 3.0, 4.0],
    };

    final values = presetValues[presetName] ?? List.filled(5, 0.0);

    setState(() {
      bandLevels = List.from(values);
    });

    for (int i = 0; i < values.length && i < bandLevels.length; i++) {
      EqualizerFlutter.setBandLevel(i, values[i].toInt());
    }
  }

  Widget _buildSliderBand(int freq, int bandId) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 250.h,
            child: RotatedBox(
              quarterTurns: context.locale.languageCode == 'ar' ? 1 : 3,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade700,
                  thumbColor: Colors.white,
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                ),
                child: Slider(
                  min: min,
                  max: max,
                  value: bandLevels[bandId],
                  onChanged:
                      widget.enabled
                          ? (value) => _onSliderChanged(bandId, value)
                          : null,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${freq ~/ 1000} Hz',
            style: TextStyles.titleMedium.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
