import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qurany/core/const/static_surah_data.dart';
import 'package:qurany/feature/home/services/quran_service.dart';
import 'package:qurany/feature/profile/model/note_list_item.dart';
import 'package:qurany/feature/quran/view/surah_reading_screen.dart';

// ─── Controller ──────────────────────────────────────────────────────────────

class NotesController extends GetxController {
  final QuranService _service = QuranService();

  RxList<NoteListItem> notes = <NoteListItem>[].obs;
  RxBool isLoading = true.obs;
  RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    try {
      isLoading(true);
      error('');
      final fetched = await _service.fetchNotes();
      notes.assignAll(fetched);
    } catch (e) {
      error(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<bool> deleteNote(String noteId) async {
    final ok = await _service.deleteNote(noteId);
    if (ok) notes.removeWhere((n) => n.id == noteId);
    return ok;
  }

  Future<bool> updateNote({
    required String noteId,
    required String description,
    required int surahId,
    required int verseId,
  }) async {
    final ok = await _service.updateNote(
      noteId: noteId,
      description: description,
      surahId: surahId,
      verseId: verseId,
    );
    if (ok) await fetchNotes();
    return ok;
  }
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotesController());

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, controller),
            SizedBox(height: 16.h),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.error.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48.sp,
                          color: Colors.red[300],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Failed to load notes',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: controller.fetchNotes,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (controller.notes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 64.sp,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'No notes yet',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchNotes,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: controller.notes.length,
                    itemBuilder: (context, index) => _buildNoteCard(
                      context,
                      controller.notes[index],
                      index,
                      controller,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, NotesController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16.sp,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                "Notes",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  Widget _buildNoteCard(
    BuildContext context,
    NoteListItem note,
    int index,
    NotesController controller,
  ) {
    final colors = [
      const Color(0xFF2E7D32),
      const Color(0xFFFF9800),
      const Color(0xFF2196F3),
    ];
    final accentColor = colors[index % colors.length];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border(
          left: BorderSide(color: accentColor, width: 4.w),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              note.title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            SizedBox(height: 4.h),

            // Arabic verse text (if available)
            if (note.verseData != null) ...[
              SizedBox(height: 4.h),
              Text(
                note.verseData!.text,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontFamily: 'Arial',
                  height: 1.8,
                  color: Colors.black87,
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 4.h),
              Text(
                note.verseData!.translation,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 8.h),
            ],

            // Date and surah info
            Text(
              '${note.formattedDate} • Surah ${note.surahId} : ${note.verseId}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            ),
            SizedBox(height: 12.h),

            // Note description
            Text(
              note.description,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),

            // Bottom row
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    final surahList = StaticSurahData.getAllSurahs();
                    final surah = surahList.firstWhere(
                      (s) => s.number == note.surahId,
                      orElse: () => surahList.first,
                    );
                    Get.delete<SurahReadingController>();
                    Get.to(
                      () => SurahReadingScreen(
                        surahId: surah.number,
                        surahName: surah.englishName,
                        arabicName: surah.arabicName,
                        meaning: surah.translation,
                        origin: surah.revelationType,
                        ayaCount: surah.totalVerses,
                        translation: surah.translation,
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    child: Text(
                      "Read Ayah",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Edit
                GestureDetector(
                  onTap: () => _showEditDialog(context, note, controller),
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 18.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Delete
                GestureDetector(
                  onTap: () => _showDeleteDialog(context, note, controller),
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: 18.sp,
                      color: Colors.red[400],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    NoteListItem note,
    NotesController controller,
  ) {
    final textController = TextEditingController(text: note.description);

    showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          bool isSaving = false;
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFF2F7D33),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      Column(
                        children: [
                          Text(
                            'Surah ${note.surahId}, Aya ${note.verseId}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Edit Note',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white54, width: 1.2),
                    ),
                    child: TextField(
                      controller: textController,
                      maxLines: 5,
                      minLines: 5,
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: 'Edit your note...',
                        hintStyle: TextStyle(
                          color: Colors.white54,
                          fontSize: 14.sp,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      cursorColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              final text = textController.text.trim();
                              if (text.isEmpty) return;
                              setState(() => isSaving = true);
                              final ok = await controller.updateNote(
                                noteId: note.id,
                                description: text,
                                surahId: note.surahId,
                                verseId: note.verseId,
                              );
                              if (ctx.mounted) Navigator.pop(ctx);
                              Get.snackbar(
                                ok ? 'Saved' : 'Error',
                                ok ? 'Note updated' : 'Failed to update note',
                                backgroundColor: ok
                                    ? const Color(0xFF2E7D32)
                                    : Colors.red,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2E7D32),
                        disabledBackgroundColor: Colors.white60,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        elevation: 0,
                      ),
                      child: isSaving
                          ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF2E7D32),
                              ),
                            )
                          : Text(
                              'Save Note',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    NoteListItem note,
    NotesController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          bool isDeleting = false;
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Icon(
                        Icons.close,
                        size: 24.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: 32.sp,
                      color: Colors.red[400],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Delete This Note?",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "This action can't be undone. Do you want to continue?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  GestureDetector(
                    onTap: isDeleting
                        ? null
                        : () async {
                            setState(() => isDeleting = true);
                            final ok = await controller.deleteNote(note.id);
                            if (ctx.mounted) Navigator.pop(ctx);
                            Get.snackbar(
                              ok ? 'Deleted' : 'Error',
                              ok ? 'Note deleted' : 'Failed to delete note',
                              backgroundColor: ok
                                  ? Colors.grey[800]
                                  : Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: isDeleting ? Colors.red[300] : Colors.red,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Center(
                        child: isDeleting
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Delete",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
