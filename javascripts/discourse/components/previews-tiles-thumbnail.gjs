import { modifier } from "ember-modifier";
import { scheduleGridItemResize } from "../lib/gridupdate";
import PreviewsThumbnail from "./previews-thumbnail";

export default class PreviewsTilesThumbnail extends PreviewsThumbnail {
  gridResizeWatcher = modifier((element) => {
    const row = element.closest(".topic-list-item");

    const resize = () => {
      if (row) {
        scheduleGridItemResize(row);
      }
    };

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

    watchMedia(element);

    const observer = new MutationObserver(() => {
      watchMedia(element);
      resize();
    });

    observer.observe(element, {
      childList: true,
      subtree: true,
      attributes: true,
      attributeFilter: ["data-tlp-media-pending", "src"],
    });

    resize();

    return () => {
      observer.disconnect();
    };
  });

  <template>
    <div
      class="topic-thumbnail"
      data-tlp-media-pending={{if this.mediaPending "true"}}
      {{this.gridResizeWatcher}}
    >
      <PreviewsThumbnail @topic={{@topic}} @tiles={{true}} />
    </div>
  </template>
}
