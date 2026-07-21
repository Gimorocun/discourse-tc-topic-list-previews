const NORMAL_RATIO = 5 / 3;
// Band around 5:3 counts as "normal"; outside becomes wide/narrow.
const RATIO_BAND = 1.1;
const WIDE_THRESHOLD = NORMAL_RATIO * RATIO_BAND; // ~1.83
const NARROW_THRESHOLD = NORMAL_RATIO / RATIO_BAND; // ~1.52

export function aspectRatioBucketName(width, height) {
  if (!width || !height) {
    return "normal";
  }

  const ratio = width / height;

  if (ratio >= WIDE_THRESHOLD) {
    return "wide";
  }

  if (ratio <= NARROW_THRESHOLD) {
    return "narrow";
  }

  return "normal";
}

export function aspectRatioBucketClass(width, height) {
  return `aspect-${aspectRatioBucketName(width, height)}`;
}

export function thumbnailSourceDimensions(thumbnails) {
  if (!thumbnails?.length) {
    return null;
  }

  const original = thumbnails.find(
    (thumb) => thumb.max_width == null && thumb.max_height == null
  );
  const source = original || thumbnails[0];

  if (!source?.width || !source?.height) {
    return null;
  }

  return {
    width: source.width,
    height: source.height,
  };
}
