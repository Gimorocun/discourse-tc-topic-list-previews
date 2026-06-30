import Component from "@glimmer/component";
import { service } from "@ember/service";
import { trustHTML } from "@ember/template";
import truncateExcerpt from "../../lib/truncate-excerpt";

export default class PreviewsExcerpt extends Component {
  @service topicListPreviews;

  get showExcerpt() {
    return this.topicListPreviews.displayExcerpts && this.args.topic.hasExcerpt;
  }

  get destinationUrl() {
    if (this.args.topic.force_latest_post_nav && this.args.topic.last_post_id) {
      return `/t/${this.args.topic.slug}/${this.args.topic.id}/${this.args.topic.last_post_id}`;
    } else {
      return this.args.topic.url;
    }
  }

  get excerpt() {
    const raw = this.args.topic.show_latest_post_excerpt
      ? this.args.topic.last_post_excerpt
      : this.args.topic.excerpt;

    return trustHTML(
      truncateExcerpt(raw, settings.topic_list_excerpt_length)
    );
  }

  <template>
    {{#if this.showExcerpt}}
      <a class="topic-excerpt" href={{this.destinationUrl}}>
        {{this.excerpt}}
      </a>
    {{/if}}
  </template>
}
