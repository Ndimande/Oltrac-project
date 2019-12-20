# OlTrace

[![Codemagic build status](https://api.codemagic.io/apps/5cbec5553371835a3f1ae83a/5cbec5553371835a3f1ae839/status_badge.svg)](https://codemagic.io/apps/5cbec5553371835a3f1ae83a/5cbec5553371835a3f1ae839/latest_build)

A mobile app built on Flutter for tracking shark fins and other products.

### Build runner 

You must run build_runner to generate MobX code.
```
flutter packages pub run build_runner build
```

To run in watch mode:
```
flutter packages pub run build_runner watch
```

You can also use the convenience shell script `br.sh` as follows:
```
br.sh build
br.sh watch
```

### Notes

Because `catch` is a reserved word in Dart. The word 'landing' is used in its place in the code.
