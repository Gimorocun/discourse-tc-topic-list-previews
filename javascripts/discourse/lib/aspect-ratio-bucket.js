const DEFAULT_BUCKET = "square";

export function aspectRatioBucketName(width, height) {
  if (!width || !height) {
    return DEFAULT_BUCKET;
  }

  if (width > height) {
    return "wide";
  }

  if (width < height) {
    return "narrow";
  }

  return "square";
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
