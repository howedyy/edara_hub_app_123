# API Documentation - Edara App

> توثيق شامل لجميع APIs العاملة في نظام إدارة الموظفين

## 🎯 JSON to Dart Compatibility

**تم تحسين جميع الـ APIs لتكون متوافقة 100% مع JSON to Dart:**

### ✅ التحسينات المطبقة:
- **Type Safety**: جميع الـ fields لها أنواع بيانات ثابتة ومحددة
- **No Null Arrays**: الـ arrays دائماً arrays حتى لو فارغة (مش null)
- **Consistent Strings**: الـ strings مش بتكون null، بتكون empty string
- **Explicit Casting**: جميع الـ values متحولة لنوع البيانات الصحيح
- **ISO Timestamps**: جميع التواريخ بصيغة ISO string
- **Nested Objects**: بنية ثابتة للـ objects المتداخلة

### 📱 Flutter Integration:
```dart
// Example Dart Models
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  
  ApiResponse({required this.success, required this.message, this.data});
}

class Event {
  final int id;
  final String title;
  final String description;
  final List<AllowedUser> allowedUsers; // Always List, never null
  final EventMedia media;
  final bool isRegistered;
  
  Event({required this.id, required this.title, ...});
}
```

---

## Base URL
```
http://127.0.0.1:8000/api/v1
```

**API Version:** v1 (Required)
**All endpoints must include `/v1/` prefix**

---

## 🔐 Authentication APIs

### 1. Register Employee
```
POST /api/v1/register
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "أحمد محمد علي",
  "employee_id": "EMP001",
  "password": "123456",
  "phone": "01012345678",
  "email": "ahmed@company.com",
  "ip_device": "192.168.1.100"
}
```

**Request Fields:**
- `name` (string, required) - اسم الموظف
- `employee_id` (string, required, unique) - رقم الموظف
- `password` (string, required, min:6) - كلمة المرور
- `phone` (string, required) - رقم الهاتف
- `email` (string, required) - البريد الإلكتروني
- `ip_device` (string, optional) - عنوان IP للجهاز

**Response (201) - Success:**
```json
{
  "success": true,
  "message": "تم التسجيل بنجاح. حسابك قيد المراجعة وسيتم تفعيله من قبل الإدارة",
  "data": {
    "user": {
      "id": 1,
      "name": "أحمد محمد علي",
      "employee_id": "EMP001",
      "email": "ahmed@company.com",
      "phone": "01012345678",
      "ip_device": "192.168.1.100",
      "status": "inactive"
    },
    "token": "1|abc123def456ghi789jkl012mno345pqr678stu901"
  }
}
```

**ملاحظة مهمة:** يتم إرجاع token في الـ Register حتى لو كان المستخدم `inactive`. لكن هذا التوكن لن يعمل مع الـ APIs المحمية حتى يتم تفعيل الحساب من قبل الإدارة.

**Response (422) - Validation Error:**
```json
{
  "success": false,
  "message": "خطأ في البيانات المدخلة",
  "errors": {
    "employee_id": ["The employee id has already been taken."],
    "email": ["The email field is required."]
  }
}
```

---

### 2. Login Employee
```
POST /api/v1/login
Content-Type: application/json
```

**Request Body:**
```json
{
  "employee_id": "EMP001",
  "password": "123456"
}
```

**Request Fields:**
- `employee_id` (string, required) - رقم الموظف
- `password` (string, required) - كلمة المرور

**Response (200) - Success (Active User):**
```json
{
  "success": true,
  "message": "تم تسجيل الدخول بنجاح",
  "data": {
    "user": {
      "id": 2,
      "name": "أحمد محمد علي",
      "employee_id": "EMP001",
      "email": "ahmed.mohamed@edara-app.com",
      "phone": "01012345678",
      "ip_device": "192.168.1.10",
      "status": "active"
    },
    "token": "4|GaP94g9oCMnY5Ff2HU29QLUAPl45TANc9TI2Q4xV"
  }
}
```

**Response (403) - Inactive User:**
```json
{
  "success": false,
  "message": "حسابك غير مفعل. يرجى انتظار موافقة الإدارة"
}
```

**Response (401) - Invalid Credentials:**
```json
{
  "success": false,
  "message": "رقم الموظف أو كلمة المرور غير صحيحة"
}
```

---

### 3. Logout Employee
```
POST /api/v1/logout
Authorization: Bearer {token}
```

**Request Headers:**
```
Authorization: Bearer 4|GaP94g9oCMnY5Ff2HU29QLUAPl45TANc9TI2Q4xV
```

**Response (200) - Success:**
```json
{
  "success": true,
  "message": "تم تسجيل الخروج بنجاح"
}
```

**Response (401) - Unauthorized:**
```json
{
  "success": false,
  "message": "Unauthenticated."
}
```

---

### 4. Get Current User
```
GET /api/v1/me
Authorization: Bearer {token}
```

**Request Headers:**
```
Authorization: Bearer 4|GaP94g9oCMnY5Ff2HU29QLUAPl45TANc9TI2Q4xV
```

**Response (200) - Success:**
```json
{
  "success": true,
  "message": "تم جلب بيانات المستخدم بنجاح",
  "data": {
    "user": {
      "id": 2,
      "name": "أحمد محمد علي",
      "employee_id": "EMP001",
      "email": "ahmed.mohamed@edara-app.com",
      "phone": "01012345678",
      "ip_device": "192.168.1.10",
      "status": "active",
      "created_at": "2024-01-20T10:30:00.000000Z",
      "updated_at": "2024-01-22T14:20:00.000000Z"
    }
  }
}
```

---

## 🎉 Events APIs

### 5. Get All Events
```
GET /api/v1/events
Authorization: Bearer {token}
```

**Request Headers:**
```
Authorization: Bearer 4|GaP94g9oCMnY5Ff2HU29QLUAPl45TANc9TI2Q4xV
```

**Query Parameters:**
```
GET /api/v1/events?category=training&page=1&per_page=10
```

**Available Query Parameters:**
- `category` (string, optional) - فلترة حسب النوع: `training`, `meeting`, `social`, `conference`
- `page` (int, optional) - رقم الصفحة (default: 1)
- `per_page` (int, optional) - عدد العناصر (default: 10, max: 50)

**Response (200) - Success:**
```json
{
  "success": true,
  "message": "تم جلب الفعاليات بنجاح",
  "data": {
    "events": [
      {
        "id": 1,
        "title": "ورشة تدريبية - تطوير المهارات التقنية",
        "description": "ورشة عمل متخصصة في تطوير المهارات التقنية للموظفين",
        "category": "training",
        "start_date": "2024-02-15T00:00:00.000000Z",
        "start_time": "09:00:00",
        "end_date": "2024-02-15T00:00:00.000000Z",
        "end_time": "17:00:00",
        "location": "قاعة المؤتمرات - الطابق الثالث",
        "current_attendees": 23,
        "is_published": true,
        "visibility": "selected_users",
        "allowed_users": [
          {
            "id": 2,
            "employee_id": "EMP001"
          },
          {
            "id": 3,
            "employee_id": "EMP002"
          }
        ],
        "media": {
          "images": [
            {
              "id": 1,
              "url": "https://example.com/storage/events/training-workshop-1.jpg"
            },
            {
              "id": 2,
              "url": "https://example.com/storage/events/training-workshop-2.jpg"
            }
          ],
          "videos": [
            {
              "id": 3,
              "url": "https://example.com/storage/events/training-intro.mp4",
              "title": "مقدمة عن الورشة التدريبية"
            }
          ]
        },
        "is_registered": false,
        "created_at": "2026-01-06T13:33:19.000000Z"
      },
      {
        "id": 2,
        "title": "اجتماع الفريق الشهري",
        "description": "اجتماع دوري لمناقشة إنجازات الشهر والخطط القادمة",
        "category": "meeting",
        "start_date": "2024-02-10T00:00:00.000000Z",
        "start_time": "14:00:00",
        "end_date": "2024-02-10T00:00:00.000000Z",
        "end_time": "16:00:00",
        "location": "قاعة الاجتماعات الرئيسية",
        "current_attendees": 15,
        "is_published": true,
        "visibility": "all_users",
        "allowed_users": [],
        "media": {
          "images": [
            {
              "id": 4,
              "url": "https://example.com/storage/events/meeting-room.jpg"
            }
          ],
          "videos": []
        },
        "is_registered": true,
        "created_at": "2026-01-06T13:33:19.000000Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 10,
      "total": 4,
      "last_page": 1,
      "from": 1,
      "to": 4
    }
  }
}
```

---

### 6. Get Event Details
```
GET /api/v1/events/{id}
Authorization: Bearer {token}
```

**Request Headers:**
```
Authorization: Bearer 4|GaP94g9oCMnY5Ff2HU29QLUAPl45TANc9TI2Q4xV
```

**Request URL:**
```
GET /api/v1/events/1
```

**Response (200) - Success:**
```json
{
  "success": true,
  "message": "تم جلب تفاصيل الفعالية بنجاح",
  "data": {
    "event": {
      "id": 1,
      "title": "ورشة تدريبية - تطوير المهارات التقنية",
      "description": "ورشة عمل متخصصة في تطوير المهارات التقنية للموظفين. سيتم تغطية أحدث التقنيات والأدوات المستخدمة في مجال التطوير.",
      "category": "training",
      "start_date": "2024-02-15T00:00:00.000000Z",
      "start_time": "09:00:00",
      "end_date": "2024-02-15T00:00:00.000000Z",
      "end_time": "17:00:00",
      "location": "قاعة المؤتمرات - الطابق الثالث",
      "current_attendees": 23,
      "is_published": true,
      "visibility": "selected_users",
      "allowed_users": [
        {
          "id": 2,
          "employee_id": "EMP001"
        },
        {
          "id": 3,
          "employee_id": "EMP002"
        },
        {
          "id": 4,
          "employee_id": "EMP003"
        }
      ],
      "media": {
        "images": [
          {
            "id": 1,
            "url": "https://example.com/storage/events/training-workshop-1.jpg",
            "uploaded_at": "2024-01-20T10:30:00.000000Z"
          },
          {
            "id": 2,
            "url": "https://example.com/storage/events/training-workshop-2.jpg",
            "uploaded_at": "2024-01-20T11:15:00.000000Z"
          }
        ],
        "videos": [
          {
            "id": 1,
            "url": "https://example.com/storage/events/training-intro.mp4",
            "title": "مقدمة عن الورشة التدريبية",
            "description": "نظرة عامة على محتوى الورشة والأهداف المتوقعة",
            "size": "45.2 MB",
            "uploaded_at": "2024-01-21T09:00:00.000000Z"
          }
        ]
      },
      "is_registered": false,
      "agenda": [
        {
          "time": "09:00 - 10:30",
          "topic": "مقدمة في التقنيات الحديثة"
        },
        {
          "time": "11:00 - 12:30",
          "topic": "ورشة عملية - تطبيق التقنيات"
        },
        {
          "time": "14:00 - 15:30",
          "topic": "مناقشة وأسئلة"
        }
      ],
      "organizer": {
        "name": "قسم التدريب والتطوير",
        "contact": "training@company.com"
      },
      "created_at": "2026-01-06T13:33:19.000000Z",
      "updated_at": "2026-01-06T13:33:19.000000Z"
    }
  }
}
```

**Response (404) - Event Not Found:**
```json
{
  "success": false,
  "message": "الفعالية غير موجودة"
}
```

**Response (403) - Not Allowed to View:**
```json
{
  "success": false,
  "message": "غير مسموح لك برؤية هذه الفعالية"
}
```

---

### 7. Register for Event
```
POST /api/v1/events/{id}/register
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Headers:**
```
Authorization: Bearer 4|GaP94g9oCMnY5Ff2HU29QLUAPl45TANc9TI2Q4xV
Content-Type: application/json
```

**Request URL:**
```
POST /api/v1/events/2/register
```

**Request Body:**
```json
{}
```

**Response (200) - Success:**
```json
{
  "success": true,
  "message": "تم تسجيلك في الفعالية بنجاح",
  "data": {
    "registration": {
      "event_id": 2,
      "user_id": 2,
      "registered_at": "2026-01-06T13:34:56.738088Z",
      "status": "confirmed"
    },
    "event": {
      "id": 2,
      "title": "اجتماع الفريق الشهري",
      "start_date": "2024-02-10T00:00:00.000000Z",
      "start_time": "14:00:00",
      "location": "قاعة الاجتماعات الرئيسية",
      "current_attendees": 1
    }
  }
}
```

**Response (400) - Already Registered:**
```json
{
  "success": false,
  "message": "أنت مسجل في هذه الفعالية مسبقاً"
}
```

**Response (403) - Not Allowed to Register:**
```json
{
  "success": false,
  "message": "غير مسموح لك بالتسجيل في هذه الفعالية"
}
```

**Response (400) - Event Ended:**
```json
{
  "success": false,
  "message": "لا يمكن التسجيل في فعالية منتهية"
}
```

---

### 8. Unregister from Event
```
DELETE /api/v1/events/{id}/register
Authorization: Bearer {token}
```

**Request Headers:**
```
Authorization: Bearer 4|GaP94g9oCMnY5Ff2HU29QLUAPl45TANc9TI2Q4xV
```

**Request URL:**
```
DELETE /api/v1/events/2/register
```

**Response (200) - Success:**
```json
{
  "success": true,
  "message": "تم إلغاء تسجيلك من الفعالية بنجاح",
  "data": {
    "event": {
      "id": 2,
      "title": "اجتماع الفريق الشهري",
      "current_attendees": 0
    }
  }
}
```

**Response (400) - Not Registered:**
```json
{
  "success": false,
  "message": "أنت غير مسجل في هذه الفعالية"
}
```

**Response (400) - Cannot Unregister:**
```json
{
  "success": false,
  "message": "لا يمكن إلغاء التسجيل قبل 24 ساعة من بداية الفعالية"
}
```

---

### 9. Get My Events
```
GET /api/v1/my-events
Authorization: Bearer {token}
```

**Request Headers:**
```
Authorization: Bearer 4|GaP94g9oCMnY5Ff2HU29QLUAPl45TANc9TI2Q4xV
```

**Query Parameters:**
```
GET /api/v1/my-events?page=1
```

**Available Query Parameters:**
- `page` (int, optional) - رقم الصفحة للتصفح

**Response (200) - Success:**
```json
{
  "success": true,
  "message": "تم جلب فعالياتك بنجاح",
  "data": {
    "events": [
      {
        "id": 2,
        "title": "اجتماع الفريق الشهري",
        "start_date": "2024-02-10T00:00:00.000000Z",
        "start_time": "14:00:00",
        "location": "قاعة الاجتماعات الرئيسية",
        "registration_status": "confirmed",
        "registered_at": "2026-01-06T13:34:56.000000Z"
      },
      {
        "id": 3,
        "title": "حفل تكريم الموظفين",
        "start_date": "2024-01-15T00:00:00.000000Z",
        "start_time": "18:00:00",
        "location": "القاعة الكبرى",
        "registration_status": "attended",
        "registered_at": "2024-01-10T12:15:00.000000Z"
      }
    ],
    "summary": {
      "total_registered": 5,
      "attended": 2
    }
  }
}
```

---

### 10. Get Event Media
```
GET /api/v1/events/{id}/media
Authorization: Bearer {token}
```

**Request Headers:**
```
Authorization: Bearer 4|GaP94g9oCMnY5Ff2HU29QLUAPl45TANc9TI2Q4xV
```

**Request URL:**
```
GET /api/v1/events/1/media?type=all
```

**Query Parameters:**
- `type` (string, optional) - نوع الوسائط: `images`, `videos`, `all` (default: all)

**Response (200) - Success:**
```json
{
  "success": true,
  "message": "تم جلب وسائط الفعالية بنجاح",
  "data": {
    "images": [
      {
        "id": 1,
        "url": "https://example.com/storage/events/training-workshop-1.jpg",
        "uploaded_at": "2024-01-20T10:30:00.000000Z"
      },
      {
        "id": 2,
        "url": "https://example.com/storage/events/training-workshop-2.jpg",
        "uploaded_at": "2024-01-20T11:15:00.000000Z"
      }
    ],
    "videos": [
      {
        "id": 1,
        "url": "https://example.com/storage/events/training-intro.mp4",
        "title": "مقدمة عن الورشة التدريبية",
        "description": "نظرة عامة على محتوى الورشة والأهداف المتوقعة",
        "size": "45.2 MB",
        "uploaded_at": "2024-01-21T09:00:00.000000Z"
      }
    ],
    "summary": {
      "total_images": 3,
      "total_videos": 2,
      "total_size": "291.5 MB"
    }
  }
}
```

**Response (404) - Event Not Found:**
```json
{
  "success": false,
  "message": "الفعالية غير موجودة"
}
```

---

## 📊 Response Status Codes

| Code | Status | Description |
|------|--------|-------------|
| 200 | OK | طلب ناجح |
| 201 | Created | تم إنشاء المورد بنجاح |
| 400 | Bad Request | خطأ في البيانات المرسلة |
| 401 | Unauthorized | غير مصرح - token غير صالح |
| 403 | Forbidden | ممنوع - لا يملك صلاحية |
| 404 | Not Found | المورد غير موجود |
| 422 | Unprocessable Entity | خطأ في التحقق من البيانات |
| 500 | Internal Server Error | خطأ في الخادم |

---

## 🔑 Authentication

جميع الـ APIs المحمية تتطلب إرسال token في header:

```
Authorization: Bearer {your_token_here}
```

**الحصول على Token:**
1. استخدم `/api/register` أو `/api/login` للحصول على token
2. أرسل Token في كل طلب محمي
3. استخدم `/api/logout` لإلغاء Token

**ملاحظة:** Token من `/api/register` لن يعمل مع الـ APIs المحمية إذا كان المستخدم `inactive`.

---

## 📝 Request/Response Format

**جميع الطلبات:**
- Content-Type: `application/json`
- Accept: `application/json`

**جميع الاستجابات:**
```json
{
  "success": true/false,
  "message": "رسالة توضيحية",
  "data": { ... },
  "errors": { ... }
}
```

---

## 🧪 Testing

**Test Credentials:**
- Employee ID: `EMP001`
- Password: `123456`

**Test Server:**
```bash
php artisan serve
```

**Test Files:**
- `test_events_api.php` - اختبار شامل
- `test_events_ui.html` - واجهة تفاعلية

---

## 📱 Pagination

الـ APIs التي تدعم التصفح ترجع:

```json
{
  "pagination": {
    "current_page": 1,
    "per_page": 10,
    "total": 25,
    "last_page": 3,
    "from": 1,
    "to": 10
  }
}
```

---

## 🔍 Filtering & Search

**Available Filters:**
- Events: `category`, `page`, `per_page`
- My Events: `page`

**Usage:**
```
GET /api/events?category=training&page=2&per_page=5
```

---

## ⚠️ Error Handling

**Validation Errors (422):**
```json
{
  "success": false,
  "message": "خطأ في البيانات المدخلة",
  "errors": {
    "field_name": ["Error message"]
  }
}
```

**Authentication Errors (401):**
```json
{
  "success": false,
  "message": "Unauthenticated."
}
```

**Authorization Errors (403):**
```json
{
  "success": false,
  "message": "غير مسموح لك بهذا الإجراء"
}
```

---

## 🚀 API Versions

**Current Version:** v1 (Required)

**All endpoints require v1 prefix:**
- ✅ `/api/v1/login`
- ✅ `/api/v1/events`
- ❌ `/api/login` (Not supported)
- ❌ `/api/events` (Not supported)

---

**Last Updated:** January 8, 2026
**API Version:** 1.0
**Total Endpoints:** 10 (4 Auth + 6 Events)
**Dart Compatibility:** ✅ 100% Compatible

## 🧪 Testing Dart Compatibility

تم اختبار جميع الـ APIs للتأكد من التوافق مع JSON to Dart:

```bash
php test_dart_compatibility.php
```

**Test Results:**
- ✅ All data types explicitly cast
- ✅ Arrays always arrays (never null)  
- ✅ Strings never null (empty string instead)
- ✅ Integers properly typed
- ✅ Booleans properly typed
- ✅ ISO date strings for timestamps
- ✅ Consistent nested object structures

**Ready for Flutter development!** 🚀