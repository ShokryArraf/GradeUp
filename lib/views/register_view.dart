import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grade_up/constants/routes.dart';
import 'package:grade_up/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _fullName;
  late final TextEditingController _newSchoolController;

  String _role = 'Student'; // Default role
  int _selectedGrade = 1; // Default grade for students
  String _selectedSchool = 'Braude High School'; // Default school
  final Set<String> _selectedLessons = {}; // Selected lessons for students
  // List of available schools
  final List<String> _availableSchools = [];
  final Map<String, Set<int>> _lessonGradeMap =
      {}; // Map lesson to grades for teachers

  // List of available lessons
  final List<String> _availableLessons = [
    'math',
    'english',
    'hebrew',
    'geography',
    'biology',
    'chemistry',
  ];

  void _fetchSchoolsFromFirestore() async {
    final schoolsCollection = FirebaseFirestore.instance.collection('schools');
    final querySnapshot = await schoolsCollection.get();

    setState(() {
      for (var doc in querySnapshot.docs) {
        final schoolName = doc['name'] as String?;
        if (schoolName != null && !_availableSchools.contains(schoolName)) {
          _availableSchools.add(schoolName);
        }
      }
      _availableSchools.sort(); // Sort alphabetically
    });
  }

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    _fullName = TextEditingController();
    _newSchoolController = TextEditingController();
    _fetchSchoolsFromFirestore(); // Fetch schools during initialization
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _fullName.dispose();
    _newSchoolController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    final email = _email.text.trim();
    final password = _password.text.trim();
    final fullName = _fullName.text.trim();

    try {
      // Firebase Auth: Create user
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Firestore: Save user data
      final userId = userCredential.user?.uid;
      if (userId != null) {
        final schoolDoc = FirebaseFirestore.instance
            .collection('schools')
            .doc(_selectedSchool);
        schoolDoc.set({
          'exists':
              true, // Placeholder field to make the document visible in queries
          'name': _selectedSchool
        }, SetOptions(merge: true));

        if (_role == 'Teacher') {
          // Set display name with role and school name
          await userCredential.user
              ?.updateDisplayName("$_role: $fullName: $_selectedSchool");
          // Save teacher to the school's teachers subcollection
          final teacherData = {
            'name': fullName,
            'teachingLessons': _lessonGradeMap.map((lesson, grades) =>
                MapEntry(lesson, grades.toList())), // Convert Set to List
          };

          await schoolDoc.collection('teachers').doc(userId).set(teacherData);
        } else if (_role == 'Student') {
          // Set display name with role and school name
          await userCredential.user?.updateDisplayName(
              "$_role: $fullName: $_selectedSchool: $_selectedGrade");
          // Save student to the school's grades subcollection
          final studentData = {
            'name': fullName,
            'grade': _selectedGrade,
            'enrolledLessons': _selectedLessons.toList(),
          };

          await schoolDoc
              .collection('grades')
              .doc(_selectedGrade
                  .toString()) // Grade document ID is the grade number
              .collection('students')
              .doc(userId)
              .set(studentData);
        }
      }

      // Navigate to login
      Navigator.of(context)
          .pushNamedAndRemoveUntil(loginRoute, (route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        await showErrorDialog(context, '.סיסמא חלשה');
      } else if (e.code == 'email-already-in-use') {
        await showErrorDialog(context, '.דוא"ל כבר בשימוש');
      } else if (e.code == 'invalid-email') {
        await showErrorDialog(context, '.דוא"ל לא תקין');
      } else {
        await showErrorDialog(context, 'שגיאה: ${e.message}');
      }
    } catch (e) {
      await showErrorDialog(context, 'שגיאה: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('הרשמה'),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          )),
      body: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Full Name Input
                    TextField(
                      controller: _fullName,
                      decoration: const InputDecoration(hintText: 'שם מלא'),
                    ),
                    const SizedBox(height: 8),
                    // Email Input
                    TextField(
                      controller: _email,
                      decoration: const InputDecoration(hintText: 'הכנס דוא"ל'),
                    ),
                    const SizedBox(height: 8),
                    // Password Input
                    TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: 'הכנס סיסמא'),
                    ),
                    const SizedBox(height: 16),
                    // Role Selection Dropdown
                    DropdownButton<String>(
                      value: _role,
                      items: ['Student', 'Teacher'].map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _role = value!;
                          _selectedLessons.clear();
                          _lessonGradeMap.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // School Selection Dropdown
                    DropdownButton<String>(
                      value: _selectedSchool,
                      items: _availableSchools.map((school) {
                        return DropdownMenuItem(
                          value: school,
                          child: Text(school),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSchool = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _newSchoolController,
                          decoration: const InputDecoration(
                            hintText: 'הכנס שם בית ספר חדש',
                            hintTextDirection:
                                TextDirection.rtl, // Hint text direction
                          ),
                          textDirection: TextDirection
                              .rtl, // Right-to-left text direction for typing
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            final newSchool = _newSchoolController.text.trim();
                            if (newSchool.isNotEmpty &&
                                !_availableSchools.contains(newSchool)) {
                              setState(() {
                                _availableSchools.add(newSchool);
                                _selectedSchool =
                                    newSchool; // Automatically select the new school
                              });

                              // Add the new school to Firestore
                              FirebaseFirestore.instance
                                  .collection('schools')
                                  .doc(newSchool)
                                  .set({
                                'exists': true, // Placeholder field
                                'name': newSchool,
                              });
                            }
                          },
                          child: const Text('הוסף בית ספר חדש'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    // Student-Specific Input
                    if (_role == 'Student') ...[
                      const Text('בחר הכיתה שלך'),
                      DropdownButton<int>(
                        value: _selectedGrade,
                        items:
                            List.generate(8, (index) => index + 1).map((grade) {
                          return DropdownMenuItem(
                            value: grade,
                            child: Text('כיתה $grade'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGrade = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('בחר את השיעורים הרשומים שלך'),
                      Column(
                        children: _availableLessons.map((lesson) {
                          return CheckboxListTile(
                            title: Text(lesson),
                            value: _selectedLessons.contains(lesson),
                            onChanged: (isSelected) {
                              setState(() {
                                if (isSelected == true) {
                                  _selectedLessons.add(lesson);
                                } else {
                                  _selectedLessons.remove(lesson);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                    // Teacher-Specific Input
                    if (_role == 'Teacher') ...[
                      const Text('בחר שיעורים וכיתות'),
                      Column(
                        children: _availableLessons.map((lesson) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CheckboxListTile(
                                title: Text(lesson),
                                value: _lessonGradeMap.containsKey(lesson),
                                onChanged: (isSelected) {
                                  setState(() {
                                    if (isSelected == true) {
                                      _lessonGradeMap[lesson] = {};
                                    } else {
                                      _lessonGradeMap.remove(lesson);
                                    }
                                  });
                                },
                              ),
                              if (_lessonGradeMap.containsKey(lesson))
                                Wrap(
                                  spacing: 8.0,
                                  children:
                                      List.generate(8, (index) => index + 1)
                                          .map((grade) {
                                    return FilterChip(
                                      label: Text('כיתה $grade'),
                                      selected: _lessonGradeMap[lesson]!
                                          .contains(grade),
                                      onSelected: (isSelected) {
                                        setState(() {
                                          if (isSelected) {
                                            _lessonGradeMap[lesson]!.add(grade);
                                          } else {
                                            _lessonGradeMap[lesson]!
                                                .remove(grade);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Register Button
                    TextButton(
                      onPressed: _registerUser,
                      child: const Text('הרשמה'),
                    ),
                    // Login Button
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            loginRoute, (route) => false);
                      },
                      child: const Text('!כבר רשום? כנס כאן'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
