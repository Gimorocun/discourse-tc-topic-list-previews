import { modifier } from "ember-modifier";
import { scheduleGridItemResize } from "../lib/gridupdate";
import PreviewsThumbnail from "./previews-thumbnail";

export default class PreviewsTilesThumbnail extends PreviewsThumbnail {
  syncRowHeight = modifier((element, [showThumbnailArea]) => {
    const row = element.closest(".topic-list-item");
    scheduleGridItemResize(row);

    if (!showThumbnailArea) {
      return;
    }

    const thumbnail = element.querySelector(".topic-thumbnail");
    if (!thumbnail) {
      return;
    }

    const resize = () => scheduleGridItemResize(row);

    const watchMedia = (root) => {
      root.querySelectorAll("img").forEach((img) => {
        if (img.complete) {
          return;
        }

        img.addEventListener("load", resize, { once: true });
        img.addEventListener("error", resize, { once: true });
      });

      root.querySelectorAll("video").forEach((video) => {
        if (video.readyState >= 1) {
          return;
        }

        video.addEventListener("loadedmetadata", resize, { once: true });
        video.addEventListener("error", resize, { once: true });
      });
    };

    watchMedia(thumbnail);

    const observer = new MutationObserver(() => {
      watchMedia(thumbnail);
      resize();
    });

    observer.observe(thumbnail, {
      childList: true,
      subtree: true,
      attributes: true,
      attributeFilter: ["data-tlp-media-pending", "src"],
    });

    return () => {
      observer.disconnect();
    };
  });

  get showThumbnailArea() {
    return (
      this.mediaPending ||
      this.previewUrl ||
      this.showVideoPreview ||
      this.defaultThumbnailUrl
    );
  }

  get shouldProbeForMedia() {
    return (
      !this.showThumbnailArea &&
      this.mediaPreview === undefined &&
      !this.hasPostThumbnail &&
      !this.getDefaultThumbnail
    );
  }

  <template>
    <span {{this.syncRowHeight this.showThumbnailArea}}>
      {{#if this.showThumbnailArea}}
        <div
          class="topic-thumbnail"
          data-tlp-media-pending={{if this.mediaPending "true"}}
        >
          <PreviewsThumbnail @topic={{@topic}} @tiles={{true}} />
        </div>
      {{else if this.shouldProbeForMedia}}
        <span hidden>
          <PreviewsThumbnail @topic={{@topic}} @tiles={{true}} />
        </span>
      {{/if}}
    </span>
  </template>
}
