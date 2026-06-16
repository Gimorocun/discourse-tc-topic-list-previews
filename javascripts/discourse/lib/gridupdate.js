import { getURLWithCDN } from "discourse/lib/get-url";
import loadScript from "discourse/lib/load-script";

const DEFAULT_ROW_SPAN = 44;
let imagesLoadedPromise;
let resizeFrame;
const pendingItems = new Set();

function ensureImagesLoaded() {
  if (!imagesLoadedPromise) {
    imagesLoadedPromise = loadScript(
      getURLWithCDN(settings.theme_uploads.imagesloaded)
    );
  }

  return imagesLoadedPromise;
}

function getGridMetrics() {
  const grid = document.querySelector(".tiles-style tbody");

  if (!grid) {
    return null;
  }

  return {
    rowHeight:
      parseInt(window.getComputedStyle(grid).getPropertyValue("grid-auto-rows"), 10) ||
      4,
    rowGap:
      parseInt(window.getComputedStyle(grid).getPropertyValue("grid-row-gap"), 10) ||
      4,
  };
}

function getCurrentRowSpan(item) {
  const inlineSpan = item.style.gridRowEnd?.match(/span\s+(\d+)/)?.[1];
  if (inlineSpan) {
    return parseInt(inlineSpan, 10);
  }

  const computedSpan = window
    .getComputedStyle(item)
    .gridRowEnd?.match(/span\s+(\d+)/)?.[1];

  return parseInt(computedSpan, 10) || DEFAULT_ROW_SPAN;
}

export function itemMediaPending(item) {
  if (!item) {
    return false;
  }

  if (item.querySelector("[data-tlp-media-pending]")) {
    return true;
  }

  return Array.from(item.querySelectorAll(".topic-thumbnail img")).some(
    (img) => !img.complete || img.naturalHeight === 0
  );
}

function itemExpectsMedia(item) {
  if (itemMediaPending(item)) {
    return true;
  }

  return !!item.querySelector(
    ".topic-thumbnail img, .topic-thumbnail video, .topic-thumbnail button.topic-video-preview"
  );
}

function getIsSideBySide() {
  const topicList = document.querySelector(".topic-list.tiles-style");
  const listArea = document.getElementById("list-area");

  return (
    topicList?.classList.contains("side-by-side") &&
    listArea &&
    listArea.offsetWidth > 900
  );
}

function calculateContentHeight(item, isSideBySide) {
  if (isSideBySide) {
    return item.getBoundingClientRect().height;
  }

  return Array.from(item.children).reduce(
    (total, child) => total + child.getBoundingClientRect().height,
    0
  );
}

function applyRowSpan(item, rowSpan, isSideBySide) {
  if (isSideBySide) {
    item.style.gridRowEnd = "span 1";
    return;
  }

  const currentSpan = getCurrentRowSpan(item);
  const pending = itemMediaPending(item);
  const expectsMedia = itemExpectsMedia(item);

  if (!Number.isFinite(rowSpan)) {
    rowSpan = expectsMedia ? DEFAULT_ROW_SPAN : 1;
  }

  rowSpan = Math.max(rowSpan, 1);

  if (pending) {
    rowSpan = Math.max(rowSpan, currentSpan, DEFAULT_ROW_SPAN);
  } else if (expectsMedia) {
    rowSpan = Math.max(rowSpan, DEFAULT_ROW_SPAN);
  }

  item.style.gridRowEnd = `span ${rowSpan}`;
}

function resizeGridItem(item, isSideBySide, metrics) {
  const { rowHeight, rowGap } = metrics;
  const contentHeight = calculateContentHeight(item, isSideBySide);
  const rowSpan = Math.ceil((contentHeight + rowGap) / (rowHeight + rowGap));

  applyRowSpan(item, rowSpan, isSideBySide);
}

function resizeGridItemWithImages(item, isSideBySide, metrics) {
  return ensureImagesLoaded().then(() => {
    return new Promise((resolve) => {
      // eslint-disable-next-line no-undef
      imagesLoaded(item, () => {
        resizeGridItem(item, isSideBySide, metrics);
        resolve();
      });
    });
  });
}

export function scheduleGridItemResize(item) {
  if (!item) {
    return;
  }

  pendingItems.add(item);

  if (resizeFrame) {
    return;
  }

  resizeFrame = requestAnimationFrame(() => {
    resizeFrame = null;
    const metrics = getGridMetrics();

    if (!metrics) {
      pendingItems.clear();
      return;
    }

    const isSideBySide = getIsSideBySide();
    const items = [...pendingItems];
    pendingItems.clear();

    items.forEach((gridItem) => {
      resizeGridItemWithImages(gridItem, isSideBySide, metrics);
    });
  });
}

function resizeAllGridItems(isSideBySide) {
  const items = document.getElementsByClassName("topic-list-item");

  for (let i = 0; i < items.length; i++) {
    scheduleGridItemResize(items[i]);
  }
}

export { resizeAllGridItems };
