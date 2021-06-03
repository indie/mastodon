# frozen_string_literal: true

module Paperclip
  module UrlGeneratorExtensions
    # Monkey-patch Paperclip to use Addressable::URI's normalization instead
    # of the long-deprecated URI.esacpe
    def escape_url(url)
      if url.respond_to?(:escape)
        url.escape
      else
        Addressable::URI.parse(url).normalize.to_str.gsub(escape_regex) { |m| "%#{m.ord.to_s(16).upcase}" }
      end
    end
<<<<<<< HEAD

    def for_as_default(style_name)
      attachment_options[:interpolator].interpolate(default_url, @attachment, style_name)
    end
=======
>>>>>>> 0db8db0294dca2f3fd4490431f27a697be5f4d42
  end
end

Paperclip::UrlGenerator.prepend(Paperclip::UrlGeneratorExtensions)
