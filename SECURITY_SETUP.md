# Security Setup Guide

This guide will help you set up the necessary credentials and API keys for the Mat Kenya application.

## Important Security Notice

**NEVER commit sensitive files to Git!** The following files contain sensitive information and are ignored by `.gitignore`:

- `.env` files
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- Any files containing API keys or secrets

## Setup Instructions

### 1. Environment Variables

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Open `.env` and fill in your actual values:
   - Get Firebase credentials from [Firebase Console](https://console.firebase.google.com/)
   - Add any other API keys your app requires

### 2. Firebase Configuration Files

#### For Android:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings > General
4. Under "Your apps", find your Android app
5. Click "google-services.json" to download
6. Place the file at: `android/app/google-services.json`

#### For iOS:

1. In the same Firebase Console location
2. Find your iOS app
3. Click "GoogleService-Info.plist" to download
4. Place the file at: `ios/Runner/GoogleService-Info.plist`

### 3. Verify Setup

After adding the files, verify they are NOT tracked by Git:

```bash
git status
```

These files should NOT appear in the output. If they do, check your `.gitignore` file.

## What Each File Contains

### .env
Contains environment-specific variables and API keys used across the application.

### google-services.json (Android)
Contains Firebase configuration for Android including:
- Project ID
- API Keys
- OAuth client IDs
- Firebase services configuration

### GoogleService-Info.plist (iOS)
Contains Firebase configuration for iOS including:
- Project ID
- API Keys
- OAuth client IDs
- Firebase services configuration

## Team Collaboration

When working with a team:

1. **Share credentials securely**: Use a password manager or secure credential sharing service
2. **Never commit**: Each team member sets up their own local copies
3. **Document**: Keep this SECURITY_SETUP.md updated with any new requirements
4. **Different environments**: Use separate Firebase projects for dev/staging/production

## Troubleshooting

### Firebase not working?
- Verify your google-services.json and GoogleService-Info.plist files are in the correct locations
- Check that the package name in the files matches your app's package name
- Ensure you've enabled the required Firebase services in the console

### Environment variables not loading?
- Check that your .env file is in the project root
- Verify the variable names match what's used in the code
- Restart your development server after changing .env

## Security Best Practices

1. ✅ Keep .gitignore up to date
2. ✅ Use different API keys for development and production
3. ✅ Rotate API keys regularly
4. ✅ Never share credentials in plain text (Slack, email, etc.)
5. ✅ Use environment-specific Firebase projects
6. ✅ Enable Firebase security rules to protect your data
