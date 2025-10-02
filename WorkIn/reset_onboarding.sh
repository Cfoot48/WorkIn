#!/bin/bash
echo "This will reset onboarding so you can test it"
echo "Run this command in Terminal:"
echo ""
echo "defaults delete com.yourcompany.WorkIn hasCompletedOnboarding"
echo ""
echo "Or add this line to your app for testing:"
echo "UserDefaults.standard.removeObject(forKey: \"hasCompletedOnboarding\")"
