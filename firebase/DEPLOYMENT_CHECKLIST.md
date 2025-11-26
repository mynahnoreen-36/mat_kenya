# Firebase Backend Deployment Checklist

Use this checklist when deploying your Mat Kenya backend to production.

## Pre-Deployment

### 1. Security Review
- [ ] Review Firestore security rules in `firestore.rules`
- [ ] Verify admin-only operations are properly protected
- [ ] Confirm public read access is appropriate for Routes and Fares
- [ ] Test security rules using Firebase Emulator

### 2. Code Review
- [ ] All Firebase SDK packages are up to date
- [ ] No hardcoded credentials or API keys in code
- [ ] Error handling is in place for all Firebase operations
- [ ] Logging is appropriate (no sensitive data logged)

### 3. Data Validation
- [ ] Input validation is implemented for all user inputs
- [ ] Admin utilities are properly integrated
- [ ] Route and fare validation functions are in use

### 4. Testing
- [ ] Test authentication flow (signup, login, logout)
- [ ] Test admin role verification
- [ ] Test CRUD operations for all collections
- [ ] Test push notifications
- [ ] Test in offline mode (Firestore persistence)

## Initial Setup (First Time Only)

### 1. Create Firebase Project
```bash
# Login to Firebase
firebase login

# Initialize Firebase in project (if not already done)
firebase init
# Select: Firestore, Functions, Storage, Hosting
```

### 2. Configure Environment
- [ ] Set up Firebase project in console
- [ ] Enable Authentication (Email/Password)
- [ ] Enable Firestore Database
- [ ] Enable Cloud Storage
- [ ] Enable Cloud Functions
- [ ] Set up billing (for Cloud Functions)

### 3. Create First Admin
**CRITICAL**: Create at least one admin before deploying security rules!

Option A - Firebase Console:
- [ ] Go to Firestore Database
- [ ] Create document in `Admin` collection with your user ID
- [ ] Update `Users` collection with role: "admin"

Option B - Admin SDK Script:
```bash
cd firebase/functions
node create_admin.js [your-uid] [your-email] [your-name]
```

### 4. Deploy Firebase Config
```bash
# Deploy security rules
firebase deploy --only firestore:rules

# Deploy indexes
firebase deploy --only firestore:indexes

# Deploy storage rules
firebase deploy --only storage

# Deploy cloud functions
firebase deploy --only functions
```

## Regular Deployment

### 1. Pre-Deployment Checks
- [ ] Run `flutter analyze` - ensure no critical issues
- [ ] Run `flutter test` - ensure tests pass
- [ ] Test app in development mode
- [ ] Review changes in security rules
- [ ] Check Cloud Functions for errors

### 2. Deploy Backend
```bash
# Deploy everything
firebase deploy

# Or deploy specific components:
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
firebase deploy --only functions
firebase deploy --only storage
```

### 3. Deploy App
```bash
# Build Android APK
flutter build apk --release

# Build iOS IPA (requires Mac)
flutter build ios --release

# Or build for specific targets
flutter build appbundle  # For Google Play Store
```

### 4. Post-Deployment Verification
- [ ] Verify security rules are active (check Firebase Console)
- [ ] Test login/signup flow
- [ ] Test admin operations
- [ ] Test regular user operations
- [ ] Verify push notifications work
- [ ] Check Cloud Functions logs for errors
- [ ] Monitor Firestore usage/quota

## Monitoring Setup

### 1. Enable Monitoring
- [ ] Set up Firebase Performance Monitoring
- [ ] Enable Crashlytics for error tracking
- [ ] Set up Cloud Function logging
- [ ] Configure billing alerts

### 2. Set Up Alerts
- [ ] Budget alerts (Cloud Functions, Firestore)
- [ ] Error rate alerts
- [ ] Quota alerts
- [ ] Security rule violation alerts

### 3. Regular Monitoring
- [ ] Check Firebase Console → Usage tab weekly
- [ ] Review Cloud Functions logs for errors
- [ ] Monitor authentication metrics
- [ ] Check Crashlytics for app crashes
- [ ] Review Performance data

## Security Best Practices

### Production Environment
- [ ] Never commit `.env` files with secrets
- [ ] Use environment variables for sensitive config
- [ ] Enable App Check for Firebase services
- [ ] Set up reCAPTCHA for sensitive operations
- [ ] Regular security audits of Firestore rules
- [ ] Monitor for suspicious activity patterns

### User Data Protection
- [ ] Implement data encryption where needed
- [ ] Regular backups of Firestore data
- [ ] GDPR compliance (user data deletion)
- [ ] Clear privacy policy
- [ ] Secure password requirements

## Rollback Plan

If deployment causes issues:

### 1. Rollback Security Rules
```bash
# Revert to previous rules version in Firebase Console
# Or redeploy previous version:
git checkout [previous-commit] firebase/firestore.rules
firebase deploy --only firestore:rules
```

### 2. Rollback Cloud Functions
```bash
# Check function versions in Firebase Console
# Rollback to previous version or redeploy
git checkout [previous-commit] firebase/functions/
firebase deploy --only functions
```

### 3. Rollback App
- Unpublish from app stores if necessary
- Deploy previous APK/IPA version
- Notify users of issue and expected fix time

## Backup Procedures

### Regular Backups
```bash
# Export Firestore data (requires gcloud CLI)
gcloud firestore export gs://[YOUR-BUCKET]/backups/$(date +%Y%m%d)

# Schedule automated backups
# Set up in GCP Console → Datastore → Import/Export
```

### Restore from Backup
```bash
# Import Firestore data
gcloud firestore import gs://[YOUR-BUCKET]/backups/[TIMESTAMP]
```

## Troubleshooting

### Common Issues

**Issue**: Permission denied errors after deployment
- Check security rules are deployed
- Verify user authentication
- Confirm admin role is set correctly

**Issue**: Cloud Functions not triggering
- Check function deployment status
- Review Cloud Functions logs
- Verify triggers are configured correctly

**Issue**: Performance degradation
- Check if indexes are properly deployed
- Review query patterns
- Monitor Firestore usage metrics

**Issue**: Budget overruns
- Review Cloud Functions usage
- Check for inefficient queries
- Implement caching where appropriate
- Set up stricter quotas

## Emergency Contacts

- **Firebase Support**: https://firebase.google.com/support
- **Critical Issue**: Open Firebase Console → Support
- **Billing Issues**: Check Cloud Console → Billing

## Sign-Off

Before marking deployment complete:

- [ ] Backend deployed successfully
- [ ] All tests passing
- [ ] Monitoring active
- [ ] Team notified
- [ ] Documentation updated
- [ ] Rollback plan confirmed

**Deployed by:** _______________
**Date:** _______________
**Version:** _______________
**Notes:** _______________________________________________
