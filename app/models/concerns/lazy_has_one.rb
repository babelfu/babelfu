# frozen_string_literal: true

module LazyHasOne
  extend ActiveSupport::Concern

  class_methods do
    def lazy_has_one(association)
      define_method(association) do
        super() || send("build_#{association}")
      end

      define_method("#{association}!") do
        if send(association).persisted?
          send(association)
        else
          send("create_#{association}!")
        end
      end
    end
  end
end
