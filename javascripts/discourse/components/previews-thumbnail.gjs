import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { modifier } from "ember-modifier";
import concatClass from "discourse/helpers/concat-class";
import dIcon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";
import { topicHasPostThumbnail } from "../lib/topic-video-preview";
import TlpVideoPreviewModal from "./modal/tlp-video-preview";

export default class PreviewsThumbnail extends Component {
  @service currentUser;
  @service topicVideoPreviews;
  @service modal;

  get getDefaultThumbnail() {
    const defaultThumbnail = settings.topic_list_default_thumbnail_fallback;
    return defaultThumbnail ? settings.topic_list_default_thumbnail : false;
  }

  get hasPostThumbnail() {
    return topicHasPostThumbnail(this.args.topic);
  }

  get mediaPreview() {
    return this.topicVideoPreviews.getPreview(this.args.topic.id);
  }

  get videoPreview() {
    const preview = this.mediaPreview;
    if (!preview?.video || preview.hasStandaloneImages) {
      return null;
    }

    return preview.video;
  }

  get canShowImageThumbnail() {
    if (!this.hasPostThumbnail) {
      return false;
    }

    const preview = this.mediaPreview;
    if (preview === undefined) {
      return false;
    }

    return !(preview.video && !preview.hasStandaloneImages);
  }

  get previewUrl() {
    if (!this.canShowImageThumbnail) {
      return null;
    }

    const preferLowRes =
      this.currentUser !== undefined && this.currentUser !== null
        ? this.currentUser.custom_fields
            .tlp_user_prefs_prefer_low_res_thumbnails
        : false;

    let resLevel = settings.topic_list_thumbnail_resolution_level;
    resLevel = Math.round(
      ((this.args.topic.thumbnails.length - 1) / 6) * resLevel
    );
    if (preferLowRes) {
      resLevel++;
    }
    if (window.devicePixelRatio && resLevel > 0) {
      resLevel--;
    }
    return resLevel <= this.args.topic.thumbnails.length - 1
      ? this.args.topic.thumbnails[resLevel].url
      : this.args.topic.thumbnails[this.args.topic.thumbnails.length - 1].url;
  }

  get defaultThumbnailUrl() {
    if (this.hasPostThumbnail || this.showVideoPreview) {
      return null;
    }

    if (this.mediaPreview === undefined) {
      return null;
    }

    return this.getDefaultThumbnail;
  }

  get showVideoPreview() {
    return !!this.videoPreview;
  }

  get mediaPending() {
    if (this.previewUrl || this.showVideoPreview || this.defaultThumbnailUrl) {
      return false;
    }

    return this.mediaPreview === undefined;
  }

  get isTiles() {
    return this.args.tiles ? "tiles-thumbnail" : "non-tiles-thumbnail";
  }

  get destinationUrl() {
    if (this.args.topic.force_latest_post_nav && this.args.topic.last_post_id) {
      return `/t/${this.args.topic.slug}/${this.args.topic.id}/${this.args.topic.last_post_id}`;
    } else {
      return this.args.topic.url;
    }
  }

  loadVideoPreview = modifier(() => {
    if (this.mediaPreview !== undefined) {
      return;
    }

    this.topicVideoPreviews.loadPreview(this.args.topic);
  });

  addHasThumbnailClass = modifier((element) => {
    const row = element.closest(".topic-list-item");
    if (!row) {
      return;
    }

    row.classList.add("has-thumbnail");

    return () => {
      row.classList.remove("has-thumbnail");
    };
  });

  @action
  openVideoModal(event) {
    event.preventDefault();
    event.stopPropagation();

    if (!this.videoPreview) {
      return;
    }

    this.modal.show(TlpVideoPreviewModal, {
      model: this.videoPreview,
    });
  }

  <template>
    {{#if this.previewUrl}}
      <a href={{this.destinationUrl}} {{this.addHasThumbnailClass}}>
        <img
          class={{concatClass "thumbnail" this.isTiles}}
          src={{this.previewUrl}}
          loading="lazy"
        />
      </a>
    {{else if this.showVideoPreview}}
      <button
        type="button"
        class={{concatClass
          "topic-video-preview"
          "thumbnail"
          this.isTiles
        }}
        aria-label={{i18n (themePrefix "tlp.video_preview.play_video")}}
        {{this.addHasThumbnailClass}}
        {{on "click" this.openVideoModal}}
      >
        {{#if this.videoPreview.poster}}
          <img
            class="video-preview-poster"
            src={{this.videoPreview.poster}}
            loading="lazy"
            alt=""
          />
        {{else if this.videoPreview.url}}
          <video
            class="video-preview-media"
            src={{this.videoPreview.url}}
            muted
            playsinline
            preload="metadata"
          ></video>
        {{else}}
          <span class="video-preview-placeholder"></span>
        {{/if}}
        <span class="video-preview-play-icon">
          {{dIcon "play"}}
        </span>
      </button>
    {{else if this.defaultThumbnailUrl}}
      <a href={{this.destinationUrl}} {{this.addHasThumbnailClass}}>
        <img
          class={{concatClass "thumbnail" this.isTiles}}
          src={{this.defaultThumbnailUrl}}
          loading="lazy"
        />
      </a>
    {{else}}
      <span {{this.loadVideoPreview}} hidden></span>
    {{/if}}
  </template>
}
