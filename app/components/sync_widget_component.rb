# frozen_string_literal: true

class SyncWidgetComponent < ViewComponent::Base
  def tooltip_text
    object.synced_at ? sinced_text_ago : "Not synced yet"
  end

  def sinced_text_ago
    "Synced #{time_ago_in_words(object.synced_at)} ago"
  end
end
