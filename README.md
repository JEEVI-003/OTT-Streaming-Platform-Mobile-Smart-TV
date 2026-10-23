# MediaJungle

**MediaJungle** is a full-stack OTT streaming platform. A **Spring Boot REST API** manages media, users, plans and payments, while a **Flutter client** delivers the experience on phones, Android TV / Fire TV, desktop, web, and packaged LG webOS and Samsung Tizen TVs. It streams both **video** (movies, trailers, cast & crew, scheduled ads) and **music** (songs, playlists, liked songs, recently played).

---

## Overview

| | |
|---|---|
| **Repo layout** | `mediaSpring/` (API) + `ott_project/` (Flutter client) |
| **Backend** | Spring Boot 3.4.3, Java 17, Maven → `media.war` |
| **Client** | Flutter / Dart 3 with separate mobile and TV UIs |
| **Database** | PostgreSQL (Hibernate-managed schema) |
| **API** | `/api/v2` on port `8080` |
| **Auth** | JWT (HS256), BCrypt, email OTP verification |
| **Payments** | Razorpay |
| **Media** | FFmpeg async DASH (480p/720p/1080p), HTTP Range streaming |

---

## What it does

- **Video** — catalogue with trailers, thumbnails, banners, categories, tags, languages, certificates and cast & crew.
- **Music** — category-based songs, audio shelves, background playback, "listen again" and "recently played".
- **Library** — liked songs, user playlists, watch later, play history.
- **Accounts** — sign-up, login/logout, password reset, profile editing with image upload.
- **Monetisation** — plans, features, tenures, discounts, Razorpay checkout and payment history.
- **Admin** — content and catalogue CRUD, ad scheduling, banners/containers, notifications, site/settings management.
- **Two UIs** — `lib/main.dart` auto-detects the device: touch-first mobile layout or a focused 10-foot TV layout with D-pad navigation.

---

## How it works

1. An admin uploads a video, trailer, thumbnails and metadata.
2. The API stores the files, compresses images, saves the record with `dashStatus = PROCESSING`, and returns immediately.
3. A background thread pool runs FFmpeg to generate DASH renditions, then marks the record `READY` or `FAILED`.
4. Clients stream via `GET /api/v2/{id}/videofile` (HTTP Range / partial content) or the DASH segments.
5. Users log in to receive a 24-hour JWT; protected endpoints validate the token and role.
6. Subscriptions are purchased through Razorpay and stored as payment history per user.

---

## Structure

```text
MediaJungle_public_clean/
├── mediaSpring/                    # Spring Boot REST API
│   ├── pom.xml, mvnw
│   └── src/main/java/com/VsmartEngine/MediaJungle/
│       ├── FrontController.java    # Main /api/v2 facade
│       ├── video/ audio/ Library/  # Core media + library modules
│       ├── controller/ model/      # Admin endpoints, JPA entities
│       ├── repository/ service/    # Data access + business logic
│       ├── ffmpeg/ config/         # DASH transcoding + thread pool
│       ├── userregister/           # JWT, blacklist, user auth
│       ├── MailVerification/       # Email OTP
│       ├── Banner/ Container/      # Home shelves and banners
│       └── notification/           # User/admin notifications
│
└── ott_project/                    # Flutter client
    ├── lib/
    │   ├── main.dart               # Entry + platform router
    │   ├── url.dart                # API base URL
    │   ├── pages/ components/      # Mobile screens & shared widgets
    │   ├── service/                # REST API clients
    │   ├── plan_and_payment/       # Plans & Razorpay
    │   ├── profile/
    │   └── tv_ui/                  # TV UI with focus management
    ├── android/ ios/ web/ windows/ macos/ linux/
    ├── webos_app/                  # Packaged LG webOS build
    ├── tizen_wgt/                  # Samsung Tizen widget
    └── myapp/                      # Prebuilt web bundle
```

> `webos_app/`, `tizen_wgt/` and `myapp/` are generated build artifacts, not source.

---

## Tech stack

**Backend**

| Area | Technology |
|---|---|
| Language / framework | Java 17, Spring Boot 3.4.3 (Web, Data JPA, Validation, Security, Mail) |
| Build | Maven wrapper, WAR packaging |
| Database | PostgreSQL + Hibernate |
| Auth | JWT (`jjwt`), BCrypt, email OTP |
| Payments | Razorpay Java SDK |
| Media | FFmpeg, `mp4parser`, HTTP Range streaming |
| API docs | springdoc-openapi (Swagger UI) |
| Other | Lombok, spring-dotenv, JDOM2, Commons IO |

**Client**

| Area | Technology |
|---|---|
| Language / framework | Dart 3, Flutter |
| State | Provider |
| Networking | `http` |
| Video | `video_player`, `chewie` |
| Audio | `just_audio`, `audio_service`, `just_audio_background`, `audioplayers` |
| Payments | `razorpay_flutter` |
| Storage | `shared_preferences`, `flutter_secure_storage` |
| UI / media | `cached_network_image`, `carousel_slider`, `google_fonts`, `font_awesome_flutter`, `wakelock_plus` |

---

## Getting started

**Backend**

```bash
# 1. Create a PostgreSQL database
# 2. Add mediaSpring/.env with DB_*, JWT_SECRET, FFMPEG_PATH,
#    PROJECT_VIDEO, FILE_UPLOAD_DIR, MAIL_* and storage paths

cd mediaSpring
./mvnw spring-boot:run        # or mvnw.cmd on Windows
```

- API: `http://localhost:8080/api/v2`
- Swagger UI: `http://localhost:8080/swagger-ui/index.html`
- Deployable build: `./mvnw clean package` → `target/media.war`

**Flutter client**

```bash
cd ott_project
flutter pub get

# Set baseUrl in lib/url.dart (must include /api/v2)
flutter run -d chrome      # TV layout on web
flutter run -d windows     # TV layout on desktop
flutter run -d <android>   # auto-detects phone vs TV
```

Release builds: `flutter build apk --release`, `flutter build web`, `flutter build windows`.

---

## Notes

- The admin dashboard is not part of this repo; it consumes the same API.
- DASH is generated by the backend, but the Flutter client currently plays the source file via range requests.
- Global Spring Security and Google OAuth configs exist but are commented out — authorization is enforced per controller.
- Razorpay keys are entered at runtime (`/AddrazorpayId`) and stored in the database, not in config files.
- Development artifacts (keystore, log archives, sample XML) are present in the repo; rotate any real secrets and keep `.env`/keystores out of version control.

## License

No license file is included. All rights reserved by the authors unless a license is added.
