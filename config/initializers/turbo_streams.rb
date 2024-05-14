# frozen_string_literal: true

Turbo::Streams::BroadcastJob.queue_name = "turbo_streams"
Turbo::Streams::ActionBroadcastJob.queue_name = "turbo_streams"
Turbo::Streams::BroadcastStreamJob.queue_name = "turbo_streams"
