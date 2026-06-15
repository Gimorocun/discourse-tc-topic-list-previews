import Component from "@glimmer/component";
import concatClass from "discourse/helpers/concat-class";
import DModal from "discourse/components/d-modal";

export default class TlpVideoPreviewModal extends Component {
  get embedUrl() {
    const preview = this.args.model;
    if (!preview?.embedUrl) {
      return null;
    }

    const separator = preview.embedUrl.includes("?") ? "&" : "?";
    return `${preview.embedUrl}${separator}autoplay=1`;
  }

  get isUploadPreview() {
    return !!this.args.model?.url;
  }

  <template>
    <DModal
      @closeModal={{@closeModal}}
      class="tlp-video-preview-modal"
      @hideFooter={{true}}
      @hideHeader={{true}}
    >
      <div
        class={{concatClass
          "tlp-video-preview-modal__content"
          (if this.isUploadPreview "is-upload" "is-embed")
        }}
      >
        {{#if @model.url}}
          <video controls autoplay playsinline src={{@model.url}}></video>
        {{else if this.embedUrl}}
          <iframe
            src={{this.embedUrl}}
            allow="autoplay; encrypted-media; picture-in-picture"
            allowfullscreen
          ></iframe>
        {{/if}}
      </div>
    </DModal>
  </template>
}
