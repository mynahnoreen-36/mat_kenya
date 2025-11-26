# Quick Start: Create Default Admin

## Easiest Method - Use the Built-in Setup Page

I've created a special page in your Flutter app to create the admin user. Here's how to use it:

### Step 1: Run Your App
```bash
flutter run
```

### Step 2: Access the Setup Admin Page

Once your app is running, you have a few options:

**Option A: Direct URL (if using web/browser)**
- Navigate to: `http://localhost:<port>/setupAdmin`
- Or on your device: Open the app and manually navigate to `/setupAdmin`

**Option B: Add Temporary Navigation Button**

Add this button to any page (like `lib/pages/login_page/login_page_widget.dart` or `lib/pages/signup_page/signup_page_widget.dart`):

```dart
// Add this anywhere in your page's UI (e.g., at the bottom):
TextButton(
  onPressed: () => context.pushNamed('SetupAdminPage'),
  child: const Text('Setup Admin (DEV ONLY)', style: TextStyle(fontSize: 10)),
)
```

### Step 3: Create the Admin

1. On the Setup Admin page, tap the **"Create Admin User"** button
2. Wait a few seconds while it creates the user
3. You'll see a success message with the credentials:
   - **Email:** mynahnoreen@gmail.com
   - **Password:** Kitiko.13936

### Step 4: Log In

1. Go back to the login page
2. Log in with the admin credentials
3. You're done! You now have full admin access

## Files Created

- **`lib/utils/create_default_admin.dart`** - Core logic to create the admin
- **`lib/pages/setup_admin_page/setup_admin_page_widget.dart`** - UI page to trigger admin creation
- **Route:** `/setupAdmin` - Already registered in your navigation

## Alternative: Direct Code Method

If you prefer not to use the UI, you can call this function directly from anywhere in your app:

```dart
import '/utils/create_default_admin.dart';

// Call this once during app initialization
await CreateDefaultAdmin.createAdmin();
```

## Troubleshooting

**Q: The button doesn't work / Nothing happens**
- Check the Flutter console for error messages
- Make sure Firebase is properly initialized
- Verify your internet connection

**Q: User already exists error**
- The admin was already created! Just log in with the credentials
- Email: mynahnoreen@gmail.com
- Password: Kitiko.13936

**Q: Permission denied error**
- Check your Firestore security rules
- Make sure Firebase Authentication is enabled in your Firebase Console

## Security Note

**After creating the admin:**
1. Remove or comment out any temporary navigation buttons you added
2. Consider changing the default password after first login
3. The `/setupAdmin` route will still be accessible, so consider adding auth checks if deploying to production

## Next Steps

Once you're logged in as admin:
1. Navigate to the Admin Page to manage routes and fares
2. Create new routes for your matatu service
3. Set fares for different routes
4. Add more admin users if needed using the admin utilities

---

**Admin Credentials:**
- Email: mynahnoreen@gmail.com
- Password: Kitiko.13936

Save these credentials securely!
