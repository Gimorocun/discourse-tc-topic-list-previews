import Service from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { parseTopicPreviewFromCooked } from "../lib/topic-video-preview";

const EMPTY_PREVIEW = { video: null, hasStandaloneImages: false };

export default class TopicVideoPreviewsService extends Service {
  async loadPreview(topic) {
    if (!topic?.id) {
      return EMPTY_PREVIEW;
    }

    try {
      const result = await ajax(`/t/${topic.id}.json`, {
        data: { track_visit: false },
      });

      const cooked = result?.post_stream?.posts?.[0]?.cooked;
      return parseTopicPreviewFromCooked(cooked);
    } catch {
      return EMPTY_PREVIEW;
    }
  }
}
