const YOUTUBE_ID_PATTERN =
  /(?:youtube\.com\/(?:embed\/|watch\?v=)|youtu\.be\/)([\w-]{11})/i;
const VIMEO_ID_PATTERN = /vimeo\.com\/(?:video\/)?(\d+)/i;

function normalizeUrl(url) {
  if (!url || url === "/404") {
    return null;
  }

  try {
    return new URL(url, window.location.origin).href;
  } catch {
    return url.startsWith("/") ? `${window.location.origin}${url}` : url;
  }
}

function youtubePoster(videoId) {
  return `https://img.youtube.com/vi/${videoId}/hqdefault.jpg`;
}

function parseEmbedFromIframe(src) {
  if (!src) {
    return null;
  }

  const youtubeMatch = src.match(YOUTUBE_ID_PATTERN);
  if (youtubeMatch) {
    return {
      type: "embed",
      provider: "youtube",
      videoId: youtubeMatch[1],
      embedUrl: `https://www.youtube.com/embed/${youtubeMatch[1]}`,
      poster: youtubePoster(youtubeMatch[1]),
    };
  }

  const vimeoMatch = src.match(VIMEO_ID_PATTERN);
  if (vimeoMatch) {
    return {
      type: "embed",
      provider: "vimeo",
      videoId: vimeoMatch[1],
      embedUrl: `https://player.vimeo.com/video/${vimeoMatch[1]}`,
      poster: null,
    };
  }

  return null;
}

function parseLazyEmbed(element) {
  const provider = element.getAttribute("data-provider-name");
  const videoId = element.getAttribute("data-video-id");

  if (!provider || !videoId) {
    return null;
  }

  if (provider === "youtube") {
    return {
      type: "embed",
      provider: "youtube",
      videoId,
      embedUrl: `https://www.youtube.com/embed/${videoId}`,
      poster: youtubePoster(videoId),
    };
  }

  if (provider === "vimeo") {
    return {
      type: "embed",
      provider: "vimeo",
      videoId,
      embedUrl: `https://player.vimeo.com/video/${videoId}`,
      poster: null,
    };
  }

  return {
    type: "embed",
    provider,
    videoId,
    embedUrl: null,
    poster: null,
  };
}

function parseUploadSource(sourceUrl, posterUrl = null) {
  const url = normalizeUrl(sourceUrl);
  if (!url) {
    return null;
  }

  return {
    type: "upload",
    url,
    poster: normalizeUrl(posterUrl),
  };
}

export function extractVideoPreviewFromCooked(cookedHtml) {
  if (!cookedHtml) {
    return null;
  }

  const doc = new DOMParser().parseFromString(cookedHtml, "text/html");

  const placeholder = doc.querySelector(".video-placeholder-container");
  if (placeholder) {
    const preview = parseUploadSource(
      placeholder.getAttribute("data-video-src"),
      placeholder.getAttribute("data-thumbnail-src")
    );
    if (preview) {
      return preview;
    }
  }

  const lazyEmbed = doc.querySelector("[data-video-id][data-provider-name]");
  if (lazyEmbed) {
    const preview = parseLazyEmbed(lazyEmbed);
    if (preview) {
      return preview;
    }
  }

  const iframe = doc.querySelector(
    ".onebox iframe[src*='youtube'], .onebox iframe[src*='vimeo']"
  );
  if (iframe) {
    const preview = parseEmbedFromIframe(iframe.getAttribute("src"));
    if (preview) {
      return preview;
    }
  }

  const uploadSource = doc.querySelector(
    ".video-onebox video source, .onebox.video-onebox video source, video source"
  );
  if (uploadSource) {
    const preview = parseUploadSource(uploadSource.getAttribute("src"));
    if (preview) {
      return preview;
    }
  }

  const videoElement = doc.querySelector("video[src]");
  if (videoElement) {
    const preview = parseUploadSource(
      videoElement.getAttribute("src"),
      videoElement.getAttribute("poster")
    );
    if (preview) {
      return preview;
    }
  }

  return null;
}

export function topicHasPostThumbnail(topic) {
  return topic?.thumbnails?.length > 0;
}
