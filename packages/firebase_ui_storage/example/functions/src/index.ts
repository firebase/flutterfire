import * as functions from "firebase-functions/v2";
import { getStorage } from "firebase-admin/storage";
import { encode } from "blurhash";
import * as sharp from "sharp";

exports.genBlurHash = functions.storage.onObjectFinalized(async (event) => {
  const { bucket: fileBucket, name, contentType } = event.data;

  if (!contentType?.startsWith("image/")) {
    return;
  }

  const bucket = getStorage().bucket(fileBucket);
  const file = bucket.file(name);
  const res = await file.download();
  const [buffer] = res;

  const sharpImage = sharp(buffer);
  const metadata = await sharpImage.metadata();

  if (metadata.width === undefined || metadata.height === undefined) {
    return;
  }

  const { width, height } = metadata;

  const blurHashString = encode(
    new Uint8ClampedArray(buffer),
    width,
    height,
    4,
    4
  );

  await file.setMetadata({
    metadata: {
      blurHash: blurHashString,
    },
  });
});
