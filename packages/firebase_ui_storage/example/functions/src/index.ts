import * as functions from "firebase-functions/v2";
import { getStorage } from "firebase-admin/storage";
import { encode } from "blurhash";
import * as sharp from "sharp";
import { initializeApp } from "firebase-admin/app";

initializeApp();

type ResizeResult = {
  buffer: Buffer;
  width: number;
  height: number;
};

exports.genBlurHash = functions.storage.onObjectFinalized(async (event) => {
  const { bucket: fileBucket, name, contentType } = event.data;

  if (!contentType?.startsWith("image/")) {
    return;
  }

  const bucket = getStorage().bucket(fileBucket);
  const file = bucket.file(name);
  const res = await file.download();
  const [buffer] = res;

  const {
    buffer: sharpBuffer,
    width,
    height,
  } = await new Promise<ResizeResult>((resolve, reject) => {
    sharp(buffer)
      .raw()
      .ensureAlpha()
      .resize(64, 64, {
        fit: "inside",
      })
      .toBuffer((err, buffer, { width, height }) => {
        if (err) {
          reject(err);
          return;
        }
        resolve({ buffer, width, height });
      });
  });

  const blurHashString = encode(
    new Uint8ClampedArray(sharpBuffer),
    width,
    height,
    8,
    8
  );

  await file.setMetadata({
    metadata: {
      blurHash: blurHashString,
    },
  });
});
