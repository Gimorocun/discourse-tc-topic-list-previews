import { tracked } from "@glimmer/tracking";
import Service from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { parseTopicPreviewFromCooked } from "../lib/topic-video-preview";

const MAX_CONCURRENT_REQUESTS = 4;
const EMPTY_PREVIEW = { video: null, hasStandaloneImages: false };

export default class TopicVideoPreviewsService extends Service {
  @tracked cacheRevision = 0;

  #cache = new Map();
  #pending = new Map();
  #queue = [];
  #activeRequests = 0;

  getPreview(topicId) {
    // Depend on cacheRevision so getters recompute after async updates.
    this.cacheRevision;
    return this.#cache.get(topicId);
  }

  loadPreview(topic) {
    if (!topic?.id) {
      return Promise.resolve(EMPTY_PREVIEW);
    }

    const cached = this.#cache.get(topic.id);
    if (cached !== undefined) {
      return Promise.resolve(cached);
    }

    if (this.#pending.has(topic.id)) {
      return this.#pending.get(topic.id);
    }

    const request = new Promise((resolve) => {
      this.#queue.push({ topic, resolve });
      this.#processQueue();
    });

    this.#pending.set(topic.id, request);
    return request;
  }

  #processQueue() {
    while (
      this.#activeRequests < MAX_CONCURRENT_REQUESTS &&
      this.#queue.length > 0
    ) {
      const job = this.#queue.shift();
      this.#activeRequests++;
      this.#fetchPreview(job.topic)
        .then((preview) => {
          this.#cache.set(job.topic.id, preview);
          this.cacheRevision++;
          job.resolve(preview);
        })
        .catch(() => {
          this.#cache.set(job.topic.id, EMPTY_PREVIEW);
          this.cacheRevision++;
          job.resolve(EMPTY_PREVIEW);
        })
        .finally(() => {
          this.#activeRequests--;
          this.#pending.delete(job.topic.id);
          this.#processQueue();
        });
    }
  }

  async #fetchPreview(topic) {
    const result = await ajax(`/t/${topic.id}.json`, {
      data: { track_visit: false },
    });

    const cooked = result?.post_stream?.posts?.[0]?.cooked;
    return parseTopicPreviewFromCooked(cooked);
  }
}
