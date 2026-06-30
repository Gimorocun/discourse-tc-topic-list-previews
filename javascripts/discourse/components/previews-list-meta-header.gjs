import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import dConcatClass from "discourse/ui-kit/helpers/d-concat-class";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default class PreviewsListMetaHeader extends Component {
  @service topicListPreviews;

  get isSortingPosts() {
    return this.args.sortable && this.args.activeOrder === "posts";
  }

  get isSortingViews() {
    return this.args.sortable && this.args.activeOrder === "views";
  }

  get isSortingActivity() {
    return this.args.sortable && this.args.activeOrder === "activity";
  }

  @action
  onSort(order, event) {
    event.preventDefault();
    this.args.changeSort(order);
  }

  @action
  onKeyDown(order, event) {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      this.args.changeSort(order);
    }
  }

  <template>
    <th class="topic-list-data tlp-list-meta" scope="col">
      <div class="tlp-list-meta__container">
        <div class="tlp-list-meta__top">
          <div
            class={{dConcatClass
              "num posts"
              (if @sortable "sortable")
              (if this.isSortingPosts "sorting")
            }}
            data-sort-order="posts"
            aria-sort={{if this.isSortingPosts (if @ascending "ascending" "descending")}}
          >
            {{#if @sortable}}
              <button
                {{on "click" (fn this.onSort "posts")}}
                {{on "keydown" (fn this.onKeyDown "posts")}}
                aria-pressed={{this.isSortingPosts}}
              >
                {{i18n "replies"}}
                {{#if this.isSortingPosts}}
                  {{dIcon (if @ascending "chevron-up" "chevron-down")}}
                {{/if}}
              </button>
            {{else}}
              <span>{{i18n "replies"}}</span>
            {{/if}}
          </div>

          <div
            class={{dConcatClass
              "num views"
              (if @sortable "sortable")
              (if this.isSortingViews "sorting")
            }}
            data-sort-order="views"
            aria-sort={{if this.isSortingViews (if @ascending "ascending" "descending")}}
          >
            {{#if @sortable}}
              <button
                {{on "click" (fn this.onSort "views")}}
                {{on "keydown" (fn this.onKeyDown "views")}}
                aria-pressed={{this.isSortingViews}}
              >
                {{i18n "views"}}
                {{#if this.isSortingViews}}
                  {{dIcon (if @ascending "chevron-up" "chevron-down")}}
                {{/if}}
              </button>
            {{else}}
              <span>{{i18n "views"}}</span>
            {{/if}}
          </div>

          <div
            class={{dConcatClass
              "num activity"
              (if @sortable "sortable")
              (if this.isSortingActivity "sorting")
            }}
            data-sort-order="activity"
            aria-sort={{if this.isSortingActivity (if @ascending "ascending" "descending")}}
          >
            {{#if @sortable}}
              <button
                {{on "click" (fn this.onSort "activity")}}
                {{on "keydown" (fn this.onKeyDown "activity")}}
                aria-pressed={{this.isSortingActivity}}
              >
                {{i18n "activity"}}
                {{#if this.isSortingActivity}}
                  {{dIcon (if @ascending "chevron-up" "chevron-down")}}
                {{/if}}
              </button>
            {{else}}
              <span>{{i18n "activity"}}</span>
            {{/if}}
          </div>
        </div>

        {{#if this.topicListPreviews.listMetaIncludesPosters}}
          <div class="tlp-list-meta__bottom posters">
            <span class="sr-only">{{i18n "category.sort_options.posters"}}</span>
          </div>
        {{/if}}
      </div>
    </th>
  </template>
}
