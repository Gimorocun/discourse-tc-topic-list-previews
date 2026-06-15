import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import concatClass from "discourse/helpers/concat-class";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { deferAnonymousAction } from "discourse/lib/anonymous-action";
import { i18n } from "discourse-i18n";

export default class PreviewsVoteComponent extends Component {
  @service siteSettings;
  @service currentUser;
  @service topicListPreviews;

  @tracked voteCount = this.args.topic.vote_count || 0;
  @tracked hasVoted = !!this.args.topic.user_voted;

  get showVoteButton() {
    return (
      this.siteSettings.topic_voting_enabled &&
      this.args.topic.can_vote &&
      this.topicListPreviews.displayActions
    );
  }

  get voteIcon() {
    return this.hasVoted ? "vote-up-filled" : "vote-up";
  }

  get voteClass() {
    return this.hasVoted ? "has-voted" : "";
  }

  get voteTitle() {
    if (this.args.topic.closed) {
      return i18n("topic_voting.voting_closed_description");
    }

    if (this.currentUser?.vote_limit === 0) {
      return i18n("topic_voting.locked_description");
    }

    return this.hasVoted
      ? i18n("topic_voting.remove_vote")
      : i18n("topic_voting.vote_title");
  }

  get voteDisabled() {
    return (
      this.args.topic.closed ||
      this.args.topic.archived ||
      (this.currentUser?.votes_exceeded && !this.hasVoted) ||
      this.currentUser?.vote_limit === 0
    );
  }

  @action
  toggleVote() {
    if (!this.currentUser) {
      if (this.args.topic.archived || this.args.topic.closed) {
        return;
      }

      return deferAnonymousAction(this, "vote_topic", {
        topic_id: this.args.topic.id,
      });
    }

    if (this.voteDisabled) {
      return;
    }

    if (this.hasVoted) {
      this.removeVote();
    } else {
      this.addVote();
    }
  }

  @action
  addVote() {
    return ajax("/voting/vote", {
      type: "POST",
      data: {
        topic_id: this.args.topic.id,
      },
    })
      .then((result) => {
        this.voteCount = result.vote_count;
        this.hasVoted = true;
        this.args.topic.vote_count = result.vote_count;
        this.args.topic.user_voted = true;

        if (this.currentUser) {
          this.currentUser.votes_exceeded = !result.can_vote;
          this.currentUser.vote_limit = result.vote_limit;
          this.currentUser.votes_left = result.votes_left;
        }
      })
      .catch(popupAjaxError);
  }

  @action
  removeVote() {
    return ajax("/voting/unvote", {
      type: "POST",
      data: {
        topic_id: this.args.topic.id,
      },
    })
      .then((result) => {
        this.voteCount = result.vote_count;
        this.hasVoted = false;
        this.args.topic.vote_count = result.vote_count;
        this.args.topic.user_voted = false;

        if (this.currentUser) {
          this.currentUser.votes_exceeded = !result.can_vote;
          this.currentUser.vote_limit = result.vote_limit;
          this.currentUser.votes_left = result.votes_left;
        }
      })
      .catch(popupAjaxError);
  }

  <template>
    {{#if this.showVoteButton}}
      <span class="tlp-list-vote list-vote-count">
        {{#if this.voteCount}}
          <span class="vote-count">{{this.voteCount}}</span>
        {{/if}}
        <DButton
          @action={{this.toggleVote}}
          class={{concatClass
            "list-button btn-transparent topic-vote"
            this.voteClass
          }}
          title={{this.voteTitle}}
          disabled={{this.voteDisabled}}
          data-topic_id={{@topic.id}}
        >
          {{icon this.voteIcon}}
        </DButton>
      </span>
    {{/if}}
  </template>
}
