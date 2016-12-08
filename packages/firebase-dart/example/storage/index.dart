import 'dart:html';

import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/src/assets/assets.dart';

main() async {
  //Use for firebase package development only
  await config();

  fb.initializeApp(
      apiKey: apiKey,
      authDomain: authDomain,
      databaseURL: databaseUrl,
      storageBucket: storageBucket);

  new ImageUploadApp();
}

class ImageUploadApp {
  final fb.StorageReference ref;
  final InputElement _uploadImage;

  ImageUploadApp()
      : ref = fb.storage().ref("pkg_firebase/examples/storage"),
        _uploadImage = querySelector("#upload_image") {
    _uploadImage.disabled = false;

    _uploadImage.onChange.listen((e) async {
      e.preventDefault();
      var file = (e.target as FileUploadInputElement).files[0];

      var customMetadata = {"location": "Prague", "owner": "You"};
      var uploadTask = ref.child(file.name).put(
          file,
          new fb.UploadMetadata(
              contentType: file.type, customMetadata: customMetadata));
      uploadTask.onStateChanged.listen((e) {
        querySelector("#message").text =
            "Transfered ${e.bytesTransferred}/${e.totalBytes}...";
      });

      try {
        var snapshot = await uploadTask.future;
        var filePath = snapshot.downloadURL;
        var metadata = snapshot.metadata.customMetadata;
        var image = new ImageElement(src: filePath.toString());
        document.body.append(image);
        querySelector("#message").text = "Metadata: ${metadata.toString()}";
      } catch (e) {
        print(e);
      }
    });
  }
}
