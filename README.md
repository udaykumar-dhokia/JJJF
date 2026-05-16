# JJJF - Jalore Jain Sangh App

A comprehensive mobile application and backend system for the Jalore Jain Sangh community.

## Project Structure

- `app/`: Flutter mobile application.
- `backend/`: Node.js/Express backend server.

## Features

- **News Feed**: Stay updated with the latest community news.
- **Job Board**: Post and find job vacancies within the community.
- **Directory**: Connect with community members.
- **Business Board**: Explore and onboard community businesses.
- **Birthdays & Anniversaries**: Never miss a community celebration.

## Recent Updates

- **WhatsApp Integration**: Added WhatsApp quick-chat icons in the directory list and a dedicated button in contact details for seamless communication.
- **Enhanced Contact Visibility**: Now showing Father's Name in the main directory and detail view. Added Current City and Gaon (Village) fields to contact profiles.
- **Family Details**: Introduced a dynamic input section for users to add and manage family member details (Name, Relation, Occupation).
- **Profile & User Flow**: Enhanced user profiles with new fields: Native Village (Gaon), District, Current City, and Marital Status. Introduced job role and company details for better community professional networking. Added "Others" category for businesses.
- **News Detail View**: Fixed the bug where news items were not clickable. Now users can tap on a news item to view full details, including images and complete content.

## Getting Started

### Mobile App (Flutter)

1. Navigate to `app/`.
2. Run `flutter pub get`.
3. Create a `.env` file with `BACKEND_URL`.
4. Run `flutter run`.

### Backend (Node.js)

1. Navigate to `backend/`.
2. Run `npm install`.
3. Configure environment variables in `.env`.
4. Run `npm start`.

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Node.js, Express, MongoDB
- **State Management**: Provider
- **Icons**: HugeIcons
- **Fonts**: Google Fonts (Mulish)
