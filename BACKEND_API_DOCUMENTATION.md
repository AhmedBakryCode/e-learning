# 📚 E-Learning Platform — Backend API Documentation

> **Base URL:** `https://api.elearning.dev/api/v1`  
> **Authentication:** Bearer Token (JWT)  
> **Content-Type:** `application/json` (إلا في حالات رفع الملفات فتكون `multipart/form-data`)

---

## 📋 جدول المحتويات

1. [Authentication — المصادقة](#1-authentication--المصادقة)
2. [Courses — الكورسات](#2-courses--الكورسات)
3. [Course Videos — فيديوهات الكورس](#3-course-videos--فيديوهات-الكورس)
4. [Students — الطلاب](#4-students--الطلاب)
5. [Progress — تتبع التقدم](#5-progress--تتبع-التقدم)
6. [Video Watch Progress — تقدم مشاهدة الفيديو](#6-video-watch-progress--تقدم-مشاهدة-الفيديو)
7. [Comments — التعليقات](#7-comments--التعليقات)
8. [Notifications — الإشعارات](#8-notifications--الإشعارات)
9. [Payment — الدفع](#9-payment--الدفع)
10. [Database Schema — هيكل قاعدة البيانات](#10-database-schema--هيكل-قاعدة-البيانات)
11. [Error Handling — التعامل مع الأخطاء](#11-error-handling--التعامل-مع-الأخطاء)
12. [ملاحظات عامة للباك اند](#12-ملاحظات-عامة-للباك-اند)

---

## 1. Authentication — المصادقة

> **Prefix:** `/auth`  
> **الوصف:** إدارة تسجيل الدخول، التسجيل، والمستخدم الحالي.

---

### 1.1 — تسجيل الدخول

| Property | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/auth/login` |
| **Auth** | ❌ لا يحتاج Token |

**Request Body:**
```json
{
  "email": "teacher@elevate.academy",
  "password": "your_password"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "admin-001",
    "name": "Ava Teacher",
    "email": "teacher@elevate.academy",
    "role": "admin"
  }
}
```

> 🔑 **ملاحظة:** الـ `role` يكون إما `"admin"` (المدرس/الإدمن) أو `"student"` (الطالب). الـ Flutter App يستخدم هذا لتحديد لوحة التحكم المناسبة.

---

### 1.2 — تسجيل مستخدم جديد (طالب)

| Property | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/auth/register` |
| **Auth** | ❌ لا يحتاج Token |

**Request Body:**
```json
{
  "name": "Noah Student",
  "email": "student@elevate.academy",
  "password": "your_password",
  "role": "student"
}
```

**Response (201 Created):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "student-xyz",
    "name": "Noah Student",
    "email": "student@elevate.academy",
    "role": "student"
  }
}
```

---

### 1.3 — جلب المستخدم الحالي

| Property | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/auth/me` |
| **Auth** | ✅ Bearer Token |

**Response (200 OK):**
```json
{
  "id": "admin-001",
  "name": "Ava Teacher",
  "email": "teacher@elevate.academy",
  "role": "admin"
}
```

---

### 1.4 — تسجيل الخروج

| Property | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/auth/logout` |
| **Auth** | ✅ Bearer Token |

**Response (200 OK):**
```json
{
  "message": "Logged out successfully"
}
```

---

## 2. Courses — الكورسات

> **Prefix:** `/courses`  
> **الوصف:** إدارة الكورسات كاملةً (CRUD). المدرس (admin) يشوف كل الكورسات. الطالب يشوف فقط المنشورة (`isPublished: true`).

---

### 2.1 — جلب كل الكورسات

| Property | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/courses` |
| **Auth** | ✅ Bearer Token |

**Query Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `role` | `string` | ❌ | `admin` أو `student` — يفلتر النتائج حسب الدور. إذا كان `student` يُرجع فقط `isPublished: true` |
| `featured` | `boolean` | ❌ | إذا `true` يُرجع فقط الكورسات المميزة (`isFeatured: true`) |

**Response (200 OK):**
```json
[
  {
    "id": "course-001",
    "title": "Flutter for Scalable Products",
    "description": "Architect modular Flutter apps...",
    "instructorName": "Ava Morgan",
    "category": "Development",
    "level": "Advanced",
    "duration": "8h 20m",
    "totalLessons": 24,
    "enrolledCount": 312,
    "rating": 4.9,
    "completionPercent": 0.65,
    "isFeatured": true,
    "isPublished": true
  }
]
```

---

### 2.2 — جلب كورس بـ ID

| Property | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/courses/:id` |
| **Auth** | ✅ Bearer Token |

**Response (200 OK):** نفس Object الكورس أعلاه

**Response (404 Not Found):**
```json
{ "error": "Course not found" }
```

---

### 2.3 — إنشاء كورس جديد

| Property | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/courses` |
| **Auth** | ✅ Bearer Token (admin فقط) |

**Request Body:**
```json
{
  "title": "New Course Title",
  "description": "Course description here",
  "instructorName": "Instructor Name",
  "category": "Development",
  "level": "Beginner",
  "isPublished": false
}
```

**قيم صالحة لـ `level`:** `"Beginner"` | `"Intermediate"` | `"Advanced"`  
**قيم صالحة لـ `category`:** `"Development"` | `"Design"` | `"Analytics"` | `"AI"` | `"Teaching"`

**Response (201 Created):** Object الكورس مع `id` جديد و:
```json
{
  "id": "course-1748291234567",
  "title": "New Course Title",
  "duration": "0h 00m",
  "totalLessons": 0,
  "enrolledCount": 0,
  "rating": 0,
  "completionPercent": 0,
  "isFeatured": false,
  ...
}
```

---

### 2.4 — تعديل كورس

| Property | Value |
|---|---|
| **Method** | `PUT` |
| **Endpoint** | `/courses/:id` |
| **Auth** | ✅ Bearer Token (admin فقط) |

**Request Body:** نفس حقول الإنشاء (كلها مطلوبة)

**Response (200 OK):** Object الكورس المحدّث

---

### 2.5 — حذف كورس

| Property | Value |
|---|---|
| **Method** | `DELETE` |
| **Endpoint** | `/courses/:id` |
| **Auth** | ✅ Bearer Token (admin فقط) |

**Response (200 OK):**
```json
{ "message": "Course deleted successfully" }
```

---

## 3. Course Videos — فيديوهات الكورس

> **Prefix:** `/courses/:courseId/videos`  
> **الوصف:** إدارة فيديوهات كل كورس.

---

### 3.1 — جلب فيديوهات كورس

| Property | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/courses/:courseId/videos` |
| **Auth** | ✅ Bearer Token |

**Response (200 OK):**
```json
[
  {
    "id": "video-001",
    "courseId": "course-001",
    "title": "Welcome and course roadmap",
    "description": "Set expectations, outcomes...",
    "videoUrl": "https://cdn.example.com/videos/video-001.mp4",
    "duration": "08:12",
    "progress": 1.0,
    "isPreview": true,
    "isUploaded": true
  }
]
```

> 📌 **ملاحظة `duration`:** يُخزَّن كـ string بصيغة `"MM:SS"` (مثلاً `"08:12"`)  
> 📌 **ملاحظة `progress`:** قيمة بين `0.0` و `1.0` تمثل نسبة تقدم الطالب في هذا الفيديو  
> 📌 **`isPreview`:** إذا `true`، الطالب يمكنه مشاهدته بدون اشتراك  
> 📌 **`isUploaded`:** إذا `false`، الفيديو لم يُرفع بعد

---

### 3.2 — رفع فيديو جديد

| Property | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/courses/:courseId/videos` |
| **Auth** | ✅ Bearer Token (admin فقط) |
| **Content-Type** | `multipart/form-data` |

**Form Fields:**

| Field | Type | Required | Description |
|---|---|---|---|
| `title` | `string` | ✅ | عنوان الفيديو |
| `description` | `string` | ✅ | وصف الفيديو |
| `video` | `file` | ✅ | ملف الفيديو (mp4, mov, avi) |
| `isPreview` | `boolean` | ❌ | هل متاح كمعاينة مجانية؟ (default: `false`) |

> ⚠️ **بديل للـ URL:** يمكن إرسال `videoUrl` كـ string بدلاً من رفع ملف فعلي إذا كان الفيديو مُستضاف خارجياً (YouTube/Vimeo/CDN).

**Response (201 Created):**
```json
{
  "id": "video-1748291234567",
  "courseId": "course-001",
  "title": "New Video Title",
  "description": "Video description",
  "videoUrl": "https://cdn.example.com/videos/video-xyz.mp4",
  "duration": "00:00",
  "progress": 0,
  "isPreview": false,
  "isUploaded": true
}
```

> ✅ **مهم:** بعد إضافة الفيديو، الباك اند يجب أن يُحدّث `totalLessons` في الكورس تلقائياً.

---

## 4. Students — الطلاب

> **Prefix:** `/students`  
> **الوصف:** إدارة بيانات الطلاب. متاح للمدرس فقط.

---

### 4.1 — جلب كل الطلاب

| Property | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/students` |
| **Auth** | ✅ Bearer Token (admin فقط) |

**Response (200 OK):**
```json
[
  {
    "id": "student-001",
    "name": "Olivia Harper",
    "email": "olivia@academy.com",
    "activeCourses": 4,
    "completionRate": 0.81,
    "phoneNumber": "+201012345678",
    "parentPhoneNumber": "+201087654321",
    "profileImageUrl": "https://cdn.example.com/profiles/olivia.jpg"
  }
]
```

---

### 4.2 — جلب طالب بـ ID

| Property | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/students/:id` |
| **Auth** | ✅ Bearer Token |

**Response (200 OK):** نفس Object الطالب أعلاه

---

### 4.3 — إضافة طالب جديد

| Property | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/students` |
| **Auth** | ✅ Bearer Token (admin فقط) |
| **Content-Type** | `multipart/form-data` |

**Form Fields:**

| Field | Type | Required | Description |
|---|---|---|---|
| `name` | `string` | ✅ | الاسم الكامل للطالب |
| `email` | `string` | ✅ | البريد الإلكتروني (يجب أن يكون unique) |
| `password` | `string` | ✅ | كلمة المرور (الباك اند يعمل hash) |
| `phoneNumber` | `string` | ❌ | رقم هاتف الطالب |
| `parentPhoneNumber` | `string` | ❌ | رقم هاتف ولي الأمر |
| `profileImage` | `file` | ❌ | صورة البروفايل |

**Response (201 Created):**
```json
{
  "id": "student-1748291234567",
  "name": "New Student",
  "email": "new@academy.com",
  "activeCourses": 0,
  "completionRate": 0,
  "phoneNumber": "+201012345678",
  "parentPhoneNumber": null,
  "profileImageUrl": null
}
```

---

### 4.4 — تعديل بيانات طالب

| Property | Value |
|---|---|
| **Method** | `PUT` |
| **Endpoint** | `/students/:id` |
| **Auth** | ✅ Bearer Token (admin فقط) |
| **Content-Type** | `multipart/form-data` |

**Form Fields:** نفس حقول الإنشاء (يمكن إرسال الحقول المراد تغييرها فقط)

**Response (200 OK):** Object الطالب المحدّث

---

### 4.5 — حذف طالب

| Property | Value |
|---|---|
| **Method** | `DELETE` |
| **Endpoint** | `/students/:id` |
| **Auth** | ✅ Bearer Token (admin فقط) |

**Response (200 OK):**
```json
{ "message": "Student deleted successfully" }
```

---

### 4.6 — جلب أفضل الطلاب (Top Students)

| Property | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/students/top` |
| **Auth** | ✅ Bearer Token (admin فقط) |

**Query Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `limit` | `integer` | ❌ | `5` | عدد الطلاب المطلوب إرجاعهم |

**Response (200 OK):** قائمة طلاب مرتبة تنازلياً حسب `completionRate`

---

## 5. Progress — تتبع التقدم

> **Prefix:** `/progress`  
> **الوصف:** تتبع تقدم الطالب في الكورسات، والتسجيل في الكورسات.

---

### 5.1 — جلب تقدم الطلاب

| Property | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/progress` |
| **Auth** | ✅ Bearer Token |

**Query Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `studentId` | `string` | ❌ | إذا أُرسل يُرجع تقدم طالب معين. إذا لم يُرسل يُرجع تقدم كل الطلاب (للمدرس فقط) |

**Response (200 OK):**
```json
[
  {
    "id": "progress-student-001-course-001",
    "studentId": "student-001",
    "courseId": "course-001",
    "courseTitle": "Flutter for Scalable Products",
    "completionPercent": 0.65,
    "currentLesson": 3,
    "totalLessons": 4,
    "watchedVideos": 3,
    "lastVideoId": "video-003",
    "lastVideoTitle": "Building premium UI systems"
  }
]
```

---

### 5.2 — تسجيل طالب في كورس (Enroll)

| Property | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/progress/enroll` |
| **Auth** | ✅ Bearer Token |

**Request Body:**
```json
{
  "studentId": "student-001",
  "courseId": "course-001"
}
```

**Response (201 Created):**
```json
{
  "id": "progress-student-001-course-001",
  "studentId": "student-001",
  "courseId": "course-001",
  "courseTitle": "Flutter for Scalable Products",
  "completionPercent": 0,
  "currentLesson": 1,
  "totalLessons": 4,
  "watchedVideos": 0,
  "lastVideoId": null,
  "lastVideoTitle": null
}
```

> 📌 **ملاحظة:** هذا الـ endpoint يُستدعى بعد نجاح الدفع مباشرةً. يُنشئ سجل تقدم لكل فيديو في الكورس بـ `watchedSeconds: 0`.

---

### 5.3 — تحديث تقدم الطالب في كورس

| Property | Value |
|---|---|
| **Method** | `PUT` |
| **Endpoint** | `/progress/:progressId` |
| **Auth** | ✅ Bearer Token |

**Request Body:**
```json
{
  "completionPercent": 0.75,
  "currentLesson": 3
}
```

**Response (200 OK):** Object التقدم المحدّث

---

## 6. Video Watch Progress — تقدم مشاهدة الفيديو

> **Prefix:** `/progress/video`  
> **الوصف:** تتبع تقدم مشاهدة الطالب لكل فيديو على حدة (بالثواني).

---

### 6.1 — جلب تقدم مشاهدة فيديوهات كورس

| Property | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/progress/video` |
| **Auth** | ✅ Bearer Token |

**Query Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `studentId` | `string` | ✅ | ID الطالب |
| `courseId` | `string` | ✅ | ID الكورس |

**Response (200 OK):**
```json
[
  {
    "id": "student-001|course-001|video-001",
    "studentId": "student-001",
    "courseId": "course-001",
    "videoId": "video-001",
    "watchedSeconds": 492,
    "totalDurationSeconds": 492,
    "isCompleted": true,
    "lastWatchedAt": "2026-03-26T10:30:00.000Z"
  }
]
```

---

### 6.2 — حفظ تقدم مشاهدة فيديو

| Property | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/progress/video/save` |
| **Auth** | ✅ Bearer Token |

> 📡 **يُستدعى دورياً** كل 10-30 ثانية أثناء مشاهدة الفيديو لحفظ الموضع الحالي.

**Request Body:**
```json
{
  "studentId": "student-001",
  "courseId": "course-001",
  "videoId": "video-002",
  "watchedSeconds": 350
}
```

**Response (200 OK):**
```json
{
  "id": "student-001|course-001|video-002",
  "studentId": "student-001",
  "courseId": "course-001",
  "videoId": "video-002",
  "watchedSeconds": 350,
  "totalDurationSeconds": 888,
  "isCompleted": false,
  "lastWatchedAt": "2026-03-29T11:00:00.000Z"
}
```

> ✅ **مهم:** الباك اند يُحدّث `isCompleted` تلقائياً إذا كان `watchedSeconds >= totalDurationSeconds`.

---

### 6.3 — تحديد فيديو كمكتمل

| Property | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/progress/video/complete` |
| **Auth** | ✅ Bearer Token |

**Request Body:**
```json
{
  "studentId": "student-001",
  "courseId": "course-001",
  "videoId": "video-002"
}
```

**Response (200 OK):**
```json
{
  "id": "student-001|course-001|video-002",
  "studentId": "student-001",
  "courseId": "course-001",
  "videoId": "video-002",
  "watchedSeconds": 888,
  "totalDurationSeconds": 888,
  "isCompleted": true,
  "lastWatchedAt": "2026-03-29T11:00:00.000Z"
}
```

---

## 7. Comments — التعليقات

> **Prefix:** `/comments`  
> **الوصف:** تعليقات الطلاب على الفيديوهات.

---

### 7.1 — جلب تعليقات

| Property | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/comments` |
| **Auth** | ✅ Bearer Token |

**Query Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `courseId` | `string` | ✅ | ID الكورس |
| `videoId` | `string` | ❌ | إذا أُرسل يُرجع تعليقات فيديو معين فقط |

**Response (200 OK):**
```json
[
  {
    "id": "comment-001",
    "courseId": "course-001",
    "videoId": "video-002",
    "authorName": "Sophia Lane",
    "courseTitle": "Flutter for Scalable Products",
    "message": "The architecture breakdown around repositories was excellent.",
    "timeLabel": "Today",
    "createdAt": "2026-03-26T10:30:00.000Z"
  }
]
```

> 📌 **ترتيب النتائج:** تنازلياً حسب `createdAt` (الأحدث أولاً)

---

### 7.2 — إضافة تعليق

| Property | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/comments` |
| **Auth** | ✅ Bearer Token |

**Request Body:**
```json
{
  "courseId": "course-001",
  "videoId": "video-002",
  "authorName": "Sophia Lane",
  "courseTitle": "Flutter for Scalable Products",
  "message": "Great explanation, thank you!"
}
```

> 📌 **ملاحظة:** `authorName` و `courseTitle` يمكن استخلاصهما من الباك اند باستخدام `courseId` و ID المستخدم الحالي، لكن الـ Flutter يُرسلهما مباشرةً لتبسيط الـ response.

**Response (201 Created):**
```json
{
  "id": "comment-1748291234567",
  "courseId": "course-001",
  "videoId": "video-002",
  "authorName": "Sophia Lane",
  "courseTitle": "Flutter for Scalable Products",
  "message": "Great explanation, thank you!",
  "timeLabel": "Just now",
  "createdAt": "2026-03-29T11:20:00.000Z"
}
```

---

## 8. Notifications — الإشعارات

> **Prefix:** `/notifications`  
> **الوصف:** إشعارات المنصة. المدرس ينشئها، الطلاب يستقبلونها.

---

### 8.1 — جلب كل الإشعارات

| Property | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/notifications` |
| **Auth** | ✅ Bearer Token |

> 📌 **للطالب:** يُرجع إشعاراته الخاصة + الإشعارات العامة للكورسات المسجل فيها.  
> 📌 **للمدرس:** يُرجع كل الإشعارات التي أنشأها.

**Response (200 OK):**
```json
[
  {
    "id": "notification-001",
    "title": "Course review completed",
    "message": "The latest Flutter architecture course is ready to publish.",
    "timeLabel": "2h ago",
    "isRead": false,
    "audienceLabel": "All students",
    "zoomMeetingLink": null,
    "targetCourseId": null,
    "createdAt": "2026-03-29T09:00:00.000Z"
  },
  {
    "id": "notification-003",
    "title": "Weekly live Q&A",
    "message": "Join the live Zoom session to review this week's roadmap.",
    "timeLabel": "Monday",
    "isRead": false,
    "audienceLabel": "Course: course-001",
    "zoomMeetingLink": "https://zoom.us/j/1234567890",
    "targetCourseId": "course-001",
    "createdAt": "2026-03-24T10:00:00.000Z"
  }
]
```

---

### 8.2 — إنشاء إشعار جديد

| Property | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/notifications` |
| **Auth** | ✅ Bearer Token (admin فقط) |

**Request Body:**
```json
{
  "title": "New Live Session",
  "message": "There's a live session tomorrow at 8 PM. Don't miss it!",
  "zoomMeetingLink": "https://zoom.us/j/9876543210",
  "targetCourseId": "course-001"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `title` | `string` | ✅ | عنوان الإشعار |
| `message` | `string` | ✅ | نص الإشعار |
| `zoomMeetingLink` | `string` | ✅ | رابط Zoom (يمكن أن يكون فارغاً `""`) |
| `targetCourseId` | `string` | ❌ | إذا أُرسل يُرسل الإشعار لطلاب الكورس دا فقط. إذا لم يُرسل يُرسل لكل الطلاب |

**Response (201 Created):**
```json
{
  "id": "notification-1748291234567",
  "title": "New Live Session",
  "message": "There's a live session tomorrow at 8 PM. Don't miss it!",
  "timeLabel": "Just now",
  "isRead": false,
  "audienceLabel": "Course: course-001",
  "zoomMeetingLink": "https://zoom.us/j/9876543210",
  "targetCourseId": "course-001",
  "createdAt": "2026-03-29T11:20:00.000Z"
}
```

---

### 8.3 — تحديد إشعار كمقروء

| Property | Value |
|---|---|
| **Method** | `PATCH` |
| **Endpoint** | `/notifications/:id/read` |
| **Auth** | ✅ Bearer Token |

**Response (200 OK):**
```json
{ "message": "Notification marked as read" }
```

---

### 8.4 — Real-time Notifications (WebSocket / SSE)

> 📡 **الوصف:** الـ Flutter App يستخدم `Stream` لمراقبة الإشعارات الجديدة في الوقت الحقيقي.

**الخيارات المتاحة:**

| Option | Endpoint | Description |
|---|---|---|
| **WebSocket** | `wss://api.elearning.dev/ws/notifications` | يمكن الاستخدام مع `web_socket_channel` |
| **SSE (Server-Sent Events)** | `GET /notifications/stream` | أبسط للـ read-only streaming |
| **Polling** | `GET /notifications` كل 30 ثانية | أبسط تطبيق، لكن أقل كفاءة |

> 💡 **توصية:** استخدم **SSE** أو **WebSocket** لأن الـ App يعتمد على `Stream<List<Notification>>`.

---

## 9. Payment — الدفع

> **Prefix:** `/payment`  
> **الوصف:** معالجة عمليات الدفع والاشتراك في الكورسات.

---

### 9.1 — إنشاء طلب دفع

| Property | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/payment/initiate` |
| **Auth** | ✅ Bearer Token |

**Request Body:**
```json
{
  "courseId": "course-001",
  "studentId": "student-001",
  "paymentMethod": "card",
  "amount": 1500
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `courseId` | `string` | ✅ | ID الكورس المراد الاشتراك فيه |
| `studentId` | `string` | ✅ | ID الطالب |
| `paymentMethod` | `string` | ✅ | `"card"` أو `"fawry"` أو `"vodafone"` |
| `amount` | `number` | ✅ | المبلغ بالجنيه المصري (حالياً ثابت 1500 EGP) |

**Response (201 Created):**
```json
{
  "paymentId": "payment-xyz",
  "status": "pending",
  "redirectUrl": "https://payment-gateway.com/pay/xyz",
  "message": "Proceed to payment gateway"
}
```

---

### 9.2 — تأكيد نجاح الدفع (Webhook / Callback)

| Property | Value |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/payment/confirm` |
| **Auth** | 🔐 Webhook Secret |

> 📌 **هذا الـ endpoint** يُستدعى من بوابة الدفع (Fawry, Paymob, etc.) بعد نجاح العملية.

**Request Body:**
```json
{
  "paymentId": "payment-xyz",
  "courseId": "course-001",
  "studentId": "student-001",
  "status": "success",
  "transactionId": "tx-9876"
}
```

**Response (200 OK):** يُنشئ تلقائياً سجل في Progress لتسجيل الطالب في الكورس.

> ⚠️ **تنبيه مهم:** في الـ Flutter App الحالي، التسجيل يتم client-side مباشرةً بعد "محاكاة" الدفع (`EnrollInCourseUseCase`). في الباك اند الحقيقي، يجب أن يتم التسجيل **على الخادم فقط** بعد التحقق من نجاح الدفع لمنع التلاعب.

---

## 10. Database Schema — هيكل قاعدة البيانات

### 📊 جدول `users`

```sql
CREATE TABLE users (
    id              VARCHAR(50)  PRIMARY KEY,
    name            VARCHAR(255) NOT NULL,
    email           VARCHAR(255) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    role            ENUM('admin', 'student') NOT NULL DEFAULT 'student',
    phone_number    VARCHAR(20)  NULL,
    parent_phone    VARCHAR(20)  NULL,
    profile_image   VARCHAR(500) NULL,     -- URL الصورة على CDN
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

---

### 📊 جدول `courses`

```sql
CREATE TABLE courses (
    id               VARCHAR(50)   PRIMARY KEY,
    title            VARCHAR(255)  NOT NULL,
    description      TEXT          NOT NULL,
    instructor_name  VARCHAR(255)  NOT NULL,
    instructor_id    VARCHAR(50)   NULL,               -- FK -> users.id
    category         VARCHAR(100)  NOT NULL,
    level            ENUM('Beginner', 'Intermediate', 'Advanced') NOT NULL,
    duration         VARCHAR(20)   NOT NULL DEFAULT '0h 00m',  -- مثلاً "8h 20m"
    total_lessons    INT           NOT NULL DEFAULT 0,
    enrolled_count   INT           NOT NULL DEFAULT 0,
    rating           DECIMAL(3,2)  NOT NULL DEFAULT 0.00,
    completion_pct   DECIMAL(5,4)  NOT NULL DEFAULT 0.0000,   -- 0.0000 -> 1.0000
    is_featured      BOOLEAN       NOT NULL DEFAULT FALSE,
    is_published     BOOLEAN       NOT NULL DEFAULT FALSE,
    price            DECIMAL(10,2) NOT NULL DEFAULT 1500.00,  -- بالجنيه المصري
    created_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (instructor_id) REFERENCES users(id) ON DELETE SET NULL
);
```

---

### 📊 جدول `course_videos`

```sql
CREATE TABLE course_videos (
    id              VARCHAR(50)   PRIMARY KEY,
    course_id       VARCHAR(50)   NOT NULL,
    title           VARCHAR(255)  NOT NULL,
    description     TEXT          NOT NULL,
    video_url       VARCHAR(1000) NOT NULL,     -- رابط الفيديو على CDN/YouTube
    duration        VARCHAR(10)   NOT NULL DEFAULT '00:00',  -- صيغة "MM:SS"
    duration_secs   INT           NOT NULL DEFAULT 0,        -- نفس المدة بالثواني (للحسابات)
    is_preview      BOOLEAN       NOT NULL DEFAULT FALSE,
    is_uploaded     BOOLEAN       NOT NULL DEFAULT TRUE,
    sort_order      INT           NOT NULL DEFAULT 0,        -- ترتيب الفيديو في الكورس
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    INDEX idx_course_id (course_id)
);
```

---

### 📊 جدول `enrollments` (التسجيل في الكورسات)

```sql
CREATE TABLE enrollments (
    id           VARCHAR(50) PRIMARY KEY,
    student_id   VARCHAR(50) NOT NULL,
    course_id    VARCHAR(50) NOT NULL,
    enrolled_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_id   VARCHAR(50) NULL,   -- FK -> payments.id

    FOREIGN KEY (student_id) REFERENCES users(id)    ON DELETE CASCADE,
    FOREIGN KEY (course_id)  REFERENCES courses(id)  ON DELETE CASCADE,
    UNIQUE KEY uq_student_course (student_id, course_id)
);
```

---

### 📊 جدول `video_watch_progress` (تقدم مشاهدة الفيديو)

```sql
CREATE TABLE video_watch_progress (
    id                    VARCHAR(150)  PRIMARY KEY,   -- صيغة: "studentId|courseId|videoId"
    student_id            VARCHAR(50)   NOT NULL,
    course_id             VARCHAR(50)   NOT NULL,
    video_id              VARCHAR(50)   NOT NULL,
    watched_seconds       INT           NOT NULL DEFAULT 0,
    total_duration_secs   INT           NOT NULL DEFAULT 0,
    is_completed          BOOLEAN       NOT NULL DEFAULT FALSE,
    last_watched_at       TIMESTAMP     NULL,
    updated_at            TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (student_id) REFERENCES users(id)          ON DELETE CASCADE,
    FOREIGN KEY (course_id)  REFERENCES courses(id)        ON DELETE CASCADE,
    FOREIGN KEY (video_id)   REFERENCES course_videos(id)  ON DELETE CASCADE,
    
    INDEX idx_student_course (student_id, course_id),
    INDEX idx_video_id (video_id)
);
```

---

### 📊 جدول `learning_progress` (ملخص تقدم الطالب في الكورس)

```sql
CREATE TABLE learning_progress (
    id                  VARCHAR(100)  PRIMARY KEY,   -- صيغة: "progress-{studentId}-{courseId}"
    student_id          VARCHAR(50)   NOT NULL,
    course_id           VARCHAR(50)   NOT NULL,
    completion_percent  DECIMAL(5,4)  NOT NULL DEFAULT 0.0000,  -- 0.0000 -> 1.0000
    current_lesson      INT           NOT NULL DEFAULT 1,
    total_lessons       INT           NOT NULL DEFAULT 0,
    watched_videos      INT           NOT NULL DEFAULT 0,
    last_video_id       VARCHAR(50)   NULL,
    updated_at          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (student_id)   REFERENCES users(id)         ON DELETE CASCADE,
    FOREIGN KEY (course_id)    REFERENCES courses(id)       ON DELETE CASCADE,
    FOREIGN KEY (last_video_id) REFERENCES course_videos(id) ON DELETE SET NULL,
    
    UNIQUE KEY uq_student_course_progress (student_id, course_id)
);
```

> 💡 **اختياري:** يمكن حساب هذا الجدول dynamically من `video_watch_progress` بدلاً من تخزينه، لكن التخزين يُحسّن الأداء.

---

### 📊 جدول `comments`

```sql
CREATE TABLE comments (
    id           VARCHAR(50)  PRIMARY KEY,
    course_id    VARCHAR(50)  NOT NULL,
    video_id     VARCHAR(50)  NOT NULL,
    author_id    VARCHAR(50)  NOT NULL,   -- FK -> users.id
    author_name  VARCHAR(255) NOT NULL,   -- cached للأداء
    course_title VARCHAR(255) NOT NULL,   -- cached للأداء
    message      TEXT         NOT NULL,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (course_id) REFERENCES courses(id)       ON DELETE CASCADE,
    FOREIGN KEY (video_id)  REFERENCES course_videos(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(id)         ON DELETE CASCADE,
    
    INDEX idx_course_video (course_id, video_id),
    INDEX idx_created_at (created_at DESC)
);
```

---

### 📊 جدول `notifications`

```sql
CREATE TABLE notifications (
    id               VARCHAR(50)   PRIMARY KEY,
    title            VARCHAR(255)  NOT NULL,
    message          TEXT          NOT NULL,
    zoom_link        VARCHAR(1000) NULL,
    target_course_id VARCHAR(50)   NULL,   -- NULL = لكل الطلاب
    audience_label   VARCHAR(255)  NOT NULL DEFAULT 'All students',
    created_by       VARCHAR(50)   NOT NULL,   -- FK -> users.id (admin)
    created_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (target_course_id) REFERENCES courses(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by)       REFERENCES users(id)   ON DELETE CASCADE
);
```

---

### 📊 جدول `notification_reads` (تتبع من قرأ الإشعار)

```sql
CREATE TABLE notification_reads (
    notification_id  VARCHAR(50)  NOT NULL,
    user_id          VARCHAR(50)  NOT NULL,
    read_at          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (notification_id, user_id),
    FOREIGN KEY (notification_id) REFERENCES notifications(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id)         REFERENCES users(id)         ON DELETE CASCADE
);
```

---

### 📊 جدول `payments`

```sql
CREATE TABLE payments (
    id               VARCHAR(50)   PRIMARY KEY,
    student_id       VARCHAR(50)   NOT NULL,
    course_id        VARCHAR(50)   NOT NULL,
    amount           DECIMAL(10,2) NOT NULL,
    currency         VARCHAR(10)   NOT NULL DEFAULT 'EGP',
    payment_method   ENUM('card', 'fawry', 'vodafone') NOT NULL,
    status           ENUM('pending', 'success', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
    transaction_id   VARCHAR(255)  NULL,   -- من بوابة الدفع
    created_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (student_id) REFERENCES users(id)   ON DELETE CASCADE,
    FOREIGN KEY (course_id)  REFERENCES courses(id) ON DELETE CASCADE
);
```

---

## 11. Error Handling — التعامل مع الأخطاء

### صيغة رسائل الخطأ الموحدة

```json
{
  "error": "Course not found",
  "code": "COURSE_NOT_FOUND",
  "statusCode": 404
}
```

### أكواد HTTP المستخدمة

| Status Code | Meaning | متى يُستخدم |
|---|---|---|
| `200` | OK | نجاح العملية |
| `201` | Created | إنشاء resource جديد |
| `400` | Bad Request | بيانات ناقصة أو خاطئة |
| `401` | Unauthorized | Token مفقود أو منتهي |
| `403` | Forbidden | صلاحيات غير كافية (مثلاً طالب يحاول حذف كورس) |
| `404` | Not Found | Resource غير موجود |
| `409` | Conflict | تكرار (مثلاً email مكرر، أو طالب مسجل مسبقاً) |
| `500` | Server Error | خطأ داخلي |

---

## 12. ملاحظات عامة للباك اند

### 🔐 Authentication & Authorization

- استخدم **JWT** مع `expiry` مناسب (مثلاً 7 أيام)
- أضف **Refresh Token** mechanism
- تحقق من الـ `role` في كل endpoint محمي:
  - `admin` فقط: إنشاء/تعديل/حذف Courses، Students، Notifications
  - `student`: قراءة Courses المنشورة، إضافة Comments، حفظ Progress
  - كلاهما: قراءة Notifications، Profile

### 📁 File Storage (رفع الملفات)

- استخدم **AWS S3** أو **Cloudinary** أو **Firebase Storage** لرفع الفيديوهات والصور
- الفيديوهات الكبيرة: استخدم **Signed Upload URLs** بدلاً من رفعها مباشرة للـ Server
- صور البروفايل: ضغط الصورة قبل الحفظ

### ⚙️ حسابات تلقائية يجب على الباك اند تنفيذها

| الحدث | التحديث التلقائي |
|---|---|
| إضافة فيديو جديد | تحديث `courses.total_lessons` |
| حفظ تقدم فيديو | تحديث `learning_progress.completion_percent` و `watched_videos` |
| تسجيل طالب في كورس | زيادة `courses.enrolled_count` |
| إتمام تسجيل طالب | تحديث `users.active_courses` في بجدول الـ students |

### 🌐 CORS

- اسمح بـ requests من الـ Flutter Web App و Mobile clients

### 📡 Recommended Tech Stack للباك اند

| Layer | Technology |
|---|---|
| **Framework** | Node.js (Express/Fastify) أو Laravel (PHP) أو Django (Python) |
| **Database** | MySQL أو PostgreSQL |
| **Auth** | JWT + bcrypt لـ passwords |
| **File Storage** | AWS S3 أو Cloudinary |
| **Real-time** | Socket.io أو SSE |
| **Payment** | Paymob أو Fawry API |

---

> 📅 **تاريخ التوثيق:** 2026-03-29  
> 🔄 **الإصدار:** v1.0  
> 📱 **المشروع:** E-Learning Flutter App
