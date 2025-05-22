import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ui/Utils/show_toast.dart';
import 'package:ui/controllers/video_controller/video_controller.dart';
import 'package:video_player/video_player.dart';

class ContentCreatePage extends StatefulWidget {
  const ContentCreatePage({super.key});

  @override
  State<ContentCreatePage> createState() => _ContentCreatePageState();
}

class _ContentCreatePageState extends State<ContentCreatePage> {
  int _currentStep = 0;
  bool loading = false;
  File? _videoFile;
  File? _thumbnailFile;
  VideoPlayerController? _videoController;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  List<String> _hashtags = [];

  final VideoController vid_controller = Get.put(VideoController());

  // Function to pick a video file
  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );
    if (result != null) {
      setState(() {
        _videoFile = File(result.files.single.path!);
        _videoController = VideoPlayerController.file(_videoFile!)
          ..initialize()
              .then((_) {
                // Ensure the first frame is displayed and the video is ready to play.
                setState(() {});
              })
              .catchError((error) {
                // Handle video initialization errors
                log('Error initializing video: $error');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to load video: $error')),
                );
                _videoFile = null; // Clear the file if it fails to load
                _videoController?.dispose(); // Dispose the controller
                _videoController = null;
              });
      });
    }
  }

  // Function to pick a thumbnail image
  Future<void> _pickThumbnail() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _thumbnailFile = File(image.path);
      });
    }
  }

  // Function to add a hashtag
  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !_hashtags.contains(tag.trim())) {
      setState(() {
        _hashtags.add(tag.trim());
        _tagController.clear();
      });
    }
  }

  // Function to remove a hashtag
  void _removeTag(String tag) {
    setState(() {
      _hashtags.remove(tag);
    });
  }

  // Function to handle form submission
  Future<void> _submit() async {
    if (_formKey.currentState!.validate() &&
        _videoFile != null &&
        _thumbnailFile != null) {
      // TODO: Implement actual upload logic here
      setState(() {
        loading = true;
      });
      bool success = await vid_controller.publishVideo(
        context,
        _videoFile,
        _thumbnailFile,
        _hashtags,
        _titleController.text,
        _descriptionController.text,
      );
      setState(() {
        loading = false;
      });
      if (!success) {
        showErrorMsg("Failed to upload!", context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Content uploaded!)"),
            backgroundColor: Colors.green,
          ),
        );
      }

      // For demonstration, reset the form after "submission"
      setState(() {
        _currentStep = 0;
        _videoFile = null;
        _thumbnailFile = null;
        _videoController?.dispose();
        _videoController = null;
        _titleController.clear();
        _descriptionController.clear();
        _tagController.clear();
        _hashtags = [];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please complete all steps and provide a video and thumbnail.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Content",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.red, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0, // Remove shadow
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: Colors.deepPurple, // Active step color
          ),
        ),
        child: Stepper(
          type: StepperType.vertical, // Can be horizontal for a different look
          currentStep: _currentStep,
          onStepContinue: () {
            // Validate current step before moving to the next
            if (_currentStep == 2 && !_formKey.currentState!.validate()) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please fill in all required fields in Details.',
                  ),
                ),
              );
              return; // Stay on the current step if validation fails
            }

            if (_currentStep == 0 && _videoFile == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select a video.')),
              );
              return;
            }

            if (_currentStep == 1 && _thumbnailFile == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select a thumbnail.')),
              );
              return;
            }

            if (_currentStep < 3) {
              setState(() => _currentStep++);
            } else {
              _submit();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep--);
          },
          controlsBuilder: (BuildContext context, ControlsDetails details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.deepPurple, // Button background color
                        foregroundColor: Colors.white, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Rounded corners
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 5, // Shadow
                      ),
                      child:
                          _currentStep == 3
                              ? (loading
                                  ? CircularProgressIndicator(
                                    backgroundColor: Colors.white,
                                  )
                                  : Text('Publish'))
                              : Text('Next'),
                    ),
                  ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple, // Text color
                          side: const BorderSide(
                            color: Colors.deepPurple,
                            width: 2,
                          ), // Border color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // Rounded corners
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                ],
              ),
            );
          },
          steps: [
            // Step 1: Video Selection
            Step(
              title: const Text(
                "Upload Video",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              content: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _videoFile == null
                          ? Column(
                            children: [
                              Icon(
                                Icons.videocam,
                                size: 80,
                                color: Colors.deepPurple.shade200,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "No video selected",
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _pickVideo,
                                icon: const Icon(Icons.upload_file),
                                label: const Text("Pick Video"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple.shade400,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          )
                          : Column(
                            children: [
                              _videoController!.value.isInitialized
                                  ? AspectRatio(
                                    aspectRatio:
                                        _videoController!.value.aspectRatio,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: VideoPlayer(_videoController!),
                                    ),
                                  )
                                  : const CircularProgressIndicator(), // Show loading indicator
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _pickVideo,
                                icon: const Icon(Icons.replay),
                                label: const Text("Change Video"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple.shade400,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    ],
                  ),
                ),
              ),
              isActive: _currentStep >= 0,
              state:
                  _videoFile != null ? StepState.complete : StepState.indexed,
            ),

            // Step 2: Thumbnail Selection
            Step(
              title: const Text(
                "Select Thumbnail",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              content: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _thumbnailFile == null
                          ? Column(
                            children: [
                              Icon(
                                Icons.image,
                                size: 80,
                                color: Colors.deepPurple.shade200,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "No thumbnail selected",
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _pickThumbnail,
                                icon: const Icon(Icons.add_photo_alternate),
                                label: const Text("Pick Thumbnail"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple.shade400,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          )
                          : Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _thumbnailFile!,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _pickThumbnail,
                                icon: const Icon(Icons.refresh),
                                label: const Text("Change Thumbnail"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple.shade400,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    ],
                  ),
                ),
              ),
              isActive: _currentStep >= 1,
              state:
                  _thumbnailFile != null
                      ? StepState.complete
                      : StepState.indexed,
            ),

            // Step 3: Details Input
            Step(
              title: const Text(
                "Add Description",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              content: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            hintText:
                                'Enter a compelling title for your content',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(
                              Icons.title,
                              color: Colors.deepPurple,
                            ),
                            filled: true,
                            fillColor: Colors.deepPurple.shade50,
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Title cannot be empty'
                                      : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            hintText: 'Tell us more about your content',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(
                              Icons.description,
                              color: Colors.deepPurple,
                            ),
                            filled: true,
                            fillColor: Colors.deepPurple.shade50,
                          ),
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              isActive: _currentStep >= 2,
              state:
                  _formKey.currentState?.validate() == true
                      ? StepState.complete
                      : StepState.indexed,
            ),

            // Step 4: Hashtags
            Step(
              title: const Text(
                "Add Hashtags",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              content: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _tagController,
                        decoration: InputDecoration(
                          labelText: 'Add Hashtag',
                          hintText: 'e.g., #coding',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(
                            Icons.tag,
                            color: Colors.deepPurple,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.deepPurple,
                            ),
                            onPressed: () => _addTag(_tagController.text),
                          ),
                          filled: true,
                          fillColor: Colors.deepPurple.shade50,
                        ),
                        onSubmitted: _addTag,
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _hashtags
                                  .map(
                                    (tag) => Chip(
                                      label: Text(tag),
                                      onDeleted: () => _removeTag(tag),
                                      backgroundColor:
                                          Colors.deepPurple.shade100,
                                      labelStyle: const TextStyle(
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      deleteIconColor: Colors.deepPurple,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: const BorderSide(
                                          color: Colors.deepPurple,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              isActive: _currentStep >= 3,
              state:
                  _hashtags.isNotEmpty ? StepState.complete : StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }
}
