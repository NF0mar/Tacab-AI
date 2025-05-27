import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  File? _pickedImage;
  bool _isLoading = false;

  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? '';
    _emailController.text = user?.email ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadAndSetProfilePicture(File imageFile) async {
    if (user == null) {
      print('No user logged in, aborting upload.');
      return;
    }

    try {
      print('Starting profile picture upload...');
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_pictures/${user!.uid}.jpg');

      final uploadTask = storageRef.putFile(imageFile);

      final snapshot = await uploadTask;

      if (snapshot.state == firebase_storage.TaskState.success) {
        final downloadURL = await storageRef.getDownloadURL();
        print('Upload successful. Download URL: $downloadURL');

        await user!.updatePhotoURL(downloadURL);
        await user!.reload();
        user = FirebaseAuth.instance.currentUser; // Refresh user

        print('Profile picture updated successfully.');
      } else {
        print('Upload failed with state: ${snapshot.state}');
        Get.snackbar('Error', 'Failed to upload profile picture.');
      }
    } catch (e) {
      print('Error during profile picture upload: $e');
      Get.snackbar('Error', 'Failed to update profile picture.');
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      print('Updating display name...');
      if (_nameController.text.trim() != (currentUser.displayName ?? '')) {
        await currentUser.updateDisplayName(_nameController.text.trim());
        print('Display name updated');
      }

      print('Updating email...');
      if (_emailController.text.trim() != (currentUser.email ?? '')) {
        await currentUser.updateEmail(_emailController.text.trim());
        print('Email updated');
      }

      if (_pickedImage != null) {
        print('Uploading profile picture...');
        await _uploadAndSetProfilePicture(_pickedImage!);
        print('Profile picture upload completed');
      }

      print('Reloading user...');
      await currentUser.reload();
      user = FirebaseAuth.instance.currentUser; // Refresh user instance
      print('User reloaded');

      Get.back();
      Get.snackbar('Success', 'Profile updated successfully.');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: $e');
      Get.snackbar('Error', e.message ?? 'Failed to update profile.');
    } catch (e) {
      print('Exception: $e');
      Get.snackbar('Error', 'Failed to update profile.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoURL;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF73964A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _pickedImage != null
                    ? FileImage(_pickedImage!)
                    : (photoUrl != null
                        ? NetworkImage(photoUrl) as ImageProvider
                        : const AssetImage('assets/images/profile.jpg')),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    backgroundColor: Colors.white70,
                    radius: 18,
                    child: Icon(Icons.camera_alt, color: Colors.grey[800]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF73964A),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
