# Normandy App




## IOS Deployment

VSCode

    1. Make sure you're on the main branch
    2. : git pull
    3. : flutter pub get
    4. Open pubspec.yaml
    5. Increment the version based on changes
    6. Check the API, and make sure it is set to the correct base URL
    7. : flutter build ipa

[Transporter](https://apps.apple.com/us/app/transporter/id1450874784?mt=12)

    1. Click + (add new package)
    2. Choose ios/ipa/normandy_app.ipa
    3. Wait for it to load, then click the three dots
    4. Choose "verify" from the dropdown menu
    5. Once verified, finish the delivery
    6. You should see a green checkmark below the name

Once done, the app will need a few minutes to upload to TestFlight. You will see a message, below the checkmark, that says "ready for internal testing." This means you can open TestFlight and update to the new version, or you can wait for it to automatically update (can take a few hours).






## Android Deployment

WIP