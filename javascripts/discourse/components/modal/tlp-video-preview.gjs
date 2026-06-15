import Component from "@glimmer/component";
import DModal from "discourse/components/d-modal";
import { i18n } from "discourse-i18n";

export default class TlpVideoPreviewModal extends Component {
  get embedUrl() {
    const preview = this.args.model;
    if (!preview?.embedUrl) {
      return null;
    }

    const separator = preview.embedUrl.includes("?") ? "&" : "?";
    return `${preview.embedUrl}${separator}autoplay=1`;
  }

  <template>
    <DModal
      @closeModal={{@closeModal}}
      class="tlp-video-preview-modal"
      @title={{i18n (themePrefix "tlp.video_preview.modal_title")}}
    >
      <div class="tlp-video-preview-modal__content">
        {{#if @model.url}}
          <video controls autoplay playsinline src={{@model.url}}></video>
        {{else if this.embedUrl}}
          <iframe
            src={{this.embedUrl}}
            title={{i18n (themePrefix "tlp.video_preview.modal_title")}}
            allow="autoplay; encrypted-media; picture-in-picture"
            allowfullscreen
          ></iframe>
        {{/if}}
      </div>
    </DModal>
  </template>
}
