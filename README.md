# flutter assets builder

# Use this package as a library
Add this to your package's pubspec.yaml file:
## 1. Depend on it
    dev_dependencies:
        assets_builder:
            git:
                url: https://github.com/kecson/assets_builder.git

## 2. Install it   
    flutter pub get   
## 3. generate assets dart file      
    flutter pub run  assets_builder 
## 4. Import it
Now in your Dart code, you can use:

    import 'generated/assets.dart';
    
    //use  image
    Image(image: AssetImage(Assets.images_ic_launcher_png))
