# Lambda-Task

This repository contains several files corresponding to a single Flutter app in a hierarchical manner.
In order to run the app, one needs to download the files into one folder, maintaining the hierarchy, and install all the dependencies in the .yaml file.
It can be done using 'flutter pub get' in a CLI.
The app can be launched and run on an Android device or emulator.


Overview of the app:
The app serves as a To-Do app, which allows user to add tasks(specifying a deadline and a priority if required), under 4 different categories.
Once added, tasks can be edited or removed as per will. Higher priority tasks are displayed first.

The app makes use of persistent storage, so once a task is added, its information is not lost upon closing the app.
One of the four categories, 'All-purpose' is a general category, and tasks added in it are visible across categories.

The app also makes use of a search feature, and lets the user search for existing tasks by name.
