# frozen_string_literal: true

class SyncWidgetComponent < ViewComponent::Base
  attr_reader :object, :live

  # live is a boolean that determines if the component is being rendered as part
  # of a stream update or not.
  def initialize(object, live: false)
    @object = object
    @live = live
  end

  def tooltip_text
    object.synced_at ? sinced_text_ago : "Not synced yet"
  end

  def sinced_text_ago
    "Synced #{time_ago_in_words(object.synced_at)} ago"
  end
end
