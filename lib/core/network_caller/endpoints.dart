// const String baseUrl = 'http://10.10.13.26:8000';
//const String baseUrl = 'https://yearningly-stemlike-shavon.ngrok-free.dev';
const String baseUrl = 'https://backend.qurany.pro';

// Auth Endpoints
const String googleAuthEndpoint = '$baseUrl/api/user/auth/google';
const String guestLoginEndpoint = '$baseUrl/api/user/guest';

// Quran Endpoints
const String quranSurahEndpoint = '$baseUrl/api/auth/quran/surah';
const String quranSurahDetailEndpoint = '$baseUrl/api/auth/quran/surah/';
const String quranSurahInfoEndpoint = '$baseUrl/api/quran/surah-details/';
const String randomVerseEndpoint = '$baseUrl/api/auth/quran/random/verse';
const String aiVerseReflectionEndpoint =
    '$baseUrl/api/auth/quran/random/verse/ai/';
const String tafsirEndpoint = '$baseUrl/api/quran/tafsir/';
const String juzEndpoint = '$baseUrl/api/auth/quran/juz';

// Bookmark Endpoints
const String bookmarkSurahEndpoint = '$baseUrl/api/auth/bookmark/surah/';
const String bookmarkVerseEndpoint = '$baseUrl/api/auth/bookmark/verse';
const String azkarBookmarkEndpoint = '$baseUrl/api/auth/azkar/bookmark';
const String historyBookmarkEndpoint = '$baseUrl/api/auth/history/bookmark/';
const String deleteHistoryBookmarkEndpoint =
    '$baseUrl/api/auth/history/bookmark/delete/';

// Azkar Endpoints
const String azkarEndpoint = '$baseUrl/api/auth/azkar';
const String azkarGroupEndpoint = '$baseUrl/api/auth/azkar/grouped';

// History & Progress Endpoints
const String historyEndpoint = '$baseUrl/api/auth/history';
const String surahProgressEndpoint = '$baseUrl/api/progress/surah';
const String verseProgressEndpoint = '$baseUrl/api/progress';

// Note Endpoints
const String noteEndpoint = '$baseUrl/api/auth/note';

// Knowledge Endpoints
const String knowledgeBaseUrl = '$baseUrl/auth/knowledge';

// AI Endpoints
const String askAiChatEndpoint = '$baseUrl/api/auth/ai/chat';
const String avgAccuracyEndpoint =
    '$baseUrl/api/auth/ai/pronunciation/avg-accuracy';
const String completedVersesEndpoint =
    '$baseUrl/api/auth/ai/pronunciation/completed/verses';
const String completedSurahEndpoint =
    '$baseUrl/api/auth/ai/pronunciation/completed/surah';
const String recitationCheckEndpoint =
    '$baseUrl/api/auth/ai/pronunciation/recite';

// Subscription Endpoints
const String subscriptionStatusEndpoint =
    '$baseUrl/api/auth/subscription/status';

// Referral Endpoints
const String referralAddCodeEndpoint = '$baseUrl/api/auth/referral/add-code/';
const String myReferralCodeEndpoint = '$baseUrl/api/auth/referral/my-ref-code';

// External API Endpoints - Ayahlight
const String islamicMiscBaseUrl = 'https://api.ayahlight.co.uk/api/v1/misc';
const String hijriSpecialDaysEndpoint =
    '$islamicMiscBaseUrl/all-hijri-special-days/';

// External API Endpoints - IslamicAPI
const String islamicApiBaseUrl = 'https://islamicapi.com/api/v1';
const String prayerTimeEndpoint = '$islamicApiBaseUrl/prayer-time/';
