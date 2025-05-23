import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/notes_model.dart';

class VoiceNoteScreen extends StatefulWidget {
  final String notebookId;

  const VoiceNoteScreen({Key? key, required this.notebookId}) : super(key: key);

  @override
  _VoiceNoteScreenState createState() => _VoiceNoteScreenState();
}

class _VoiceNoteScreenState extends State<VoiceNoteScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _filePath;

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<bool> _ensureMicPermission() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brak dostępu do mikrofonu')),
      );
      return false;
    }
    return true;
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() => _isRecording = false);
      if (path != null) {
        // Pytanie o tytuł notatki głosowej
        final titleController = TextEditingController();
        final title = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Podaj tytuł notatki głosowej'),
            content: TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Tytuł...'),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Anuluj')),
              TextButton(onPressed: () => Navigator.pop(ctx, titleController.text.trim()), child: const Text('OK')),
            ],
          ),
        );
        if (title != null && title.isNotEmpty) {
          context.read<NotesModel>().addVoiceNote(path, title);
        }
      }
      Navigator.of(context).pop();
    } else {
      if (await _ensureMicPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final filePath =
            '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: filePath,
        );
        setState(() {
          _isRecording = true;
          _filePath = filePath;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nowa notatka głosowa'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 64,
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              color: Theme.of(context).primaryColor,
              onPressed: _toggleRecording,
            ),
            const SizedBox(height: 12),
            Text(
              _isRecording ? 'Nagrywanie...' : 'Dotknij, aby nagrać',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
