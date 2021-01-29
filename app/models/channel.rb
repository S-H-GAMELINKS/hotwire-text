class Channel < ApplicationRecord
    has_many :messages
    broadcasts_to ->(channel) { 
        :channels 
    }
end
