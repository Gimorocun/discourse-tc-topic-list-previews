import Component from "@glimmer/component";
import { service } from "@ember/service";
import { trustHTML } from "@ember/template";
import PluginOutlet from "discourse/components/plugin-outlet";
import coldAgeClass from "discourse/helpers/cold-age-class";
import lazyHash from "discourse/helpers/lazy-hash";
import dConcatClass from "discourse/ui-kit/helpers/d-concat-class";
import DUserLink from "discourse/ui-kit/d-user-link";
import dAvatar from "discourse/ui-kit/helpers/d-avatar";
import dFormatDate from "discourse/ui-kit/helpers/d-format-date";
import dNumber from "discourse/ui-kit/helpers/d-number";
import { i18n } from "discourse-i18n";

export default class PreviewsListMetaCell extends Component {
  @service siteSettings;
  @service topicListPreviews;

  get ratio() {
    const likes = parseFloat(this.args.topic.like_count);
    const posts = parseFloat(this.args.topic.posts_count);

    if (posts < 10) {
      return 0;
    }

    return (likes || 0) / posts;
  }

  get ratioText() {
    if (this.ratio > this.siteSettings.topic_post_like_heat_high) {
      return "high";
    }
    if (this.ratio > this.siteSettings.topic_post_like_heat_medium) {
      return "med";
    }
    if (this.ratio > this.siteSettings.topic_post_like_heat_low) {
      return "low";
    }
    return "";
  }

  get likesHeat() {
    if (this.ratioText?.length) {
      return `heatmap-${this.ratioText}`;
    }
  }

  <template>
    <td class="topic-list-data tlp-list-meta">
      <div class="tlp-list-meta__container">
        <div class="tlp-list-meta__top">
          <div class={{dConcatClass "num posts-map posts" this.likesHeat}}>
            <a
              href={{@topic.firstPostUrl}}
              class="badge-posts"
              aria-label={{i18n "topic.reply_count_link" count=@topic.replyCount}}
            >
              <PluginOutlet
                @name="topic-list-before-reply-count"
                @outletArgs={{lazyHash topic=@topic}}
              />
              {{dNumber @topic.replyCount noTitle="true"}}
            </a>
          </div>

          <div class={{dConcatClass "num views" @topic.viewsHeat}}>
            <PluginOutlet
              @name="topic-list-before-view-count"
              @outletArgs={{lazyHash topic=@topic}}
            />
            {{dNumber @topic.views numberKey="views_long"}}
          </div>

          <div
            title={{trustHTML @topic.bumpedAtTitle}}
            class={{dConcatClass
              "activity num"
              (coldAgeClass @topic.createdAt startDate=@topic.bumpedAt class="")
            }}
          >
            <a href={{@topic.lastPostUrl}} class="post-activity">
              <PluginOutlet
                @name="topic-list-before-relative-date"
                @outletArgs={{lazyHash topic=@topic}}
              />
              {{dFormatDate @topic.bumpedAt format="tiny" noTitle="true"}}
            </a>
          </div>
        </div>

        {{#if this.topicListPreviews.listMetaIncludesPosters}}
          <div class="tlp-list-meta__bottom posters">
            {{#each @topic.featuredUsers as |poster|}}
              {{#if poster.moreCount}}
                <a class="posters-more-count">{{poster.moreCount}}</a>
              {{else}}
                <DUserLink
                  @username={{poster.user.username}}
                  @href={{poster.user.path}}
                  class={{poster.extraClasses}}
                >
                  {{dAvatar
                    poster
                    avatarTemplatePath="user.avatar_template"
                    usernamePath="user.username"
                    namePath="user.name"
                    imageSize="small"
                  }}</DUserLink>
              {{/if}}
            {{/each}}
          </div>
        {{/if}}
      </div>
    </td>
  </template>
}
