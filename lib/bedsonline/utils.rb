module Bedsonline
  module Utils
    def self.clean_utf8(string_to_clean)
      return string_to_clean.force_encoding('UTF-8').encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    end
  end
end
