/*
  Sports KPI Simulator
  Copyright (C) 2025  Mario Stumpo

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:csv/csv.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SimApp());
}

class SimApp extends StatelessWidget {
  const SimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sports KPI Simulator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const SimHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SimHomePage extends StatefulWidget {
  const SimHomePage({super.key});

  @override
  State<SimHomePage> createState() => _SimHomePageState();
}

class _SimHomePageState extends State<SimHomePage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  final _nPlayers = TextEditingController(text: '100');
  final _seed = TextEditingController(text: '42');
  final _minutesMin = TextEditingController(text: '70');
  final _minutesMax = TextEditingController(text: '90');
  final _distanceMean = TextEditingController(text: '10.0');
  final _distanceStd = TextEditingController(text: '1.5');
  final _sprintsLambda = TextEditingController(text: '20.0');
  final _passesMin = TextEditingController(text: '30');
  final _passesMax = TextEditingController(text: '80');
  final _accMin = TextEditingController(text: '0.70');
  final _accMax = TextEditingController(text: '0.95');

  // Data + preview
  List<Map<String, dynamic>> rows = [];
  int previewCap = 100;

  // Saving state
  final _fileBaseNameCtrl = TextEditingController(text: 'simulated_players');
  String? _lastSavedPath;

  // Scroll controllers
  final _vCtrl = ScrollController();
  final _hCtrl = ScrollController();

  @override
  void dispose() {
    for (final c in [
      _nPlayers, _seed, _minutesMin, _minutesMax, _distanceMean, _distanceStd,
      _sprintsLambda, _passesMin, _passesMax, _accMin, _accMax, _fileBaseNameCtrl
    ]) { c.dispose(); }
    _vCtrl.dispose(); _hCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sports KPI Simulator')),
      body: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 320, maxWidth: 450),
            child: _buildForm(context),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _buildPreview(context)),
        ],
      ),
    );
  }

  // ---------------- UI: Form ----------------
  Widget _buildForm(BuildContext context) {
    InputDecoration deco(String label) => InputDecoration(
      labelText: label, border: const OutlineInputBorder(), isDense: true,
    );
    const gap = SizedBox(height: 10);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(children: [
          Text('Parameters', style: Theme.of(context).textTheme.titleLarge),
          gap,
          TextFormField(controller: _nPlayers, decoration: deco('Players'),
            validator: _reqInt, keyboardType: TextInputType.number),
          gap,
          TextFormField(controller: _seed, decoration: deco('Seed'),
            validator: _reqInt, keyboardType: TextInputType.number),
          gap,
          Row(children: [
            Expanded(child: TextFormField(controller: _minutesMin, decoration: deco('Minutes min'),
              validator: _reqInt, keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: _minutesMax, decoration: deco('Minutes max'),
              validator: _reqInt, keyboardType: TextInputType.number)),
          ]),
          gap,
          Row(children: [
            Expanded(child: TextFormField(controller: _distanceMean, decoration: deco('Distance mean (km)'),
              validator: _reqNum, keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: _distanceStd, decoration: deco('Distance std (km)'),
              validator: _reqNum, keyboardType: TextInputType.number)),
          ]),
          gap,
          TextFormField(controller: _sprintsLambda, decoration: deco('Sprints λ'),
            validator: _reqNum, keyboardType: TextInputType.number),
          gap,
          Row(children: [
            Expanded(child: TextFormField(controller: _passesMin, decoration: deco('Passes min'),
              validator: _reqInt, keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: _passesMax, decoration: deco('Passes max'),
              validator: _reqInt, keyboardType: TextInputType.number)),
          ]),
          gap,
          Row(children: [
            Expanded(child: TextFormField(controller: _accMin, decoration: deco('Pass acc min (0–1)'),
              validator: _reqNum, keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: _accMax, decoration: deco('Pass acc max (0–1)'),
              validator: _reqNum, keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _onGenerate,
            icon: const Icon(Icons.bolt),
            label: const Text('Generate'),
          ),
          const SizedBox(height: 24),
          Text('Export', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          TextFormField(
            controller: _fileBaseNameCtrl,
            decoration: deco('File name (without extension)'),
          ),
          const SizedBox(height: 8),
          if (_lastSavedPath != null) ...[
            OutlinedButton.icon(
              onPressed: () => _revealInFileManager(_lastSavedPath!),
              icon: const Icon(Icons.folder),
              label: const Text('Reveal last saved'),
            ),
          ],
        ]),
      ),
    );
  }

  // --------------- UI: Preview + Download buttons ---------------
  Widget _buildPreview(BuildContext context) {
    final cols = rows.isEmpty ? <String>[] : rows.first.keys.toList();

    final dataTable = rows.isEmpty
        ? const Center(child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No data yet — fill the form and click Generate'),
          ))
        : DataTable(
            columns: cols.map((c) => DataColumn(label: Text(c))).toList(),
            rows: rows.take(previewCap).map((r) =>
              DataRow(cells: cols.map((c) => DataCell(Text('${r[c]}'))).toList())
            ).toList(),
          );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text('Preview (${rows.length} rows total)',
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _saveCsv,
            icon: const Icon(Icons.download),
            label: const Text('CSV'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _saveJson,
            icon: const Icon(Icons.download),
            label: const Text('JSON'),
          ),
          const SizedBox(width: 16),
          Text('Show', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 8),
          SizedBox(
            width: 160,
            child: Slider(
              value: previewCap.toDouble(),
              min: 10, max: 500, divisions: 49,
              label: '$previewCap',
              onChanged: (v) => setState(() => previewCap = v.round()),
            ),
          ),
          const SizedBox(width: 4),
          Text('$previewCap', style: Theme.of(context).textTheme.bodySmall),
        ]),
        const SizedBox(height: 12),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Scrollbar(
              controller: _vCtrl, thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _vCtrl, scrollDirection: Axis.vertical,
                child: Scrollbar(
                  controller: _hCtrl, thumbVisibility: true,
                  notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
                  child: SingleChildScrollView(
                    controller: _hCtrl, scrollDirection: Axis.horizontal,
                    child: Padding(padding: const EdgeInsets.all(8.0), child: dataTable),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text('Note: CSV/JSON always save ALL rows.',
            style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }

  // ---------------- Validation ----------------
  String? _reqInt(String? s) {
    if (s == null || s.trim().isEmpty) return 'Required';
    final v = int.tryParse(s);
    if (v == null) return 'Integer required';
    return null;
  }
  String? _reqNum(String? s) {
    if (s == null || s.trim().isEmpty) return 'Required';
    final v = double.tryParse(s);
    if (v == null) return 'Number required';
    return null;
  }

  // ---------------- Generate ----------------
  Future<void> _onGenerate() async {
    if (!_formKey.currentState!.validate()) return;

    final nPlayers = int.parse(_nPlayers.text);
    final seed = int.parse(_seed.text);
    final minMin = int.parse(_minutesMin.text);
    final minMax = int.parse(_minutesMax.text);
    final distMean = double.parse(_distanceMean.text);
    final distStd = double.parse(_distanceStd.text);
    final sprLam = double.parse(_sprintsLambda.text);
    final passMin = int.parse(_passesMin.text);
    final passMax = int.parse(_passesMax.text);
    final accMin = double.parse(_accMin.text);
    final accMax = double.parse(_accMax.text);

    if (minMin > minMax) { _snack('Minutes min > max'); return; }
    if (passMin > passMax) { _snack('Passes min > max'); return; }
    if (accMin < 0 || accMax > 1 || accMin > accMax) { _snack('Accuracy must be in [0,1] and min ≤ max'); return; }
    if (nPlayers <= 0) { _snack('Players must be > 0'); return; }

    final rng = Random(seed);

    List<int> randInt(int a, int b, int n) =>
        List.generate(n, (_) => a + rng.nextInt(b - a + 1));

    List<double> normal(double mean, double std, int n) {
      // Box–Muller
      return List<double>.generate(n, (_) {
        final u1 = (rng.nextDouble() + 1e-12);
        final u2 = rng.nextDouble();
        final z0 = sqrt(-2.0 * log(u1)) * cos(2 * pi * u2);
        return mean + std * z0;
      });
    }

    List<int> poisson(double lambda, int n) {
      // Knuth
      final out = <int>[];
      for (var i = 0; i < n; i++) {
        final L = exp(-lambda);
        int k = 0; double p = 1.0;
        do { k++; p *= rng.nextDouble(); } while (p > L);
        out.add(k - 1);
      }
      return out;
    }

    List<double> uniform(double a, double b, int n) =>
        List<double>.generate(n, (_) => a + (b - a) * rng.nextDouble());

    final minutes = randInt(minMin, minMax, nPlayers);
    final distanceKm = normal(distMean, distStd, nPlayers)
        .map((v) => double.parse(v.toStringAsFixed(2))).toList();
    final sprints = poisson(sprLam, nPlayers);
    final passes = randInt(passMin, passMax, nPlayers);
    final passAcc = uniform(accMin, accMax, nPlayers);

    final output = <Map<String, dynamic>>[];
    for (int i = 0; i < nPlayers; i++) {
      final passesCompleted = (passes[i] * passAcc[i]).floor();
      final minutesVal = max(1, minutes[i]);
      final r = <String, dynamic>{
        'player': 'Player_${(i + 1).toString().padLeft(2, '0')}',
        'minutes': minutesVal,
        'distance_km': double.parse(distanceKm[i].toStringAsFixed(2)),
        'sprints': sprints[i],
        'passes': passes[i],
        'passes_completed': passesCompleted,
      };
      r['pass_accuracy_%'] = passes[i] == 0
          ? 0.0
          : double.parse((100.0 * passesCompleted / passes[i]).toStringAsFixed(2));
      r['distance_per90_km'] = double.parse(
          ((r['distance_km'] as double) * 90.0 / minutesVal).toStringAsFixed(3));
      r['sprints_per90'] = double.parse(
          ((r['sprints'] as int) * 90.0 / minutesVal).toStringAsFixed(3));
      output.add(r);
    }

    setState(() => rows = output);
    _snack('Generated ${rows.length} rows.');
  }

  // ---------------- Save (always ask folder; write with dart:io) ----------------
  Future<void> _saveCsv() async {
    if (rows.isEmpty) { _snack('Generate first.'); return; }

    final base = _sanitizeBaseName(_fileBaseNameCtrl.text.trim());
    if (base.isEmpty) { _snack('Enter a file name.'); return; }

    final folder = await getDirectoryPath(); // user picks Desktop/Documents/etc.
    if (folder == null) { _snack('Save cancelled.'); return; }

    try {
      final cols = rows.first.keys.toList();
      final data = <List<dynamic>>[
        cols,
        ...rows.map((r) => cols.map((c) => r[c]).toList()),
      ];
      final csvStr = const ListToCsvConverter().convert(data);
      final path = _join(folder, '$base.csv');

      final f = File(path);
      await f.create(recursive: true);
      await f.writeAsString(csvStr, flush: true);

      setState(() => _lastSavedPath = path);
      _snack('Saved: $path');
    } on FileSystemException catch (e) {
      _snack('CSV save failed: ${e.osError?.message ?? e.message}');
    } catch (e) {
      _snack('CSV save failed: $e');
    }
  }

  Future<void> _saveJson() async {
    if (rows.isEmpty) { _snack('Generate first.'); return; }

    final base = _sanitizeBaseName(_fileBaseNameCtrl.text.trim());
    if (base.isEmpty) { _snack('Enter a file name.'); return; }

    final folder = await getDirectoryPath();
    if (folder == null) { _snack('Save cancelled.'); return; }

    try {
      final pretty = const JsonEncoder.withIndent('  ').convert(rows);
      final path = _join(folder, '$base.json');

      final f = File(path);
      await f.create(recursive: true);
      await f.writeAsString(pretty, flush: true);

      setState(() => _lastSavedPath = path);
      _snack('Saved: $path');
    } on FileSystemException catch (e) {
      _snack('JSON save failed: ${e.osError?.message ?? e.message}');
    } catch (e) {
      _snack('JSON save failed: $e');
    }
  }

  // ---------------- Helpers ----------------
  String _sanitizeBaseName(String s) =>
      s.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

  String _join(String dir, String name) =>
      '$dir${Platform.pathSeparator}$name';

  void _revealInFileManager(String path) {
    try {
      if (Platform.isMacOS) {
        Process.run('open', ['-R', path]);
      } else if (Platform.isWindows) {
        Process.run('explorer', ['/select,', path.replaceAll('/', '\\')]);
      } else {
        Process.run('xdg-open', [Directory(path).parent.path]);
      }
    } catch (_) {}
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
