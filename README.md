# Proof It!

Proof It! is a comprehensive project management platform designed to simplify team workflows, roadmaps, and notifications.

## Project Structure

This repository is a monorepo containing both the frontend and backend:

- `Proof-It-app/` - The frontend application built with Flutter/Dart.
- `backend-ProofIt/` - The backend server built with Node.js, Express, and Supabase.

## Features
- **Authentication**: Secure JWT-based login system.
- **Dashboard & Roadmaps**: Visualize project progress and schedules.
- **Team Management**: Manage roles like Admin, PIC, and Member.
- **Real-time Notifications**: Integrated with Supabase Realtime for instant updates.

## Getting Started

### 1. Backend Setup

First, navigate into the backend directory and install the dependencies:
```bash
cd backend-ProofIt
npm install
```

Create a `.env` file in the `backend-ProofIt` folder (if you haven't already). It should contain your Supabase credentials and JWT Secret:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_anon_key
SUPABASE_SERVICE_KEY=your_supabase_service_key
PORT=3000
JWT_SECRET=your_super_secret_hex_string
```

Run the backend server:
```bash
npm run dev
# Server akan berjalan di http://localhost:3000
```

### 2. Frontend Setup

Open a new terminal, navigate to the frontend directory, and fetch the Dart packages:
```bash
cd Proof-It-app
flutter pub get
```

Run the Flutter app:
```bash
flutter run
```

## Git Workflow
We use `.gitignore` to prevent large files (like `node_modules` or `build/`) from being uploaded to GitHub. Ensure you never commit `.env` files to the repository!
