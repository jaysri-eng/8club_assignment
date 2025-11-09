# eightclub_assignment

A new Flutter project.

## Getting Started

This is a project built using Flutter for 8Club's "Flutter Developer Intern" role
Here's the demo link for the app: https://drive.google.com/file/d/16X7evnmqzWQ7X_G2SSNtS0UljhEoF62X/view?usp=sharing

## Features and functionalities implemented

# Features
Custom app bar
    Created a custom top bar to display the wavy pattern. Using the screen's width and amplitude/wavelength it draws the sine wave sort of line in the app bar to display the progress made. I have kept it as 50/50 as we have two screens.

Experience Selection Screen
    1. Fetches experiences from API using Dio
    2. Multi-select experience cards with grayscale for unselected state and also the cards are a bit tilted as shown in the figma file
    3. Multi-line text field with 250 character limit
    4. Clean, modern UI with proper spacing
    5. State management using BLoC pattern

Onboarding Question Screen
    1. Multi-line text field with 600 character limit
    2. Audio recording with waveform visualization
    3. Dynamic layout - recording buttons hide after recording
    4. Cancel option during recording
    5. Delete option for recorded media
    6. Animated Next button width adjustment
    7. After a video has been recorded you can view the video (same goes for audios as well)
    8. Audio/videos have delete/stop/cancel options

Project Structure


![alt text](image.png)


## Default flutter project creation stuff 
This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
